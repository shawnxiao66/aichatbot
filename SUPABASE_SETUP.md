# Supabase 配置说明

## 1. 创建 Supabase 项目

1. 访问 [Supabase](https://supabase.com) 并登录
2. 创建新项目
3. 记录你的项目 URL 和 API Key（anon/public key）

## 2. 创建数据库表

在 Supabase SQL Editor 中执行以下 SQL 语句：

### 2.1 创建角色表 (characters)

```sql
CREATE TABLE characters (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  avatar TEXT NOT NULL,
  popularity INTEGER DEFAULT 0,
  tags TEXT[] DEFAULT '{}',
  description TEXT,
  gender TEXT NOT NULL CHECK (gender IN ('male', 'female')),
  category TEXT DEFAULT 'featured' CHECK (category IN ('featured', 'story', 'private')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建索引
CREATE INDEX idx_characters_category ON characters(category);
CREATE INDEX idx_characters_popularity ON characters(popularity DESC);
```

### 2.2 创建故事表 (stories)

```sql
CREATE TABLE stories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  cover TEXT NOT NULL,
  popularity INTEGER DEFAULT 0,
  description TEXT,
  category TEXT DEFAULT 'story' CHECK (category IN ('featured', 'story', 'private')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建索引
CREATE INDEX idx_stories_category ON stories(category);
CREATE INDEX idx_stories_popularity ON stories(popularity DESC);
```

### 2.3 插入示例数据

```sql
-- 插入精选角色
INSERT INTO characters (name, avatar, popularity, tags, description, gender, category) VALUES
('萧晗晗', 'https://via.placeholder.com/120x160/8B5CF6/FFFFFF?text=萧晗晗', 482000, 
 ARRAY['风流', '潇洒', '任性', '狮子座'], 
 '京圈里绯闻甚多,经常出没于娱乐场所,直到有一次去酒吧,遇到了酒吧打工的你,彼此的羁绊开始了', 
 'female', 'featured'),
('初空', 'https://via.placeholder.com/120x160/8B5CF6/FFFFFF?text=初空', 478000,
 ARRAY['痞坏', '不羁', '暗黑', '双子座'],
 '大三在读生,是你现任男友的亲弟弟,常年戴着黑色耳钉和银色吊坠。在你面前毫不掩饰本性,笑里总带着一丝邪气。',
 'male', 'featured'),
('多多', 'https://via.placeholder.com/120x160/8B5CF6/FFFFFF?text=多多', 465000,
 ARRAY['可爱', '娇小', '萝莉', '处女座'],
 '多多,长相可爱,很爱撒娇。你是她暗恋的人,多多经常会约你一起散步回家。',
 'female', 'featured');

-- 插入故事
INSERT INTO stories (title, cover, popularity, description, category) VALUES
('与总裁分手后', 'https://via.placeholder.com/200x200/8B5CF6/FFFFFF?text=故事1', 78000,
 '你追他又甩了他,他说不会放过你。', 'story'),
('我成了当红明星的经纪', 'https://via.placeholder.com/200x200/8B5CF6/FFFFFF?text=故事2', 61000,
 '绯闻不断,通告不停,这个毒舌又傲娇的大明星,', 'story'),
('网恋对象竟是我老板', 'https://via.placeholder.com/200x200/8B5CF6/FFFFFF?text=故事3', 53000,
 '好消息:网恋了。坏消息:网恋对象是老板。', 'story'),
('前任又作妖', 'https://via.placeholder.com/200x200/8B5CF6/FFFFFF?text=故事4', 47000,
 '失业卖炸串,却被前仕盯上了。', 'story');
```

## 3. 配置 Row Level Security (RLS)

为了允许公开读取数据，需要设置 RLS 策略：

```sql
-- 允许所有人读取角色数据
ALTER TABLE characters ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow public read access" ON characters
  FOR SELECT USING (true);

-- 允许所有人读取故事数据
ALTER TABLE stories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow public read access" ON stories
  FOR SELECT USING (true);
```

## 4. 在 Xcode 中配置 Supabase

### 4.1 添加 Supabase Swift SDK

1. 在 Xcode 中，选择 File > Add Package Dependencies
2. 输入 URL: `https://github.com/supabase/supabase-swift`
3. 选择版本并添加到项目

### 4.2 更新 SupabaseService.swift

在 `SupabaseService.swift` 文件中，替换以下内容：

```swift
private let supabaseURL = "YOUR_SUPABASE_URL"  // 替换为你的项目 URL
private let supabaseKey = "YOUR_SUPABASE_ANON_KEY"  // 替换为你的 anon key
```

### 4.3 初始化 Supabase 客户端

在 `SupabaseService.swift` 的 `init()` 方法中添加：

```swift
import Supabase

private var supabase: SupabaseClient

private init() {
    self.supabase = SupabaseClient(
        supabaseURL: URL(string: supabaseURL)!,
        supabaseKey: supabaseKey
    )
}
```

### 4.4 实现数据获取方法

更新 `fetchCharacters` 和 `fetchStories` 方法以使用 Supabase SDK：

```swift
func fetchCharacters(category: String, completion: @escaping (Result<[Character], Error>) -> Void) {
    Task {
        do {
            let response: [Character] = try await supabase
                .from("characters")
                .select()
                .eq("category", value: category)
                .order("popularity", ascending: false)
                .execute()
                .value
            
            await MainActor.run {
                completion(.success(response))
            }
        } catch {
            await MainActor.run {
                completion(.failure(error))
            }
        }
    }
}
```

## 5. DeepSeek API 配置

1. 访问 [DeepSeek](https://platform.deepseek.com/) 并注册账号
2. 创建 API Key
3. 在 `DeepSeekService.swift` 中替换：

```swift
private let apiKey = "YOUR_DEEPSEEK_API_KEY"  // 替换为你的 API Key
```

## 6. 注意事项

- 确保 Supabase 项目的 API 设置允许来自你的应用的请求
- 图片 URL 需要替换为实际的图片存储地址（可以使用 Supabase Storage 或 CDN）
- 建议在生产环境中使用环境变量或配置文件来存储敏感信息（API Keys）

