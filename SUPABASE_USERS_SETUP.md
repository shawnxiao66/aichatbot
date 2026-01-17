# Supabase 用户表设置说明

本文档说明如何在 Supabase 中创建用户表，以支持用户注册功能。

## 1. 创建用户表 (users)

在 Supabase SQL Editor 中执行以下 SQL 语句：

```sql
-- 创建用户表
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  username TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  age INTEGER NOT NULL,
  gender TEXT NOT NULL CHECK (gender IN ('male', 'female')),
  avatar TEXT,
  level INTEGER DEFAULT 1,
  diamonds INTEGER DEFAULT 30,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建索引
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
```

## 2. 配置 Row Level Security (RLS)

为了允许用户注册和读取自己的数据，需要设置 RLS 策略：

```sql
-- 启用 RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- 允许所有人插入（注册）
CREATE POLICY "Allow public insert" ON users
  FOR INSERT
  WITH CHECK (true);

-- 允许用户读取自己的数据
CREATE POLICY "Allow users to read own data" ON users
  FOR SELECT
  USING (true);

-- 允许用户更新自己的数据
CREATE POLICY "Allow users to update own data" ON users
  FOR UPDATE
  USING (true);
```

## 3. 可选：添加触发器自动更新 updated_at

```sql
-- 创建更新 updated_at 的函数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 为 users 表创建触发器
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

## 4. 验证表结构

执行以下查询验证表是否创建成功：

```sql
-- 查看表结构
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'users'
ORDER BY ordinal_position;

-- 查看 RLS 策略
SELECT * FROM pg_policies WHERE tablename = 'users';
```

## 5. 测试插入用户

可以执行以下 SQL 测试插入功能：

```sql
-- 测试插入用户（注意：实际应用中应该通过应用代码插入）
INSERT INTO users (username, email, age, gender, level, diamonds)
VALUES ('测试用户', 'test@example.com', 25, 'male', 1, 30);

-- 查询插入的用户
SELECT * FROM users WHERE email = 'test@example.com';
```

## 注意事项

1. **邮箱唯一性**：`email` 字段设置了 `UNIQUE` 约束，确保每个邮箱只能注册一次。
2. **RLS 策略**：当前策略允许所有人读取用户数据。如果需要在生产环境中限制访问，可以修改策略为：
   ```sql
   -- 只允许用户读取自己的数据
   CREATE POLICY "Allow users to read own data" ON users
     FOR SELECT
     USING (auth.uid()::text = id::text);
   ```
   注意：这需要 Supabase Auth 集成，当前实现使用的是自定义用户表。

3. **密码存储**：当前实现中，密码验证是在客户端模拟的。在生产环境中，应该：
   - 使用 Supabase Auth 进行身份验证
   - 或者使用加密的密码哈希存储在数据库中
   - 不要在数据库中存储明文密码

4. **数据同步**：应用会在注册时自动将用户数据同步到 Supabase。如果 Supabase 创建失败，应用仍会允许本地登录（用于开发/测试）。

## 数据迁移（已有 users 表）

如果你已经创建过 `users` 表，请执行：

```sql
ALTER TABLE users ADD COLUMN IF NOT EXISTS diamonds INTEGER DEFAULT 30;
```

## 完成后的操作

1. 在 Supabase Dashboard 中确认 `users` 表已创建
2. 确认 RLS 策略已正确设置
3. 测试应用中的注册功能，确认用户数据已保存到 Supabase

