# CloudBase 部署指南

## 部署架构

```
┌─────────────────────────────────────────────────────────────┐
│                    用户浏览器                                │
└─────────────────────────────────────────────────────────────┘
                          │
                          ├──────────────────────────────┐
                          │                              │
                          ▼                              ▼
        ┌─────────────────────────────┐  ┌─────────────────────────────┐
        │  CloudBase 静态托管          │  │  CloudBase Run (容器模式)    │
        │  - Vue3 前端静态文件          │  │  - Spring Boot 后端 :80     │
        │  - CDN 加速                  │  │  - 4核8GB 内存              │
        └─────────────────────────────┘  └─────────────────────────────┘
                                                   │
                                                   │
                                    ┌──────────────┴──────────────┐
                                    │                              │
                                    ▼                              ▼
                      ┌────────────────────────┐    ┌────────────────────────┐
                      │  MySQL 数据库           │    │  Redis (可选)          │
                      │  - CloudBase 内置       │    │  - TencentDB for Redis │
                      │  - VPC 内网连接         │    │  - VPC 内网连接         │
                      └────────────────────────┘    └────────────────────────┘
```

## 部署步骤

### 第一步：数据库初始化

请参考 `DATABASE_INIT.md` 文档完成 MySQL 数据库初始化。

### 第二步：后端部署

#### 2.1 准备工作

1. **确认 CloudBase 环境信息**
   - 环境ID: `alita-project-3gv99dp60976669b`
   - 区域: `ap-shanghai`

2. **获取 MySQL 连接信息**
   - 访问 CloudBase 控制台 MySQL 页面
   - 记录连接地址、端口、用户名、密码

#### 2.2 通过 CloudBase Run 部署

**方式 1：使用 CloudBase CLI（推荐）**

```bash
# 1. 安装 CloudBase CLI
npm install -g @cloudbase/cli

# 2. 登录
tcb login

# 3. 部署后端服务
cd backend
tcb fn deploy yudao-server --runtime-type Image --runtime-options '{"dockerfile": "Dockerfile"}'
```

**方式 2：通过控制台手动部署**

1. 访问 CloudBase Run 控制台
   ```
   https://tcb.cloud.tencent.com/dev?envId=alita-project-3gv99dp60976669b#/platform-run
   ```

2. 创建新服务
   - 服务名称: `yudao-server`
   - 访问类型: 公网访问
   - 镜像来源: 本地代码库
   - 上传方式: 上传文件夹（选择 `backend` 目录）

3. 配置环境变量
   ```
   MYSQL_URL=jdbc:mysql://<MySQL内网地址>:3306/alita-project-3gv99dp60976669b?useSSL=false&serverTimezone=Asia/Shanghai&allowPublicKeyRetrieval=true&nullCatalogMeansCurrent=true&rewriteBatchedStatements=true
   MYSQL_USERNAME=<MySQL用户名>
   MYSQL_PASSWORD=<MySQL密码>
   SPRING_PROFILES_ACTIVE=cloud
   ```

4. 配置资源规格
   - CPU: 4 核
   - 内存: 8 GB
   - 最小实例数: 1（避免冷启动）
   - 最大实例数: 5

5. 点击"部署"按钮

#### 2.3 验证后端部署

1. 获取后端服务访问地址
   - 在 CloudBase Run 服务列表中查看"访问路径"
   - 格式: `https://<service-id>.ap-shanghai.run.tcloudbase.com`

2. 测试健康检查
   ```bash
   curl https://<service-id>.ap-shanghai.run.tcloudbase.com/actuator/health
   ```

3. 测试 API 文档
   ```
   https://<service-id>.ap-shanghai.run.tcloudbase.com/swagger-ui
   ```

### 第三步：前端部署

#### 3.1 修改前端配置

1. 编辑 `frontend/.env.prod` 文件
   ```bash
   # 后端 API 地址
   VITE_BASE_URL=https://<service-id>.ap-shanghai.run.tcloudbase.com
   
   # 其他配置
   VITE_APP_TITLE=芋道管理系统
   ```

2. 安装依赖并构建
   ```bash
   cd frontend
   pnpm install
   pnpm build
   ```

#### 3.2 部署到 CloudBase 静态托管

**方式 1：使用 CloudBase CLI**

```bash
# 部署前端静态文件
tcb hosting deploy ./dist --envId alita-project-3gv99dp60976669b
```

**方式 2：通过控制台上传**

1. 访问 CloudBase 静态网站托管控制台
   ```
   https://tcb.cloud.tencent.com/dev?envId=alita-project-3gv99dp60976669b#/static-hosting
   ```

2. 上传 `frontend/dist` 目录下的所有文件

#### 3.3 获取前端访问地址

前端部署完成后，可以通过以下地址访问：
```
https://alita-project-3gv99dp60976669b-1259785529.tcloudbaseapp.com
```

### 第四步：端到端验证

1. **访问前端页面**
   ```
   https://alita-project-3gv99dp60976669b-1259785529.tcloudbaseapp.com
   ```

2. **登录系统**
   - 默认账号: `admin`
   - 默认密码: `admin123`

3. **验证核心功能**
   - 系统管理 -> 用户管理
   - 系统管理 -> 角色管理
   - 系统管理 -> 菜单管理

## 常见问题

### 1. 后端启动失败

**可能原因:**
- MySQL 连接信息配置错误
- 数据库未初始化
- 端口冲突（确保监听 PORT 环境变量）

**解决方法:**
```bash
# 查看后端日志
tcb fn log yudao-server

# 或在控制台查看日志
https://tcb.cloud.tencent.com/dev?envId=alita-project-3gv99dp60976669b#/devops/log
```

### 2. 前端无法访问后端 API

**可能原因:**
- CORS 跨域问题
- 后端服务未启动
- API 地址配置错误

**解决方法:**
- 检查浏览器控制台的错误信息
- 确认后端服务正常运行
- 检查 `.env.prod` 中的 `VITE_BASE_URL` 配置

### 3. 数据库连接失败

**可能原因:**
- MySQL 连接地址错误
- 用户名密码错误
- 数据库未开通

**解决方法:**
- 在 CloudBase 控制台确认 MySQL 已开通
- 检查环境变量中的连接信息
- 测试 MySQL 连接

## 成本估算

### CloudBase 个人版

- **MySQL 数据库**: 约 ¥0.05/小时
- **CloudBase Run (4核8GB)**: 约 ¥0.3/小时
- **静态托管**: 约 ¥0.01/GB/天
- **CDN 流量**: 约 ¥0.2/GB

**月度估算（最小实例数=1，24小时运行）:**
- MySQL: ¥36/月
- CloudBase Run: ¥216/月
- 静态托管 + CDN: ¥20/月
- **总计**: 约 ¥272/月

### 优化建议

1. **减少实例运行时间**
   - 开发环境可以设置定时启停
   - 最小实例数设为 0（按量计费，但会有冷启动）

2. **降低配置**
   - 开发环境可以使用 2核4GB 配置
   - 仅在需要性能测试时使用 4核8GB

3. **使用预留实例**
   - 长期运行建议购买预留实例，可节省 30-50% 成本

## 下一步

1. 根据实际需求调整资源配置
2. 配置自定义域名（可选）
3. 开启 HTTPS（CloudBase 默认支持）
4. 配置监控告警
