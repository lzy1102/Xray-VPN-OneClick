# Xray 服务端一键配置脚本

[![GitHub Stars](https://img.shields.io/github/stars/DanOps-1/Xray-VPN-OneClick?style=flat-square)](https://github.com/DanOps-1/Xray-VPN-OneClick/stargazers)
[![License](https://img.shields.io/github/license/DanOps-1/Xray-VPN-OneClick?style=flat-square)](https://github.com/DanOps-1/Xray-VPN-OneClick/blob/main/LICENSE)
[![Last Commit](https://img.shields.io/github/last-commit/DanOps-1/Xray-VPN-OneClick?style=flat-square)](https://github.com/DanOps-1/Xray-VPN-OneClick/commits/main)
[![Platform](https://img.shields.io/badge/platform-Linux-blue?style=flat-square)](https://github.com/DanOps-1/Xray-VPN-OneClick)

[**中文**](../README.md) | [**English**](README-en.md)

**快速部署 Xray-core VLESS + XTLS-Reality 代理服务器**

本项目提供完全自动化的 Xray 服务端配置脚本和详细教程，支持一键部署，无需手动配置。适合需要搭建私有代理服务器的用户。

---

## ✨ 主要特性

- ✅ **完全自动化** - 一键安装，无需用户输入，5分钟内完成部署
- 🔒 **安全可靠** - 使用最新的 VLESS + XTLS-Reality 协议，难以被检测
- 📱 **全平台支持** - 兼容 Windows、macOS、Linux、Android、iOS 所有主流平台
- 🚀 **性能优化** - 内置 BBR 拥塞控制、TCP Fast Open 等性能优化
- 📚 **详细文档** - 完整的中英文安装、配置和故障排查指南
- 🛠️ **管理工具** - 提供用户管理、服务更新、配置备份等便捷工具
- 🌍 **多语言** - 支持中英文文档和脚本输出
- 🐳 **Docker 支持** - Xray 服务端与管理工具均提供镜像，一键 compose 部署

---

## 🚀 快速开始

### 系统要求

- **操作系统**: Linux（支持 Ubuntu、Debian、CentOS、Kali 等发行版）
- **最低配置**: 512MB 内存、100MB 存储空间
- **推荐配置**: 1GB 内存、1核 CPU、10Mbps 带宽
- **网络要求**: 具有公网 IP 地址

### 一键安装（推荐）

使用以下命令一键安装 Xray 服务端：

```bash
wget https://raw.githubusercontent.com/DanOps-1/Xray-VPN-OneClick/main/scripts/install.sh -O xray-install.sh
sudo bash xray-install.sh
```

或者使用 curl：

```bash
curl -O https://raw.githubusercontent.com/DanOps-1/Xray-VPN-OneClick/main/scripts/install.sh
sudo bash install.sh
```

### 安装过程

安装脚本会自动完成以下步骤：

1. ✅ 检测系统环境并安装依赖
2. ✅ 下载并安装最新版 Xray-core
3. ✅ 自动生成配置参数（UUID、密钥对、Short ID）
4. ✅ 创建优化的服务端配置文件
5. ✅ 配置并启动 systemd 服务
6. ✅ 显示客户端配置信息和分享链接

### 安装完成后

安装完成后，脚本会输出以下信息：

```
================================
✅ Xray 安装成功！
================================

📋 服务器信息：
地址: YOUR_SERVER_IP
端口: 443

🔑 客户端配置：
UUID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
Public Key: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
...

📱 分享链接：
vless://xxxxxxxx@YOUR_IP:443?...
```

**保存好这些信息**，用于客户端配置。

---

## 📱 客户端配置

### 支持的客户端

| 平台 | 推荐客户端 | 下载链接 |
|------|-----------|---------|
| **Windows** | v2rayN | [GitHub Releases](https://github.com/2dust/v2rayN/releases) |
| **macOS** | V2rayU / V2RayXS | [V2rayU](https://github.com/yanue/V2rayU/releases) \| [V2RayXS](https://github.com/tzmax/V2RayXS/releases) |
| **Linux** | v2ray-core / Qv2ray | [v2ray](https://github.com/v2fly/v2ray-core/releases) \| [Qv2ray](https://github.com/Qv2ray/Qv2ray/releases) |
| **Android** | v2rayNG | [GitHub Releases](https://github.com/2dust/v2rayNG/releases) |
| **iOS** | Shadowrocket / Quantumult X | App Store（需美区账号）|

### 快速导入配置

**方式一：使用分享链接（推荐）**

1. 复制安装脚本输出的 VLESS 分享链接
2. 打开客户端应用
3. 选择"从剪贴板导入"或"扫描二维码"
4. 连接并开始使用

**方式二：手动配置**

查看详细教程：[客户端配置指南](client-setup.md)

---

## 🛠️ 服务管理

### 基本命令

```bash
# 查看服务状态
sudo systemctl status xray

# 启动服务
sudo systemctl start xray

# 停止服务
sudo systemctl stop xray

# 重启服务
sudo systemctl restart xray

# 查看实时日志
sudo journalctl -u xray -f

# 查看最近日志
sudo journalctl -u xray -n 100
```

### 用户管理

```bash
# 添加新用户
sudo bash scripts/add-user.sh user@example.com

# 删除用户
sudo bash scripts/del-user.sh user@example.com

# 列出所有用户
sudo bash scripts/show-config.sh users

# 显示用户的分享链接
sudo bash scripts/show-config.sh link user@example.com
```

### 系统维护

```bash
# 更新 Xray 到最新版本
sudo bash scripts/update.sh

# 备份当前配置
sudo bash scripts/backup.sh

# 恢复配置
sudo bash scripts/restore.sh <备份文件>

# 卸载 Xray
sudo bash scripts/uninstall.sh
```

---

## 📖 详细文档

- [完整安装教程](installation-guide.md) - 手动安装的详细步骤说明
- [客户端配置指南](client-setup.md) - 各平台客户端的详细配置方法
- [用户管理指南](user-management.md) - 如何添加、删除和管理多个用户
- [常见问题解答](installation-guide.md#常见问题) - 常见问题的排查和解决方案
- [性能优化指南](installation-guide.md#性能优化) - 提升服务器性能的建议

---

## 🔒 安全建议

### 基本安全措施

1. ✅ **定期更换密钥** - 建议每 3-6 个月更换 UUID 和密钥对
2. ✅ **使用强密码** - 为服务器 SSH 设置强密码或密钥认证
3. ✅ **配置防火墙** - 只开放必要的端口（443）
4. ✅ **定期更新** - 及时更新 Xray 到最新版本修复安全漏洞
5. ✅ **监控日志** - 定期检查日志发现异常访问
6. ✅ **配置备份** - 定期备份配置文件到安全位置

### 进阶安全配置

```bash
# 限制 SSH 访问
sudo ufw allow 22/tcp
sudo ufw allow 443/tcp
sudo ufw enable

# 禁用 root 登录（推荐）
sudo nano /etc/ssh/sshd_config
# 设置: PermitRootLogin no
sudo systemctl restart sshd

# 配置自动安全更新
sudo apt install unattended-upgrades
sudo dpkg-reconfigure --priority=low unattended-upgrades
```

---

## 📊 支持的云平台

本项目已在以下云平台测试通过：

### 国外云平台
- ✅ **AWS EC2** - Amazon Web Services
- ✅ **Google Cloud Platform** - GCP Compute Engine
- ✅ **Microsoft Azure** - Azure Virtual Machines
- ✅ **DigitalOcean** - Droplets
- ✅ **Vultr** - Cloud Compute
- ✅ **Linode** - Akamai Cloud
- ✅ **Hetzner** - Cloud Servers

### 国内云平台
- ✅ **阿里云** - ECS 云服务器
- ✅ **腾讯云** - CVM 云服务器
- ✅ **华为云** - ECS 弹性云服务器

> **注意**: 在国内云平台使用可能面临合规风险，请谨慎选择。

---

## 🐳 Docker 部署

### 一键 Docker 安装（推荐，复制粘贴即可）

```bash
wget https://raw.githubusercontent.com/lzy1102/Xray-VPN-OneClick/main/scripts/docker-install.sh -O xray-docker-install.sh && sudo bash xray-docker-install.sh
```

脚本自动安装 Docker、构建镜像、启动容器并打印分享链接。自定义示例：

```bash
# 换伪装目标 / 端口
REALITY_DEST=www.apple.com:443 HOST_PORT=8443 sudo bash xray-docker-install.sh
# 国内服务器 Docker 安装加速
DOCKER_INSTALL_URL=https://ghproxy.com/https://get.docker.com sudo bash xray-docker-install.sh
```

### 使用 Docker Compose

```bash
git clone https://github.com/lzy1102/Xray-VPN-OneClick.git
cd Xray-VPN-OneClick

# 启动 Xray（首次自动生成 UUID/密钥/ShortID，持久化在 xray-config 卷中）
docker compose up -d xray

# 查看分享链接
docker logs xray-reality
# 或
docker exec xray-reality cat /etc/xray/xray-info.txt
```

自定义配置（端口/伪装目标/固定密钥）：

```bash
cp docker/.env.example .env && vim .env
docker compose up -d xray
```

### 只用 Docker 运行 Xray（免 compose）

```bash
docker build -f docker/Dockerfile.xray -t xray-reality .
docker run -d --name xray-reality -p 443:443 \
  -v xray-config:/etc/xray \
  --restart=unless-stopped \
  xray-reality
docker logs -f xray-reality  # 启动后打印分享链接
```

### 管理工具容器（免装 Node.js）

```bash
# TUI（需 -it；挂载同一配置卷后，用 manager 改完配置要 restart xray 生效）
docker compose --profile tools run --rm -it manager
# 或单容器
docker build -t xray-manager .
docker run -it --rm -v xray-config:/usr/local/etc/xray xray-manager --config /usr/local/etc/xray/config.json
```

> 注意：云服务商安全组需放行映射端口（默认 443/TCP）；宿主机映射端口与容器端口不一致时，把 `.env` 中的 `HOST_PORT` 设成宿主机端口，保证分享链接正确。

---

## 💡 常见问题

### 1. 端口 443 被占用怎么办？

```bash
# 查看占用端口的进程
sudo lsof -i :443

# 停止占用的服务
sudo systemctl stop nginx  # 或其他服务

# 或修改 Xray 配置使用其他端口
sudo nano /usr/local/etc/xray/config.json
```

### 2. 客户端无法连接？

**排查步骤**：

1. 确认服务正在运行：`sudo systemctl status xray`
2. 检查防火墙规则：`sudo ufw status`
3. 确认云服务商安全组已开放 443 端口
4. 检查配置信息是否正确（UUID、公钥等）
5. 查看服务日志：`sudo journalctl -u xray -f`

### 3. 如何更换伪装目标网站？

编辑配置文件 `/usr/local/etc/xray/config.json`：

```json
"dest": "www.cloudflare.com:443",
"serverNames": ["www.cloudflare.com"]
```

推荐使用：`www.microsoft.com`、`www.apple.com`、`www.cloudflare.com`

### 4. 如何提升连接速度？

```bash
# 启用 BBR 拥塞控制
echo "net.core.default_qdisc=fq" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# 启用 TCP Fast Open
echo "net.ipv4.tcp_fastopen=3" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

更多问题查看：[常见问题完整列表](installation-guide.md#常见问题)

---

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request 来改进本项目！

### 贡献流程

1. Fork 本项目到你的账号
2. 创建特性分支：`git checkout -b feature/AmazingFeature`
3. 提交你的更改：`git commit -m 'Add some AmazingFeature'`
4. 推送到分支：`git push origin feature/AmazingFeature`
5. 提交 Pull Request

### 贡献建议

- 📝 改进文档和教程
- 🐛 修复 bug 和问题
- ✨ 添加新功能和工具
- 🌍 翻译文档到其他语言
- 📊 优化脚本性能

---

## 📝 更新日志

### v1.0.0 (2026-01-07)

**首次发布**

- ✅ 完整的 VLESS + XTLS-Reality 配置教程
- ✅ 全自动一键安装脚本
- ✅ 用户管理工具（添加、删除、列表）
- ✅ 服务维护工具（更新、备份、卸载）
- ✅ 详细的中英文文档
- ✅ 多平台客户端配置指南
- ✅ 性能优化和安全加固指南

---

## 📚 参考资源

### 官方文档
- [Xray 官方网站](https://xtls.github.io/)
- [VLESS 协议规范](https://xtls.github.io/config/features/vless.html)
- [Reality 协议介绍](https://github.com/XTLS/REALITY)
- [Xray-core 源代码](https://github.com/XTLS/Xray-core)

### 相关项目
- [v2rayN (Windows 客户端)](https://github.com/2dust/v2rayN)
- [v2rayNG (Android 客户端)](https://github.com/2dust/v2rayNG)
- [V2rayU (macOS 客户端)](https://github.com/yanue/V2rayU)

---

## 📄 许可证

本项目采用 [MIT License](../LICENSE) 开源许可证。

这意味着你可以：
- ✅ 自由使用、复制、修改和分发本项目
- ✅ 用于商业或非商业目的
- ✅ 在遵守许可证的前提下自由修改

但需要：
- ⚠️ 保留原作者的版权声明
- ⚠️ 提供许可证副本

---

## ⚠️ 免责声明

**重要提示**

1. 本项目仅供**学习和研究**使用
2. 使用代理技术需遵守**当地法律法规**
3. 请勿将本项目用于**任何非法用途**
4. 作者不对使用本项目造成的**任何后果**负责
5. 使用者应自行承担**所有法律责任**

在中国大陆，未经授权搭建和使用 VPN 服务可能违反相关法律法规。请在使用前充分了解并遵守当地法律。

---

## 💬 获取帮助

### 如何获取支持

- 📧 **提交 Issue**: [GitHub Issues](https://github.com/DanOps-1/Xray-VPN-OneClick/issues)
- 💡 **常见问题**: 查看 [FAQ 文档](installation-guide.md#常见问题)
- 📖 **阅读文档**: 完整的 [安装和配置教程](installation-guide.md)
- 🔍 **搜索已有问题**: 在提问前先搜索是否有相同问题

### 提交 Issue 的建议

请在 Issue 中提供以下信息：

1. 你的操作系统和版本
2. Xray 版本号
3. 详细的问题描述和错误信息
4. 相关的配置文件（隐藏敏感信息）
5. 你已经尝试过的解决方法

---

**⭐ 如果这个项目对你有帮助，请给一个 Star 支持一下！**

**🔄 也欢迎 Fork 和分享给需要的朋友！**
