# 数据库初始化说明

## CloudBase MySQL 数据库信息

- **环境 ID**: `alita-project-3gv99dp60976669b`
- **数据库名**: `alita-project-3gv99dp60976669b`
- **区域**: `ap-shanghai`

## 初始化步骤

### 方案 1：通过 CloudBase 控制台执行（推荐）

1. **访问 CloudBase 控制台**
   ```
   https://tcb.cloud.tencent.com/dev?envId=alita-project-3gv99dp60976669b#/db/mysql/table/default/
   ```

2. **登录 MySQL 数据库**
   - 点击"登录数据库"按钮
   - 使用环境默认账号登录

3. **执行 SQL 脚本**
   
   按以下顺序执行 SQL 文件：
   
   **步骤 1：执行主表结构脚本**
   - 文件位置：`backend/sql/mysql/ruoyi-vue-pro.sql`
   - 复制文件内容并粘贴到 SQL 执行窗口
   - 点击执行
   
   **步骤 2：执行 Quartz 定时任务表脚本**
   - 文件位置：`backend/sql/mysql/quartz.sql`
   - 复制文件内容并粘贴到 SQL 执行窗口
   - 点击执行

### 方案 2：通过命令行工具执行

如果您本地安装了 MySQL 客户端，可以通过以下方式执行：

1. **获取 MySQL 连接信息**
   - 访问 CloudBase 控制台 MySQL 页面
   - 查看连接地址、端口、用户名、密码

2. **执行 SQL 脚本**
   ```bash
   # 执行主表结构脚本
   mysql -h <主机地址> -P <端口> -u <用户名> -p alita-project-3gv99dp60976669b < backend/sql/mysql/ruoyi-vue-pro.sql
   
   # 执行 Quartz 定时任务表脚本
   mysql -h <主机地址> -P <端口> -u <用户名> -p alita-project-3gv99dp60976669b < backend/sql/mysql/quartz.sql
   ```

## 注意事项

1. **SQL 文件大小**
   - `ruoyi-vue-pro.sql`: 约 1MB，包含 80+ 张表的创建和初始数据
   - `quartz.sql`: 约 41KB，包含 Quartz 定时任务相关的表

2. **执行时间**
   - 完整执行可能需要 5-10 分钟
   - 建议在网络良好的环境下执行

3. **错误处理**
   - 如果出现"表已存在"错误，可以忽略（说明表已创建）
   - 如果出现其他错误，请检查 SQL 语法或数据库权限

## 验证初始化结果

执行以下 SQL 查询，确认表是否创建成功：

```sql
-- 查询表数量
SELECT COUNT(*) as table_count 
FROM information_schema.tables 
WHERE table_schema = 'alita-project-3gv99dp60976669b';

-- 查询所有表名
SELECT TABLE_NAME 
FROM information_schema.tables 
WHERE table_schema = 'alita-project-3gv99dp60976669b'
ORDER BY TABLE_NAME;
```

预期结果：
- 应该有 80+ 张表
- 核心表包括：`system_user`, `system_role`, `system_menu`, `infra_config` 等

## 下一步

数据库初始化完成后，继续执行后端部署配置。
