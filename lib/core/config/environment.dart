class Env {
  static const String dev = 'https://crew-api-dev.onrender.com/api/v1/';
  static const String stage = dev;
  static const String prod = 'https://crew-api-u8vu.onrender.com/api/';

  static String current = prod;

  static void setProduction() => current = prod;
  static void setDevelopment() => current = dev;
  static void setStage() => current = stage;
  static bool get isProduction => current == prod;
  static bool get isDevelopment => current == dev;
  static bool get isStage => current == stage;
}

  // 目前仍使用测试 API，尚无主服务器

