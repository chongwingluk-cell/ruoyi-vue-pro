# ============================================
# ruoyi-vue-pro 多阶段构建 Dockerfile
# 适配 CloudBase Run 云托管
# ============================================

# 第一阶段：Maven 构建
FROM maven:3.8-openjdk-8-slim AS builder
WORKDIR /app

# 先复制 pom.xml 利用 Docker 缓存加速依赖下载
COPY pom.xml .
COPY yudao-dependencies/pom.xml yudao-dependencies/
COPY yudao-framework/pom.xml yudao-framework/
COPY yudao-module-system/pom.xml yudao-module-system/
COPY yudao-module-member/pom.xml yudao-module-member/
COPY yudao-module-infra/pom.xml yudao-module-infra/
COPY yudao-module-bpm/pom.xml yudao-module-bpm/
COPY yudao-module-pay/pom.xml yudao-module-pay/
COPY yudao-module-mall/pom.xml yudao-module-mall/
COPY yudao-module-erp/pom.xml yudao-module-erp/
COPY yudao-module-crm/pom.xml yudao-module-crm/
COPY yudao-module-ai/pom.xml yudao-module-ai/
COPY yudao-module-mp/pom.xml yudao-module-mp/
COPY yudao-module-report/pom.xml yudao-module-report/
COPY yudao-module-iot/pom.xml yudao-module-iot/
COPY yudao-server/pom.xml yudao-server/

# 下载依赖（利用缓存）
RUN mvn dependency:go-offline -B || true

# 复制源代码
COPY . .

# 编译打包（跳过测试）
RUN mvn clean package -DskipTests -pl yudao-server -am

# 第二阶段：运行
FROM eclipse-temurin:8-jre-alpine

RUN mkdir -p /yudao-server
WORKDIR /yudao-server

# 从构建阶段复制 JAR 包
COPY --from=builder /app/yudao-server/target/yudao-server.jar app.jar

# 时区配置
ENV TZ=Asia/Shanghai

# JVM 参数
ENV JAVA_OPTS="-Xms512m -Xmx1024m -Djava.security.egd=file:/dev/./urandom"

# 预留启动参数
ENV ARGS=""

# CloudBase Run 要求监听 PORT 环境变量，默认 80
ENV PORT=80

EXPOSE 80

# 启动命令：通过 ARGS 支持外部传参（如数据库连接）
CMD java ${JAVA_OPTS} -Dserver.port=${PORT} -jar app.jar ${ARGS}
