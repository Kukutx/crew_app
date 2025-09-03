# crew_app


[your_project_name]/
├── 📁 android/                 # Android 平台特定代码
├── 📁 ios/                     # iOS 平台特定代码
├── 📁 web/                     # Web 平台特定代码
├── 📁 lib/                     # 核心 Dart 代码目录
│   ├── 📁 app/                 # 应用启动与根配置
│   │   ├── main.dart           # 应用入口文件
│   │   ├── bootstrap.dart      # 应用初始化（环境、错误处理、全局依赖）
│   │   └── app.dart            # 根组件，集成路由、主题、全局状态
│   │
│   ├── 📁 core/                # 核心能力封装，与业务无关
│   │   ├── 📁 config/          # 环境配置（开发、生产、测试环境变量）
│   │   ├── 📁 router/          # 路由系统（路由列表、跳转方法、路由守卫）
│   │   ├── 📁 network/         # 网络请求（Dio 实例、拦截器、API 常量、错误处理）
│   │   ├── 📁 storage/         # 本地存储（SharedPreferences/Hive 封装类）
│   │   ├── 📁 state/           # 全局状态管理（AppState等全局Provider/Bloc）
│   │   └── 📁 log/             # 日志系统（debugPrint、上报、性能监控）
│   │
│   ├── 📁 common/              # 通用工具与组件，可跨项目复用
│   │   ├── 📁 widgets/         # 通用组件库（AppButton、LoadingDialog、EmptyView）
│   │   ├── 📁 utils/           # 工具类（formatDate、debounce、screen_util）
│   │   └── 📁 themes/          # 主题与样式（colors.dart、text_styles.dart、app_theme.dart）
│   │
│   ├── 📁 features/            # 业务功能模块（按功能划分，高内聚低耦合）
│   │   ├── 📁 home/            # 首页模块
│   │   │   ├── 📁 models/      # 模块数据模型（HomeItem、BannerModel）
│   │   │   ├── 📁 providers/   # 模块状态管理（HomeProvider、HomeBloc）
│   │   │   ├── 📁 pages/       # 页面（HomePage、HomeDetailPage）
│   │   │   ├── 📁 widgets/     # 模块专用组件（HomeHeader、ProductGrid）
│   │   │   └── home_page.dart  # 模块主页面出口文件
│   │   │
│   │   ├── 📁 login/           # 登录模块
│   │   │   ├── models/         # (LoginRequest、LoginResponse)
│   │   │   ├── providers/      # (LoginProvider、AuthBloc)
│   │   │   ├── pages/          # (LoginPage、ForgotPasswordPage)
│   │   │   ├── widgets/        # (LoginForm、OAuthButtons)
│   │   │   └── login_page.dart
│   │   │
│   │   ├── 📁 settings/        # 设置模块
│   │   │   ├── models/         # (UserProfile、AppSettings)
│   │   │   ├── providers/      # (SettingsProvider)
│   │   │   ├── pages/          # (SettingsPage、AboutPage)
│   │   │   ├── widgets/        # (SettingItem、SwitchTile)
│   │   │   └── settings_page.dart
│   │   │
│   │   └── 📁 [other_feature]/ # 其他业务模块...
│   │
│   ├── 📁 l10n/                # 国际化/多语言
│   │   ├── 📁 generated/       # 自动生成的文件（由flutter_localizations生成）
│   │   └── 📄 cn.arb           # 翻译源文件（如：app_en.arb, app_zh.arb）
│   │
│   ├── 📁 playground/          # 🎨 实验区（不打包进正式版，用于测试新想法）
│   │   ├── 📁 new_ui/          # 测试新UI组件
│   │   ├── 📁 test_package/    # 试用第三方包
│   │   └── 📁 ideas/           # 存放各种想法和实验代码
├── 📁 assets/                  # 静态资源（图片、字体、JSON文件）
│   ├── 📁 images/
│   ├── 📁 icons/
│   └── 📁 fonts/
│
├── 📁 test/                    # 单元测试和组件测试
├── pubspec.yaml                # 项目依赖配置文件
└── README.md                   # 项目说明文档











推荐目录（feature-first + 分层）
lib/
├─ app/                    # App级入口与全局配置
│  ├─ main.dart
│  ├─ bootstrap.dart       # runZonedGuarded、Firebase init、依赖注入
│  ├─ router/              # go_router 路由与guards
│  ├─ theme/               # ThemeData、colors、text
│  ├─ localization/        # AppLocalizations（gen-l10n）
│  └─ di/                  # Provider/riverpod 全局providers
├─ core/                   # 跨feature的底层能力（无业务）
│  ├─ config/              # env、常量、app_info
│  ├─ error/               # AppException、Failure、error mapper
│  ├─ network/             # http/dio、interceptors、api client
│  ├─ storage/             # secure storage、kv、prefs
│  ├─ firebase/            # firebase_options、analytics、crashlytics门面
│  └─ utils/               # 纯函数工具（时间、格式化），尽量无状态
├─ shared/                 # 可复用UI和基础包裹
│  ├─ widgets/             # Button、AppScaffold等原子/分子组件
│  ├─ extensions/          # 扩展方法
│  └─ mixins/
├─ features/               # 以“功能域”划分
│  ├─ events/
│  │  ├─ data/             # 数据实现层（DTO、datasource、repo impl）
│  │  ├─ domain/           # 实体/值对象、仓库接口、用例（UseCases）
│  │  └─ presentation/     # UI、controllers(ViewModel)、states、widgets
│  ├─ auth/
│  └─ profile/
└─ l10n/                   # Flutter gen-l10n 生成资源目录 

