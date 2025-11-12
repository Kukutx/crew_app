/// 环境配置
/// 
/// 使用方式: flutter run --dart-define=ENV=dev
/// 或在 IDE 运行配置中添加: --dart-define=ENV=dev
class Env {
  static const String dev = 'https://crew-api-dev.onrender.com/api/v1/';
  static const String stage = dev;
  static const String prod = 'https://crew-api-u8vu.onrender.com/api/';

  /// 获取当前环境的 API 基础 URL
  static String get current {
    const env = String.fromEnvironment('ENV', defaultValue: 'prod');
    return switch (env) {
      'dev' => dev,
      'stage' => stage,
      _ => prod,
    };
  }

  static bool get isProduction => current == prod;
  static bool get isDevelopment => current == dev;
  static bool get isStage => current == stage;
}

