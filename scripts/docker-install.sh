#!/bin/bash
#
# Xray Docker 一键安装脚本（对标宿主机 install.sh）
#
# 一键命令（复制粘贴即可）：
#   wget https://raw.githubusercontent.com/lzy1102/Xray-VPN-OneClick/main/scripts/docker-install.sh -O xray-docker-install.sh && sudo bash xray-docker-install.sh
#
# 环境变量（全部可选）：
#   REPO=lzy1102/Xray-VPN-OneClick  BRANCH=main      # 镜像构建文件来源
#   HOST_PORT=443                                        # 宿主机映射端口（云安全组需放行 TCP）
#   REALITY_DEST=www.cloudflare.com:443                  # 伪装目标（默认最稳）
#   REALITY_SNI=                                         # 留空则从 REALITY_DEST 派生
#   UUID= PRIVATE_KEY= PUBLIC_KEY= SHORT_ID= SERVER_IP=  # 留空首次自动生成并持久化
#   XRAY_VERSION=v26.3.27                                # 传 latest 则构建时解析最新版
#   REUSE_CONFIG=true                                    # false 则忽略旧配置重新生成（链接会变）
#   DOCKER_INSTALL_URL=https://get.docker.com            # 国内可用 https://ghproxy.com/https://get.docker.com
#
# 重装/更新：容器已存在时直接复用（链接不变）；重建用 REUSE_CONFIG=false 重新跑一遍本脚本。

set -e

REPO="${REPO:-lzy1102/Xray-VPN-OneClick}"
BRANCH="${BRANCH:-main}"
RAW="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
CONTAINER_NAME="xray-reality"
VOLUME_NAME="xray-config"
IMAGE_NAME="xray-reality"

HOST_PORT="${HOST_PORT:-443}"
REALITY_DEST="${REALITY_DEST:-www.cloudflare.com:443}"
REALITY_SNI="${REALITY_SNI:-}"
UUID="${UUID:-}"
PRIVATE_KEY="${PRIVATE_KEY:-}"
PUBLIC_KEY="${PUBLIC_KEY:-}"
SHORT_ID="${SHORT_ID:-}"
SERVER_IP="${SERVER_IP:-}"
XRAY_VERSION="${XRAY_VERSION:-v26.3.27}"
REUSE_CONFIG="${REUSE_CONFIG:-true}"
DOCKER_INSTALL_URL="${DOCKER_INSTALL_URL:-https://get.docker.com}"

if [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ "$1" = "help" ]; then
  sed -n '2,/^$/p' "$0"
  exit 0
fi

if [ "$(id -u)" != "0" ]; then
  echo "❌ 请用 root 运行: sudo bash $0" >&2
  exit 1
fi

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

# ---- 1. 安装 Docker（缺失时）----
if ! command -v docker >/dev/null 2>&1; then
  echo "[1/4] 未检测到 Docker，正在安装..."
  curl -fsSL "$DOCKER_INSTALL_URL" -o /tmp/get-docker.sh
  sh /tmp/get-docker.sh
  rm -f /tmp/get-docker.sh
else
  echo "[1/4] 检测到 Docker: $(docker --version)"
fi

if ! docker info >/dev/null 2>&1; then
  echo "正在启动 dockerd..."
  systemctl enable --now docker 2>/dev/null || service docker start 2>/dev/null || {
    echo "❌ Docker daemon 启动失败，请手动检查" >&2
    exit 1
  }
fi

# ---- 2. 已有容器则复用（链接不变）----
if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -qx "$CONTAINER_NAME"; then
  if ! docker ps --format '{{.Names}}' 2>/dev/null | grep -qx "$CONTAINER_NAME"; then
    echo "[2/4] 发现已停止的容器，正在启动..."
    docker start "$CONTAINER_NAME" >/dev/null
    sleep 3
  else
    echo "[2/4] 容器已在运行，复用现有配置（链接不变）"
  fi
  echo ""
  docker exec "$CONTAINER_NAME" cat /etc/xray/xray-info.txt 2>/dev/null || docker logs --tail 30 "$CONTAINER_NAME"
  exit 0
fi

# ---- 3. 下载构建文件并构建镜像 ----
echo "[3/4] 构建 Xray 镜像（版本: $XRAY_VERSION）..."
BUILD_DIR="$(mktemp -d)"
trap 'rm -rf "$BUILD_DIR"' EXIT
mkdir -p "$BUILD_DIR/docker"
curl -fsSL "$RAW/docker/Dockerfile.xray" -o "$BUILD_DIR/docker/Dockerfile.xray"
curl -fsSL "$RAW/docker/entrypoint-xray.sh" -o "$BUILD_DIR/docker/entrypoint-xray.sh"
docker build -f "$BUILD_DIR/docker/Dockerfile.xray" \
  --build-arg "XRAY_VERSION=$XRAY_VERSION" \
  -t "$IMAGE_NAME" "$BUILD_DIR"

# ---- 4. 启动容器 ----
echo "[4/4] 启动容器（宿主机端口: $HOST_PORT，伪装: $REALITY_DEST）..."
docker volume create "$VOLUME_NAME" >/dev/null
docker run -d \
  --name "$CONTAINER_NAME" \
  --restart unless-stopped \
  -p "${HOST_PORT}:443" \
  -e "XRAY_PORT=443" \
  -e "PUBLIC_PORT=${HOST_PORT}" \
  -e "UUID=${UUID}" \
  -e "PRIVATE_KEY=${PRIVATE_KEY}" \
  -e "PUBLIC_KEY=${PUBLIC_KEY}" \
  -e "SHORT_ID=${SHORT_ID}" \
  -e "SERVER_IP=${SERVER_IP}" \
  -e "REALITY_DEST=${REALITY_DEST}" \
  -e "REALITY_SNI=${REALITY_SNI}" \
  -e "REUSE_CONFIG=${REUSE_CONFIG}" \
  -v "${VOLUME_NAME}:/etc/xray" \
  "$IMAGE_NAME" >/dev/null

# 放行防火墙（best-effort）
if command -v ufw >/dev/null 2>&1 && ufw status 2>/dev/null | grep -q "active"; then
  ufw allow "${HOST_PORT}/tcp" >/dev/null 2>&1 || true
elif command -v firewall-cmd >/dev/null 2>&1 && systemctl is-active --quiet firewalld 2>/dev/null; then
  firewall-cmd --permanent --add-port="${HOST_PORT}/tcp" >/dev/null 2>&1 || true
  firewall-cmd --reload >/dev/null 2>&1 || true
fi

sleep 4
if ! docker ps --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
  echo "❌ 容器启动失败，日志如下：" >&2
  docker logs --tail 30 "$CONTAINER_NAME" >&2 || true
  exit 1
fi

echo ""
echo "================================"
echo "✅ Xray 安装成功（Docker）！"
echo "================================"
echo ""
docker exec "$CONTAINER_NAME" cat /etc/xray/xray-info.txt 2>/dev/null || docker logs --tail 30 "$CONTAINER_NAME"
echo ""
echo "⚠️  云服务商安全组需放行 ${HOST_PORT}/TCP，否则客户端连不上"
echo ""
echo "容器管理命令:"
echo "- 查看链接: docker exec $CONTAINER_NAME cat /etc/xray/xray-info.txt"
echo "- 查看日志: docker logs -f $CONTAINER_NAME"
echo "- 重启服务: docker restart $CONTAINER_NAME"
echo "- 重新生成配置（链接会变）: docker rm -f $CONTAINER_NAME && REUSE_CONFIG=false sudo bash $0"
