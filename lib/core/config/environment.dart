class Env {
  static const String dev = 'https://crew-api-u8vu.onrender.com/api';
  static const String prod = 'https://your-prod-api.com/api';
  
  static String current = dev;
  
  static void setProduction() => current = prod;
  static void setDevelopment() => current = dev;
  static bool get isProduction => current == prod;
}


// 目前还在使用测试的api，没有主服务器