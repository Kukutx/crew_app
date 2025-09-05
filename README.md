# crew_app


# lib 目录结构

```text
lib/
├── app/                  # 应用入口与全局配置
│   ├── main.dart         # 应用入口
│   ├── bootstrap.dart    # 初始化（runZonedGuarded、依赖注入、Firebase）
│   ├── router/           # go_router 路由与守卫
│   ├── theme/            # ThemeData、colors、text styles
│   ├── localization/     # AppLocalizations（gen-l10n）
│   └── di/               # 全局 Provider / Riverpod 配置
│
├── core/                 # 跨 feature 的底层能力（无业务逻辑）
│   ├── config/           # 环境变量、常量、app info
│   ├── error/            # AppException、Failure、error mapper
│   ├── network/          # Dio/http 客户端、拦截器、API 常量
│   ├── storage/          # SharedPreferences/Hive/secure storage
│   ├── firebase/         # firebase_options、analytics、crashlytics
│   └── utils/            # 纯函数工具（时间、格式化等）
│
├── shared/               # 可复用 UI 和基础包裹
│   ├── widgets/          # Button、AppScaffold 等组件
│   ├── extensions/       # Dart 扩展方法
│   └── mixins/           # 可复用 mixin
│
├── features/             # 业务功能模块（按功能域划分）
│   ├── home/
│   │   ├── data/         # 数据实现层（DTO、datasource、repo impl）
│   │   ├── domain/       # 实体、值对象、仓库接口、UseCases
│   │   └── presentation/ # UI、ViewModel/Controller、widgets
│   │
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── profile/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── [other_feature]/  # 其他功能模块
│
├── l10n/                 # 国际化/多语言
│   ├── generated/        # flutter gen-l10n 自动生成文件
│   └── cn.arb            # 翻译源文件（app_en.arb, app_zh.arb）
│
└── playground/           # 实验区（不打包正式版）
    ├── new_ui/           # 测试新 UI 组件
    ├── test_package/     # 测试第三方包
    └── ideas/            # 各类实验想法与代码

```

