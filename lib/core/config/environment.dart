class Env {
  static const String dev = 'https://crew-api-dev.onrender.com/api/v1/';
  static const String stage = dev;
  static const String prod = 'https://crew-api-u8vu.onrender.com/api/';

  /// 从环境变量获取当前环境，默认为生产环境
  /// 使用方式: flutter run --dart-define=ENV=dev
  /// 或在 IDE 运行配置中添加: --dart-define=ENV=dev
  static String get current {
    const env = String.fromEnvironment('ENV', defaultValue: 'prod');
    switch (env) {
      case 'dev':
        return dev;
      case 'stage':
        return stage;
      default:
        return prod;
    }
  }

  static bool get isProduction => current == prod;
  static bool get isDevelopment => current == dev;
  static bool get isStage => current == stage;
}

// 目前仍使用测试 API，尚无主服务器

