#!/bin/sh
# Xray 容器入口：env 驱动生成 /etc/xray/config.json（幂等，已存在则复用），然后启动 xray
# 逻辑与 scripts/install.sh 的配置段保持一致
set -eu

CONFIG_FILE="${CONFIG_FILE:-/etc/xray/config.json}"
INFO_FILE="$(dirname "$CONFIG_FILE")/xray-info.txt"
ENV_FILE="$(dirname "$CONFIG_FILE")/xray-info.env"
REUSE_CONFIG="${REUSE_CONFIG:-true}"

XRAY_PORT="${XRAY_PORT:-443}"
REALITY_DEST="${REALITY_DEST:-www.cloudflare.com:443}"
REALITY_SNI="${REALITY_SNI:-$(echo "$REALITY_DEST" | cut -d: -f1)}"
PUBLIC_PORT="${PUBLIC_PORT:-$XRAY_PORT}"

# 已有配置则直接复用（密钥无法从 config 反推公钥，链接信息读 sidecar 文件）
if [ "$REUSE_CONFIG" != "false" ] && [ -f "$CONFIG_FILE" ]; then
  echo "♻️  复用已有配置: $CONFIG_FILE"
  if [ -f "$ENV_FILE" ]; then
    # shellcheck disable=SC1090
    . "$ENV_FILE"
  fi
  if [ -n "${SHARE_LINK:-}" ]; then
    echo ""
    echo "📱 分享链接："
    echo "$SHARE_LINK"
  else
    echo "⚠️  未找到分享链接 sidecar 文件($ENV_FILE)，请查看 $INFO_FILE"
  fi
  echo ""
  exec /usr/local/bin/xray run -c "$CONFIG_FILE"
fi

# ---- 生成身份参数（env 优先，缺失则自动生成）----
UUID="${UUID:-$(uuidgen | tr '[:upper:]' '[:lower:]')}"
SHORT_ID="${SHORT_ID:-$(openssl rand -hex 8)}"

if [ -z "${PRIVATE_KEY:-}" ]; then
  KEYS="$(/usr/local/bin/xray x25519)"
  PRIVATE_KEY="$(echo "$KEYS" | grep -i '^Private' | awk -F': ' '{print $NF}' | tr -d ' ')"
  PUBLIC_KEY="$(echo "$KEYS" | grep -i '^Public\|^Password' | awk -F': ' '{print $NF}' | tr -d ' ')"
elif [ -z "${PUBLIC_KEY:-}" ]; then
  echo "❌ 错误: 提供了 PRIVATE_KEY 但未提供配对的 PUBLIC_KEY，无法启动" >&2
  exit 1
fi

if [ -z "$PRIVATE_KEY" ] || [ -z "${PUBLIC_KEY:-}" ]; then
  echo "❌ 错误: 密钥生成失败" >&2
  exit 1
fi

echo "UUID: $UUID"
echo "Public Key: $PUBLIC_KEY"
echo "Short ID: $SHORT_ID"
echo "Reality Dest: $REALITY_DEST (SNI: $REALITY_SNI)"

# ---- 公网 IP（仅用于分享链接，不影响服務）----
SERVER_IP="${SERVER_IP:-}"
if [ -z "$SERVER_IP" ]; then
  for endpoint in "https://api.ipify.org" "https://ifconfig.me/ip" "https://api.ip.sb/ip"; do
    SERVER_IP="$(curl -4 -s --connect-timeout 5 --max-time 8 "$endpoint" 2>/dev/null | tr -d '[:space:]' || true)"
    case "$SERVER_IP" in
      *.*.*.*) break ;;
      *) SERVER_IP="" ;;
    esac
  done
fi
if [ -z "$SERVER_IP" ]; then
  SERVER_IP="YOUR_SERVER_IP"
  echo "⚠️  无法自动探测公网 IP，分享链接中的地址请手动替换为服务器公网 IP"
fi

case "$SERVER_IP" in
  *:*[!0-9]*|*:*:*) SERVER_HOST_URL="[$SERVER_IP]" ;; # IPv6 加方括号
  *) SERVER_HOST_URL="$SERVER_IP" ;;
esac

# ---- 写配置（与 scripts/install.sh 同 schema，日志走 stdout 便于 docker logs）----
mkdir -p "$(dirname "$CONFIG_FILE")" /var/log/xray
cat > "$CONFIG_FILE" <<EOF
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "port": $XRAY_PORT,
      "protocol": "vless",
      "tag": "vless_tls",
      "settings": {
        "clients": [
          {
            "id": "$UUID",
            "flow": "xtls-rprx-vision",
            "email": "user@example.com"
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "tcp",
        "security": "reality",
        "realitySettings": {
          "show": false,
          "dest": "$REALITY_DEST",
          "serverNames": [
            "$REALITY_SNI"
          ],
          "privateKey": "$PRIVATE_KEY",
          "shortIds": [
            "$SHORT_ID"
          ],
          "maxTimeDiff": 86400
        },
        "sockopt": {
          "tcpFastOpen": true,
          "tcpNoDelay": true,
          "tcpKeepAliveInterval": 30
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "tag": "direct"
    },
    {
      "protocol": "blackhole",
      "tag": "block"
    }
  ],
  "routing": {
    "domainStrategy": "AsIs",
    "rules": [
      {
        "type": "field",
        "ip": [
          "geoip:private"
        ],
        "outboundTag": "block"
      }
    ]
  }
}
EOF

SHARE_LINK="vless://${UUID}@${SERVER_HOST_URL}:${PUBLIC_PORT}?encryption=none&flow=xtls-rprx-vision&security=reality&sni=${REALITY_SNI}&fp=chrome&pbk=${PUBLIC_KEY}&sid=${SHORT_ID}&type=tcp&headerType=none#Xray-Reality"

# sidecar：容器重启复用配置时仍能打印链接（单引号包裹，链接含 & 不会被 shell 解析）
cat > "$ENV_FILE" <<EOF
UUID='$UUID'
PUBLIC_KEY='$PUBLIC_KEY'
SHORT_ID='$SHORT_ID'
REALITY_SNI='$REALITY_SNI'
SHARE_LINK='$SHARE_LINK'
EOF
chmod 600 "$ENV_FILE" "$CONFIG_FILE"

cat > "$INFO_FILE" <<INFO
Xray 配置信息（Docker）
生成时间: $(date -u '+%Y-%m-%d %H:%M:%S UTC')

服务器信息:
- 地址: $SERVER_IP
- 端口: $PUBLIC_PORT
- 协议: VLESS + XTLS-Reality

客户端配置:
- UUID: $UUID
- Public Key: $PUBLIC_KEY
- Short ID: $SHORT_ID
- SNI: $REALITY_SNI
- Flow: xtls-rprx-vision
- Fingerprint: chrome

分享链接:
$SHARE_LINK

容器管理命令:
- 查看链接: docker exec xray-reality cat /etc/xray/xray-info.txt
- 查看日志: docker logs -f xray-reality
- 重启服务: docker restart xray-reality
INFO

echo ""
echo "================================"
echo "✅ Xray 已就绪（Docker）"
echo "================================"
echo ""
echo "📋 服务器信息："
echo "地址: $SERVER_IP"
echo "端口: $PUBLIC_PORT"
echo ""
echo "📱 分享链接："
echo "$SHARE_LINK"
echo ""

exec /usr/local/bin/xray run -c "$CONFIG_FILE"
