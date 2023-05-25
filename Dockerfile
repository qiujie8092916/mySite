# /mySite/Dockerfile

# 构建阶段
# 使用 stefanwin/node-alpine-pnpm 作为基础镜像，包含 pnpm 的精简版 Node 镜像
FROM stefanwin/node-alpine-pnpm AS Builder

# 设置工作目录
WORKDIR /usr/src/app

# 将项目所有文件拷贝到工作目录
COPY . .

# 安装依赖
RUN pnpm install

# 执行构建
RUN pnpm build

# 部署阶段
# 使用 nginx:1.21.6-alpine 作为基础镜像
FROM nginx:1.21.6-alpine as Deploy

# 调整时区
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN echo 'Asia/Shanghai' > /etc/timezone

# 设置工作目录
WORKDIR /usr/share/nginx/html

# 将构建阶段的构建产物拷贝到工作目录
COPY --from=Builder /usr/src/app/dist .
# 将项目目录下的 ng 配置拷贝到镜像里
COPY --from=Builder /usr/src/app/default.conf /etc/nginx/nginx.conf

# 默认使用 8080 端口
EXPOSE 8080