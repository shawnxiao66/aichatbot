# Supabase 用户关联配置说明

## 概述

现在用户创建的角色和聊天记录已经可以关联到用户自己了。需要在 Supabase 中执行以下操作来支持这个功能。

## 1. 更新 private_characters 表，添加 user_id 字段

在 Supabase SQL Editor 中执行：

```sql
-- 为 private_characters 表添加 user_id 字段
ALTER TABLE private_characters 
ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES users(id) ON DELETE CASCADE;

-- 创建索引以提高查询性能
CREATE INDEX IF NOT EXISTS idx_private_characters_user_id ON private_characters(user_id);

-- 更新 RLS 策略，允许用户只能看到自己的角色
ALTER TABLE private_characters ENABLE ROW LEVEL SECURITY;

-- 删除旧的公开策略（如果存在）
DROP POLICY IF EXISTS "Allow public read access" ON private_characters;
DROP POLICY IF EXISTS "Allow public insert" ON private_characters;
DROP POLICY IF EXISTS "Allow public write private_characters" ON private_characters;

-- 创建新的 RLS 策略：用户只能看到自己的角色
CREATE POLICY "Users can view own private characters" ON private_characters
  FOR SELECT USING (true); -- 暂时允许所有人查看，后续可以改为 user_id = auth.uid()

-- 用户只能创建自己的角色
CREATE POLICY "Users can insert own private characters" ON private_characters
  FOR INSERT WITH CHECK (true); -- 暂时允许所有人创建，后续可以改为 user_id = auth.uid()

-- 用户只能更新自己的角色
CREATE POLICY "Users can update own private characters" ON private_characters
  FOR UPDATE USING (true); -- 暂时允许所有人更新，后续可以改为 user_id = auth.uid()

-- 用户只能删除自己的角色
CREATE POLICY "Users can delete own private characters" ON private_characters
  FOR DELETE USING (true); -- 暂时允许所有人删除，后续可以改为 user_id = auth.uid()
```

## 2. 创建聊天记录表（可选，用于云端存储）

如果你想将聊天记录也存储到 Supabase（而不仅仅是本地），可以创建以下表：

```sql
-- 创建对话表
CREATE TABLE IF NOT EXISTS conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  character_id UUID, -- 关联的角色ID（如果是精选角色或故事角色）
  story_id UUID, -- 关联的故事ID（如果是故事角色）
  private_character_id UUID, -- 关联的私人角色ID（如果是私人角色）
  conversation_type TEXT NOT NULL CHECK (conversation_type IN ('character', 'story', 'private_character')),
  name TEXT NOT NULL, -- 对话名称（角色名称）
  avatar TEXT, -- 角色头像URL
  background_image TEXT, -- 背景图片URL
  chat_description TEXT, -- 角色介绍
  greeting_message TEXT, -- 招呼语
  last_message TEXT, -- 最后一条消息
  last_message_time TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建索引
CREATE INDEX idx_conversations_user_id ON conversations(user_id);
CREATE INDEX idx_conversations_last_message_time ON conversations(last_message_time DESC);

-- 启用 RLS
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;

-- RLS 策略：用户只能看到自己的对话
CREATE POLICY "Users can view own conversations" ON conversations
  FOR SELECT USING (true); -- 暂时允许所有人查看，后续可以改为 user_id = auth.uid()

-- 用户只能创建自己的对话
CREATE POLICY "Users can insert own conversations" ON conversations
  FOR INSERT WITH CHECK (true); -- 暂时允许所有人创建，后续可以改为 user_id = auth.uid()

-- 用户只能更新自己的对话
CREATE POLICY "Users can update own conversations" ON conversations
  FOR UPDATE USING (true); -- 暂时允许所有人更新，后续可以改为 user_id = auth.uid()

-- 用户只能删除自己的对话
CREATE POLICY "Users can delete own conversations" ON conversations
  FOR DELETE USING (true); -- 暂时允许所有人删除，后续可以改为 user_id = auth.uid()
```

```sql
-- 创建聊天消息表
CREATE TABLE IF NOT EXISTS chat_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('user', 'assistant')),
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建索引
CREATE INDEX idx_chat_messages_conversation_id ON chat_messages(conversation_id);
CREATE INDEX idx_chat_messages_user_id ON chat_messages(user_id);
CREATE INDEX idx_chat_messages_created_at ON chat_messages(created_at);

-- 启用 RLS
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

-- RLS 策略：用户只能看到自己对话的消息
CREATE POLICY "Users can view own messages" ON chat_messages
  FOR SELECT USING (true); -- 暂时允许所有人查看，后续可以改为 user_id = auth.uid()

-- 用户只能创建自己的消息
CREATE POLICY "Users can insert own messages" ON chat_messages
  FOR INSERT WITH CHECK (true); -- 暂时允许所有人创建，后续可以改为 user_id = auth.uid()
```

## 3. 更新现有数据（如果有）

如果你已经有 private_characters 数据，需要为它们分配 user_id：

```sql
-- 注意：这只是一个示例，你需要根据实际情况修改
-- 假设你想将所有现有角色分配给第一个用户
UPDATE private_characters 
SET user_id = (SELECT id FROM users LIMIT 1)
WHERE user_id IS NULL;
```

## 4. 注意事项

1. **当前实现**：
   - 用户创建的角色会关联到 `user_id`
   - 聊天记录存储在本地（UserDefaults），按用户ID区分
   - 每个用户的对话列表是独立的

2. **后续优化**（如果使用 Supabase Auth）：
   - 将 RLS 策略中的 `true` 改为 `user_id = auth.uid()`
   - 这样用户只能看到和操作自己的数据

3. **数据迁移**：
   - 如果之前已经有数据，需要手动分配 `user_id`
   - 建议在应用启动时检查并处理未关联的数据

## 5. 验证

执行完 SQL 后，可以验证：

```sql
-- 查看 private_characters 表结构
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'private_characters';

-- 查看是否有 user_id 字段
SELECT * FROM private_characters LIMIT 1;
```

完成以上操作后，用户创建的角色和聊天记录就会正确关联到用户自己了！


