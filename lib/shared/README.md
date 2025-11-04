# Shared 目录说明

本目录包含项目中可共享的通用代码，包括工具类、扩展方法、通用组件等。

## 目录结构

```
shared/
├── extensions/          # 扩展方法
│   └── common_extensions.dart    # 常用类型扩展（String, List, int, Widget）
├── utils/              # 工具类
│   ├── country_helper.dart       # 国家代码相关工具
│   ├── formatted_date.dart       # 日期格式化工具
│   ├── image_url.dart            # 图片 URL 处理工具
│   ├── json_parser_helper.dart   # JSON 解析辅助工具
│   ├── number_format_helper.dart # 数字格式化工具
│   ├── version_helper.dart       # 版本号比较工具
│   └── utils.dart                # 统一导出文件
└── widgets/            # 通用组件
    ├── app_floating_action_button.dart
    ├── app_masonry_grid.dart
    ├── crew_avatar.dart
    ├── qr_scanner/
    ├── scroll_activity_listener.dart
    ├── sheets/
    ├── skeleton/
    └── toggle_tab_bar.dart
```

## 工具类说明

### JsonParserHelper
提供通用的 JSON 到 Dart 类型转换方法。

**功能：**
- `parseString()` - 解析为字符串
- `parseInt()` - 解析为整数
- `parseDouble()` - 解析为浮点数
- `parseBool()` - 解析为布尔值
- `parseDate()` - 解析为日期时间
- `parseStringList()` - 解析为字符串列表
- `asMap()` - 转换为 Map

**使用示例：**
```dart
import 'package:crew_app/shared/utils/json_parser_helper.dart';

final name = JsonParserHelper.parseString(json['name']);
final count = JsonParserHelper.parseInt(json['count']);
final isActive = JsonParserHelper.parseBool(json['isActive']);
```

### CountryHelper
国家代码相关工具。

**功能：**
- `countryCodeToEmoji()` - 将 ISO 3166-1 alpha-2 国家代码转换为国旗 Emoji

**使用示例：**
```dart
import 'package:crew_app/shared/utils/country_helper.dart';

final flag = CountryHelper.countryCodeToEmoji('CN'); // 返回 "🇨🇳"
```

### VersionHelper
版本号比较工具。

**功能：**
- `compareVersions()` - 比较两个版本号
- `requiresUpdate()` - 检查是否需要更新
- `requiresForceUpdate()` - 检查是否需要强制更新

**使用示例：**
```dart
import 'package:crew_app/shared/utils/version_helper.dart';

final needsUpdate = VersionHelper.requiresUpdate('1.0.0', '1.1.0'); // true
```

### FormattedDate
日期格式化工具。

**功能：**
- `format()` - 格式化日期时间
- `relative()` - 相对时间格式化（如 "5 分钟前"）
- `formatDate()` - 日期格式化

**使用示例：**
```dart
import 'package:crew_app/shared/utils/formatted_date.dart';

final formatted = FormattedDate.format(DateTime.now());
final relative = FormattedDate.relative(someDate);
```

### NumberFormatHelper
数字格式化工具，主要用于货币格式化。

**功能：**
- `shortCurrency()` - 短格式货币显示
- `currency` - 标准货币格式化器

**使用示例：**
```dart
import 'package:crew_app/shared/utils/number_format_helper.dart';

final currency = NumberFormatHelper.shortCurrency(1234.56);
```

### image_url.dart
图片 URL 处理工具。

**功能：**
- `sanitizeImageUrl()` - 验证并清理图片 URL

**使用示例：**
```dart
import 'package:crew_app/shared/utils/image_url.dart';

final validUrl = sanitizeImageUrl(rawUrl);
```

## 扩展方法

### common_extensions.dart
包含常用类型的扩展方法。

**String 扩展：**
- `capitalize()` - 首字母大写
- `isNumeric` - 是否为数字
- `noSpace` - 去除所有空格

**List 扩展：**
- `safeGet(int index)` - 安全获取元素
- `joinWith(String separator)` - 转换为字符串，带分隔符

**int 扩展：**
- `isEvenNum` - 是否偶数
- `isOddNum` - 是否奇数
- `seconds` - 转换为 Duration
- `toCompactString()` - 紧凑格式显示（如 1.2k）

**Widget 扩展：**
- `paddingAll(double value)` - 快速添加内边距
- `withBorderRadius(double radius)` - 快速添加圆角
- `onTap(VoidCallback onTap)` - 快速添加点击事件

## 通用组件

### widgets/
包含可在多个功能模块中复用的 UI 组件。

- `crew_avatar.dart` - 头像组件
- `app_floating_action_button.dart` - 浮动操作按钮
- `toggle_tab_bar.dart` - 切换标签栏
- 等等...

## 最佳实践

1. **优先使用 shared 中的工具类**：在开发新功能时，优先检查 shared 目录是否已有可用的工具类。
2. **保持工具类的通用性**：添加到 shared 的工具应该具有良好的通用性，避免包含业务特定逻辑。
3. **统一导入**：可以使用 `utils.dart` 统一导出文件来导入多个工具类。
4. **文档完善**：新增工具类时，请添加清晰的注释和使用示例。

## 迁移指南

如果项目中还有其他分散的工具函数，建议迁移到 shared/utils 目录：

1. 评估工具函数的通用性
2. 确定合适的工具类（或创建新的）
3. 移动代码并更新所有引用
4. 更新导入语句
