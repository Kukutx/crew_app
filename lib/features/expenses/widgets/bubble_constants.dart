/// 泡泡组件常量
class BubbleConstants {
  BubbleConstants._();

  /// 默认成员泡泡直径
  static const double defaultBubbleDiameter = 200.0;

  /// 默认费用泡泡直径
  static const double defaultExpenseBubbleDiameter = 56.0;

  /// 费用泡泡轨道内边距
  static const double expenseOrbitPadding = 48.0;

  /// 最小缩放比例
  static const double minScale = 0.6;

  /// 最大缩放比例
  static const double maxScale = 1.6;

  /// 缩放填充比例（当集群比视图小时）
  static const double scaleFillRatio = 0.95;

  /// 费用泡泡大小比例范围
  static const double minExpenseSizeRatio = 0.8;
  static const double maxExpenseSizeRatio = 1.2;
  
  /// 最大费用泡泡大小比例（用于计算边界）
  static const double maxExpenseSizeRatioForBounds = 1.2;

  /// 泡泡大小计算：根据人数确定的最小值和最大值比例
  static const Map<int, ({double min, double max})> bubbleSizeRatios = {
    1: (min: 1.0, max: 1.0),
    2: (min: 0.65, max: 1.50),
    3: (min: 0.72, max: 1.40),
    4: (min: 0.78, max: 1.32),
    5: (min: 0.82, max: 1.26),
    6: (min: 0.85, max: 1.20),
    7: (min: 0.87, max: 1.15),
  };

  /// 默认泡泡大小比例（8人及以上）
  static const ({double min, double max}) defaultBubbleSizeRatio = (
    min: 0.88,
    max: 1.12,
  );

  /// 位置计算：基础半径倍数
  static const double baseRadiusMultiplier = 0.95;

  /// 位置计算：根据人数的半径倍数
  static const Map<int, double> radiusMultipliers = {
    1: 0.0,
    2: 0.7,
    3: 0.85,
    4: 0.95,
    5: 1.05,
    6: 1.2,
    7: 1.35,
  };

  /// 默认半径倍数（8人及以上）
  static const double defaultRadiusMultiplier = 1.4;

  /// 内圈半径倍数
  static const double innerRadiusMultiplier = 0.6;

  /// 安全边距（用于计算集群尺寸）
  static double get safetyMargin => defaultExpenseBubbleDiameter;

  /// 最小画布尺寸倍数
  static const double minCanvasSizeMultiplier = 1.5;
  static const double minCanvasViewMultiplier = 2.0;
}

