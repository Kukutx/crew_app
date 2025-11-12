import 'dart:math' as math;

import 'package:crew_app/features/expenses/data/member.dart';
import 'package:crew_app/shared/utils/number_format_helper.dart';
import 'package:crew_app/shared/widgets/crew_avatar.dart';
import 'package:crew_app/features/expenses/widgets/bubble_constants.dart';
import 'package:flutter/material.dart';

class MemberBubble extends StatefulWidget {
  const MemberBubble({
    super.key,
    required this.member,
    required this.allMembers,
    required this.onTap,
    required this.onExpenseTap,
    this.bubbleDiameter = BubbleConstants.defaultBubbleDiameter,
    this.expenseBubbleDiameter = BubbleConstants.defaultExpenseBubbleDiameter,
    this.expenseAngles,
  });

  final Member member;
  final List<Member> allMembers;
  final VoidCallback onTap;
  final ValueChanged<MemberExpense> onExpenseTap;
  final double bubbleDiameter;
  final double expenseBubbleDiameter;
  final List<double>? expenseAngles;

  static const double defaultBubbleDiameter = BubbleConstants.defaultBubbleDiameter;
  static const double defaultExpenseBubbleDiameter = BubbleConstants.defaultExpenseBubbleDiameter;

  static double outerExtent({
    required double bubbleDiameter,
    required double expenseBubbleDiameter,
  }) {
    final orbitRadius = bubbleDiameter / 2 + BubbleConstants.expenseOrbitPadding;
    return (orbitRadius + expenseBubbleDiameter / 2) * 2;
  }

  @override
  State<MemberBubble> createState() => _MemberBubbleState();
}

class _MemberBubbleState extends State<MemberBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    // 浮动动画 - 让泡泡有轻微的上下浮动效果
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _floatAnimation = Tween<double>(
      begin: -3.0,
      end: 3.0,
    ).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final member = widget.member;
    final bubbleSize = widget.bubbleDiameter;
    final expenses = member.expenses;
    final orbitRadius = bubbleSize / 2 + BubbleConstants.expenseOrbitPadding;
    
    // 计算最大可能的费用泡泡大小（用于计算 stackExtent）
    // 基础费用泡泡大小 × 成员泡泡缩放 × 最大金额比例缩放
    final baseExpenseSize = widget.expenseBubbleDiameter;
    final baseParentSize = BubbleConstants.defaultBubbleDiameter;
    final parentScaleFactor = bubbleSize / baseParentSize;
    final maxExpenseSize = baseExpenseSize * parentScaleFactor * BubbleConstants.maxExpenseSizeRatioForBounds;
    
    final stackExtent = (orbitRadius + maxExpenseSize / 2) * 2;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final expenseBubbleStart = isDark
        ? const Color(0xCC4C5CFF)
        : const Color(0xAA81A4FF);
    final expenseBubbleEnd = isDark
        ? const Color(0x882B2E4F)
        : Colors.white.withValues(alpha: 0.75);
    final expenseBorderColor = isDark
        ? const Color(0x663C3F71)
        : const Color(0x5581A4FF);
    final expenseShadowColor = isDark
        ? const Color(0x332B2E4F)
        : const Color(0x3381A4FF);
    final bubbleShadowColor = isDark
        ? Colors.black.withValues(alpha: 0.4)
        : const Color(0x335B8DEF);
    final primaryContentColor = isDark ? Colors.white : scheme.onPrimary;
    return SizedBox(
        width: stackExtent,
        height: stackExtent,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // 绘制连接线（从费用泡泡到相关成员）
            ..._buildExpenseConnections(
              expenses,
              orbitRadius,
              stackExtent,
              isDark,
            ),
            // 成员泡泡（放在费用泡泡之前，避免遮挡费用泡泡）
            AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatAnimation.value),
                  child: GestureDetector(
                    // 使用 deferToChild 确保只在 Container 的圆形区域内响应点击
                    // 这样不会拦截费用泡泡的点击事件
                    behavior: HitTestBehavior.deferToChild,
                    onTap: () {
                      // 点击时的缩放动画
                      setState(() {
                        _scale = 0.95;
                      });
                      Future.delayed(const Duration(milliseconds: 100), () {
                        if (mounted) {
                          setState(() {
                            _scale = 1.0;
                          });
                        }
                      });
                      widget.onTap();
                    },
                    child: AnimatedScale(
                      scale: _scale,
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeOut,
                      child: Container(
                        width: bubbleSize,
                        height: bubbleSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: _getBubbleGradient(theme, isDark),
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: bubbleShadowColor,
                              blurRadius: isDark ? 30 : 20,
                              offset: const Offset(0, 18),
                            ),
                          ],
                        ),
                        child: Builder(
                          builder: (context) {
                            // 根据泡泡大小计算字体大小和间距（基础大小200px）
                            final baseSize = 200.0;
                            final scaleFactor = bubbleSize / baseSize;
                            
                            // 字体大小按比例缩放
                            final nameFontSize = 16.0 * scaleFactor;
                            final amountFontSize = 20.0 * scaleFactor;
                            final badgeFontSize = 9.0 * scaleFactor;
                            
                            // 间距按比例缩放
                            final padding = 16.0 * scaleFactor;
                            final spacing1 = 10.0 * scaleFactor;
                            final spacing2 = 6.0 * scaleFactor;
                            final spacing3 = 4.0 * scaleFactor;
                            
                            return Padding(
                              padding: EdgeInsets.all(padding),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CrewAvatar(
                                    radius: 32 * scaleFactor,
                                    backgroundColor: Colors.white.withValues(alpha: 0.24),
                                    foregroundColor: Colors.white,
                                    child: Text(
                                      member.name.isEmpty
                                          ? ''
                                          : member.name.trim().split(RegExp(r'\s+')).map((part) => part[0]).take(2).join(),
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: nameFontSize * 0.8,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: spacing1),
                                  Flexible(
                                    child: Text(
                                      member.name,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        color: primaryContentColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: nameFontSize,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: spacing2),
                                  Flexible(
                                    child: Text(
                                      NumberFormatHelper.formatCurrencyCompactIfLarge(
                                        member.totalPaid,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.headlineSmall?.copyWith(
                                        color: primaryContentColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: amountFontSize,
                                      ),
                                    ),
                                  ),
                                  // 显示应收/应付状态
                                  if (widget.allMembers.length > 1) ...[
                                    SizedBox(height: spacing3),
                                    Flexible(
                                      child: _buildBalanceBadge(
                                        theme,
                                        isDark,
                                        primaryContentColor,
                                        fontSize: badgeFontSize,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            // 绘制费用泡泡（放在最后，确保在最上层，可以点击）
            ...(() {
              // 计算当前成员所有费用中的最大金额
              final maxExpenseAmount = expenses.isEmpty
                  ? 0.0
                  : expenses.map((e) => e.amount).reduce(math.max);
              
              // 基础费用泡泡大小（相对于基础成员泡泡大小）
              final baseExpenseSize = widget.expenseBubbleDiameter;
              final baseParentSize = BubbleConstants.defaultBubbleDiameter;
              
              // 根据成员泡泡大小计算基础费用泡泡大小的缩放因子
              final parentScaleFactor = bubbleSize / baseParentSize;
              
              return List.generate(expenses.length, (index) {
                final expense = expenses[index];
                final angles = widget.expenseAngles;
                final hasCustomAngles =
                    angles != null && angles.length == expenses.length;
                final angle = hasCustomAngles
                    ? angles[index]
                    : (2 * math.pi / expenses.length) * index - math.pi / 2;
                
                // 根据费用金额相对于最大金额的比例计算大小
                final amountRatio = maxExpenseAmount > 0
                    ? expense.amount / maxExpenseAmount
                    : 1.0;
                final sizeScale = BubbleConstants.minExpenseSizeRatio + 
                    (amountRatio * (BubbleConstants.maxExpenseSizeRatio - BubbleConstants.minExpenseSizeRatio));
                
                // 最终的费用泡泡大小 = 基础大小 × 成员泡泡缩放 × 金额比例缩放
                final expenseSize = baseExpenseSize * parentScaleFactor * sizeScale;
                
                final dx = math.cos(angle) * orbitRadius;
                final dy = math.sin(angle) * orbitRadius;
                final sharedCount = expense.sharedBy.length;
                final isSharedExpense = sharedCount > 1;
                
                return Positioned(
                  left: stackExtent / 2 + dx - expenseSize / 2,
                  top: stackExtent / 2 + dy - expenseSize / 2,
                  child: _ExpenseBubble(
                    expense: expense,
                    size: expenseSize,
                    expenseBubbleStart: expenseBubbleStart,
                    expenseBubbleEnd: expenseBubbleEnd,
                    expenseBorderColor: expenseBorderColor,
                    expenseShadowColor: expenseShadowColor,
                    isSharedExpense: isSharedExpense,
                    sharedCount: sharedCount,
                    isDark: isDark,
                    theme: theme,
                    onTap: () => widget.onExpenseTap(expense),
                    animationDelay: index * 0.2, // 每个泡泡不同的动画延迟
                    parentBubbleSize: bubbleSize, // 传递父泡泡大小用于字体缩放
                  ),
                );
              });
            })(),
          ],
        ),
    );
  }

  List<Widget> _buildExpenseConnections(
    List<MemberExpense> expenses,
    double orbitRadius,
    double stackExtent,
    bool isDark,
  ) {
    // 简化版本：只显示主要连接线，避免视觉混乱
    // 可以在后续优化中根据需求添加更详细的连接线
    return [];
  }

  List<Color> _getBubbleGradient(ThemeData theme, bool isDark) {
    final balance = widget.member.balance(widget.allMembers);
    if (balance > 0) {
      // 应收（绿色系）
      return isDark
          ? [
              const Color(0xFF10B981).withValues(alpha: 0.72),
              const Color(0xFF059669).withValues(alpha: 0.72),
            ]
          : [
              const Color(0xFF34D399).withValues(alpha: 0.78),
              const Color(0xFF10B981).withValues(alpha: 0.78),
            ];
    } else if (balance < 0) {
      // 应付（橙色系）
      return isDark
          ? [
              const Color(0xFFF59E0B).withValues(alpha: 0.72),
              const Color(0xFFD97706).withValues(alpha: 0.72),
            ]
          : [
              const Color(0xFFFBBF24).withValues(alpha: 0.78),
              const Color(0xFFF59E0B).withValues(alpha: 0.78),
            ];
    } else {
      // 平衡（默认紫色系）
      return isDark
          ? [
              const Color(0xFF4F46E5).withValues(alpha: 0.72),
              const Color(0xFF9333EA).withValues(alpha: 0.72),
            ]
          : [
              const Color(0xFF5B8DEF).withValues(alpha: 0.78),
              const Color(0xFF7C3AED).withValues(alpha: 0.78),
            ];
    }
  }

  Widget _buildBalanceBadge(
    ThemeData theme,
    bool isDark,
    Color textColor, {
    double fontSize = 9.0,
  }) {
    final balance = widget.member.balance(widget.allMembers);
    if (balance.abs() < 0.01) {
      // 平衡
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: fontSize * 0.67, // 6 / 9 ≈ 0.67
          vertical: fontSize * 0.11, // 1 / 9 ≈ 0.11
        ),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.black.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(fontSize * 0.89), // 8 / 9 ≈ 0.89
        ),
          child: Text(
            '平衡',
            style: theme.textTheme.labelSmall?.copyWith(
              color: textColor.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
              fontSize: fontSize,
            ),
          ),
      );
    }

    final isPositive = balance > 0;
    final balanceColor = isPositive
        ? (isDark ? const Color(0xFF10B981) : const Color(0xFF059669))
        : (isDark ? const Color(0xFFF59E0B) : const Color(0xFFD97706));

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: fontSize * 0.67, // 6 / 9 ≈ 0.67
        vertical: fontSize * 0.11, // 1 / 9 ≈ 0.11
      ),
      decoration: BoxDecoration(
        color: balanceColor.withValues(alpha: isDark ? 0.3 : 0.2),
        borderRadius: BorderRadius.circular(fontSize * 0.89), // 8 / 9 ≈ 0.89
        border: Border.all(
          color: balanceColor.withValues(alpha: 0.5),
          width: fontSize * 0.11, // 1 / 9 ≈ 0.11
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.arrow_upward : Icons.arrow_downward,
            size: fontSize,
            color: balanceColor,
          ),
          SizedBox(width: fontSize * 0.22),
          Text(
            isPositive ? '应收' : '应付',
            style: theme.textTheme.labelSmall?.copyWith(
              color: balanceColor,
              fontWeight: FontWeight.w600,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}

/// 费用泡泡组件，带动画效果
class _ExpenseBubble extends StatefulWidget {
  const _ExpenseBubble({
    required this.expense,
    required this.size,
    required this.expenseBubbleStart,
    required this.expenseBubbleEnd,
    required this.expenseBorderColor,
    required this.expenseShadowColor,
    required this.isSharedExpense,
    required this.sharedCount,
    required this.isDark,
    required this.theme,
    required this.onTap,
    required this.animationDelay,
    required this.parentBubbleSize,
  });

  final MemberExpense expense;
  final double size;
  final Color expenseBubbleStart;
  final Color expenseBubbleEnd;
  final Color expenseBorderColor;
  final Color expenseShadowColor;
  final bool isSharedExpense;
  final int sharedCount;
  final bool isDark;
  final ThemeData theme;
  final VoidCallback onTap;
  final double animationDelay;
  final double parentBubbleSize; // 父泡泡大小，用于字体缩放

  @override
  State<_ExpenseBubble> createState() => _ExpenseBubbleState();
}

class _ExpenseBubbleState extends State<_ExpenseBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    // 呼吸动画 - 让费用泡泡有轻微的缩放效果
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // 延迟启动动画，让每个泡泡有不同的节奏
    Future.delayed(Duration(milliseconds: (widget.animationDelay * 1000).round()), () {
      if (mounted) {
        _pulseController.repeat(reverse: true);
      }
    });
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value * _scale,
          child: GestureDetector(
            onTap: () {
              // 点击时的缩放反馈
              setState(() {
                _scale = 0.9;
              });
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) {
                  setState(() {
                    _scale = 1.0;
                  });
                }
              });
              widget.onTap();
            },
            child: Builder(
              builder: (context) {
                // 根据费用泡泡大小计算所有相关的缩放值
                final baseExpenseSize = 56.0;
                final expenseScaleFactor = widget.size / baseExpenseSize;
                
                // 费用泡泡字体随费用泡泡大小按比例缩放
                final amountFontSize = 10.0 * expenseScaleFactor;
                final badgeFontSize = 8.0 * expenseScaleFactor;
                final bottomPadding = (widget.isSharedExpense ? 10.0 : 0.0) * expenseScaleFactor;
                final badgeBottom = 3.0 * expenseScaleFactor;
                final badgePaddingH = 4.0 * expenseScaleFactor;
                final badgePaddingV = 1.0 * expenseScaleFactor;
                
                return Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [widget.expenseBubbleStart, widget.expenseBubbleEnd],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: widget.isSharedExpense
                          ? widget.expenseBorderColor
                          : widget.expenseBorderColor.withValues(alpha: 0.5),
                      width: widget.isSharedExpense 
                          ? (1.5 * expenseScaleFactor).clamp(1.0, 2.5)
                          : (1.0 * expenseScaleFactor).clamp(0.8, 2.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.expenseShadowColor,
                        blurRadius: 8 * expenseScaleFactor,
                        offset: Offset(0, 4 * expenseScaleFactor),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 金额文字
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: bottomPadding,
                        ),
                        child: Text(
                          NumberFormatHelper.formatCurrencyCompactIfLarge(
                            widget.expense.amount,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: widget.theme.textTheme.labelSmall?.copyWith(
                            color: widget.isDark
                                ? Colors.white.withValues(alpha: 0.9)
                                : const Color(0xFF1B2A75),
                            fontWeight: FontWeight.w600,
                            fontSize: amountFontSize,
                          ),
                        ),
                      ),
                      // 分摊人数标识
                      if (widget.isSharedExpense)
                        Positioned(
                          bottom: badgeBottom,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: badgePaddingH,
                              vertical: badgePaddingV,
                            ),
                            decoration: BoxDecoration(
                              color: widget.isDark
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : Colors.black.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6 * expenseScaleFactor),
                            ),
                            child: Text(
                              '${widget.sharedCount}人',
                              style: widget.theme.textTheme.labelSmall?.copyWith(
                                color: widget.isDark
                                    ? Colors.white.withValues(alpha: 0.9)
                                    : const Color(0xFF1B2A75),
                                fontWeight: FontWeight.w600,
                                fontSize: badgeFontSize,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
