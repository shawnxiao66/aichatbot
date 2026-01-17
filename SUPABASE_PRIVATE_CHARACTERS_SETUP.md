# Supabase 私人角色表配置说明

## 1. 创建私人角色表

在 Supabase SQL Editor 中执行以下 SQL 语句：

```sql
-- 创建私人角色表
CREATE TABLE private_characters (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  avatar TEXT, -- 可选，背景图片URL
  description TEXT,
  gender TEXT DEFAULT 'female' CHECK (gender IN ('male', 'female')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建索引
CREATE INDEX idx_private_characters_created_at ON private_characters(created_at DESC);
```

## 2. 配置 Row Level Security (RLS)

为了允许公开读取和插入数据，需要设置 RLS 策略：

```sql
-- 启用 RLS
ALTER TABLE private_characters ENABLE ROW LEVEL SECURITY;

-- 允许所有人读取私人角色数据
CREATE POLICY "Allow public read access" ON private_characters
  FOR SELECT USING (true);

-- 允许所有人插入私人角色数据（用于创建角色）
CREATE POLICY "Allow public insert access" ON private_characters
  FOR INSERT WITH CHECK (true);
```

## 3. 可选：未来支持多用户

如果未来需要支持多用户，可以添加 `user_id` 字段并修改 RLS 策略：

```sql
-- 添加用户ID字段（可选，未来扩展用）
ALTER TABLE private_characters 
ADD COLUMN user_id TEXT;

-- 创建用户ID索引
CREATE INDEX idx_private_characters_user_id ON private_characters(user_id);

-- 修改 RLS 策略，让用户只能看到自己的角色
-- 注意：需要先删除旧的策略
DROP POLICY "Allow public read access" ON private_characters;
DROP POLICY "Allow public insert access" ON private_characters;

-- 创建新的策略（需要用户认证）
CREATE POLICY "Users can view their own characters" ON private_characters
  FOR SELECT USING (auth.uid()::text = user_id);

CREATE POLICY "Users can insert their own characters" ON private_characters
  FOR INSERT WITH CHECK (auth.uid()::text = user_id);
```

## 4. 验证表结构

执行以下 SQL 验证表结构：

```sql
-- 查看表结构
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'private_characters'
ORDER BY ordinal_position;

-- 查看 RLS 策略
SELECT * FROM pg_policies WHERE tablename = 'private_characters';
```

## 5. 测试插入数据

可以手动插入一条测试数据：

```sql
INSERT INTO private_characters (name, description, gender) 
VALUES ('测试角色', '这是一个测试角色', 'female');
```

## 注意事项

- `avatar` 字段是可选的，如果用户没有上传图片，该字段为 `NULL`
- `description` 字段用于角色介绍，在对话功能中会用到
- `gender` 字段默认为 'female'，用于对话时的称呼（"和他对话" vs "和她对话"）
- 当前实现是公开的，所有用户可以看到所有私人角色
- 如果需要用户级别的隐私控制，请参考第3步的多用户配置



