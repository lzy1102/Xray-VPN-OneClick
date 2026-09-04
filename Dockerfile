# xray-manager 管理工具镜像
# 构建: docker build -t xray-manager .
# 运行 TUI: docker run -it --rm -v xray-config:/usr/local/etc/xray xray-manager
# 构建产物为 ESM(module)，需保留 package.json（cli.mjs 按相对路径读取 version）

FROM node:20-slim AS builder

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY tsconfig.json esbuild.config.mjs ./
COPY src ./src
RUN npm run build

FROM node:20-slim AS runtime

ENV NODE_ENV=production

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev && npm cache clean --force
COPY --from=builder /app/dist ./dist

# 与宿主机安装路径保持一致，方便 -v 挂载复用 /usr/local/etc/xray/config.json
VOLUME ["/usr/local/etc/xray", "/var/log/xray", "/root/.xray-manager"]

ENTRYPOINT ["node", "dist/cli.mjs"]
CMD ["--help"]
