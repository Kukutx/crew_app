import 'dart:math' as math;

import 'package:crew_app/features/expenses/data/participant.dart';
import 'package:crew_app/features/expenses/data/sample_data.dart';
import 'package:crew_app/features/expenses/widgets/add_expense_sheet.dart';
import 'package:crew_app/features/expenses/widgets/dialog_row.dart';
import 'package:crew_app/features/expenses/widgets/member_details_sheet.dart';
import 'package:crew_app/features/expenses/widgets/participant_bubble_cluster.dart';
import 'package:crew_app/features/expenses/widgets/settlement_preview_sheet.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/utils/formatted_date.dart';
import 'package:crew_app/shared/utils/number_format_helper.dart';
import 'package:crew_app/shared/widgets/app_floating_action_button.dart';
import 'package:flutter/material.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage>
    with TickerProviderStateMixin {
  late List<Participant> _participants;
  final TransformationController _transformationController =
      TransformationController();
  AnimationController? _resetAnimationController;
  Matrix4? _initialTransform;
  bool _hasInitializedTransform = false;
  Size? _lastViewSize;
  Size? _lastClusterSize;

  @override
  void initState() {
    super.initState();
    _participants = List.from(sampleParticipants);
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _resetAnimationController?.dispose();
    super.dispose();
  }

  /// 计算合适的变换矩阵，使所有泡泡都能完整显示在视图中
  Matrix4 _calculateFitTransform({
    required Size viewSize,
    required Size clusterSize,
    required Size canvasSize,
    double padding = 16.0, // 减少边距，让泡泡显示更大
  }) {
    if (clusterSize.width <= 0 || clusterSize.height <= 0) {
      return Matrix4.identity();
    }

    // 计算可用的视图大小（减少边距，让泡泡显示更大）
    final availableWidth = viewSize.width - padding * 2;
    final availableHeight = viewSize.height - padding * 2;

    // 计算缩放比例，确保集群完全适合视图（取较小的比例以确保完整显示）
    final scaleX = availableWidth / clusterSize.width;
    final scaleY = availableHeight / clusterSize.height;
    
    // 使用更激进的缩放策略，让泡泡显示更大
    // 取较小的比例以确保完整显示
    var baseScale = math.min(scaleX, scaleY);
    
    // 如果集群比视图小（baseScale > 1.0），可以放大更多以更好地填充屏幕
    // 使用0.95的填充率（留5%的边距），让泡泡显示更大、更居中
    var scale = baseScale;
    if (baseScale > 1.0) {
      // 如果集群比视图小，可以放大到填充95%的屏幕，让泡泡显示更大
      // 例如：如果 baseScale = 2.0，意味着集群只有视图的1/2，我们可以放大到 2.0 * 0.95 = 1.9倍
      scale = baseScale * 0.95;
      // 但不要超过1.6倍，避免泡泡过大
      scale = math.min(scale, 1.6);
    } else {
      // 如果集群比视图大，使用原始比例（不缩小），确保所有泡泡都能完整显示
      // 但确保最小缩放，避免显示过小
      scale = math.max(baseScale, 0.6);
    }
    
    // 确保缩放比例在合理范围内
    scale = scale.clamp(0.6, 1.6);

    // 计算偏移，使集群居中
    // 集群在画布中的中心位置
    final clusterCenterX = canvasSize.width / 2;
    final clusterCenterY = canvasSize.height / 2;

    // 视图中心位置（考虑顶部统计卡片的高度）
    final viewCenterX = viewSize.width / 2;
    final viewCenterY = viewSize.height / 2;

    // 计算平移距离，使缩放后的集群中心对齐到视图中心
    // 变换顺序：先缩放，后平移
    // 缩放后，画布上的点 (x, y) 变成 (x * scale, y * scale)
    // 然后平移，使集群中心 (clusterCenterX, clusterCenterY) 对齐到视图中心 (viewCenterX, viewCenterY)
    // 所以：viewCenterX = clusterCenterX * scale + translateX
    // 因此：translateX = viewCenterX - clusterCenterX * scale
    final translateX = viewCenterX - clusterCenterX * scale;
    final translateY = viewCenterY - clusterCenterY * scale;

    // 创建变换矩阵：先缩放，后平移
    // Matrix4 的 scale 和 translate 操作会按照调用的顺序应用
    // 但我们想要的效果是：先缩放，然后在缩放后的坐标系中平移
    // 由于 Matrix4 的 translate 是在当前坐标系中应用的，而我们已经应用了 scale
    // 所以我们需要在缩放前的坐标系中计算平移距离
    // 在缩放后的坐标系中，平移 translateX 相当于在缩放前的坐标系中平移 translateX / scale
    final matrix = Matrix4.identity()
      ..scale(scale)
      ..translate(translateX / scale, translateY / scale);
    
    return matrix;
  }

  /// 重置视图到中心，显示所有泡泡
  void _resetView(Size viewSize, Size clusterSize, Size canvasSize) {
    final targetTransform = _calculateFitTransform(
      viewSize: viewSize,
      clusterSize: clusterSize,
      canvasSize: canvasSize,
    );

    // 如果动画控制器不存在，创建一个
    _resetAnimationController?.dispose();
    _resetAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    final currentTransform = _transformationController.value;
    final animation = Matrix4Tween(
      begin: currentTransform,
      end: targetTransform,
    ).animate(
      CurvedAnimation(
        parent: _resetAnimationController!,
        curve: Curves.easeInOut,
      ),
    );

    animation.addListener(() {
      _transformationController.value = animation.value;
    });

    _resetAnimationController!.forward().then((_) {
      _resetAnimationController?.dispose();
      _resetAnimationController = null;
    });
  }

  void _addExpense(AddExpenseResult result) {
    setState(() {
      // 找到支付人
      final payerIndex = _participants.indexWhere((p) => p.name == result.paidBy);
      if (payerIndex == -1) return;

      // 创建新的费用
      final expense = ParticipantExpense(
        title: result.title,
        amount: result.amount,
        category: result.category,
        timestamp: DateTime.now(),
        paidBy: result.paidBy,
        sharedBy: result.sharedBy,
        paymentMethod: result.paymentMethod,
        note: result.note,
      );

      // 添加到支付人的费用列表
      final payer = _participants[payerIndex];
      final updatedPayer = Participant(
        name: payer.name,
        isHost: payer.isHost,
        expenses: [...payer.expenses, expense],
      );

      _participants = List.from(_participants);
      _participants[payerIndex] = updatedPayer;
      
      // 重置初始变换标志，以便在下次构建时重新计算
      _hasInitializedTransform = false;
      _initialTransform = null;
      _lastClusterSize = null;
    });
  }

  double get _overallTotal {
    return _participants.fold<double>(
      0,
      (sum, participant) => sum + participant.totalPaid,
    );
  }

  double get _averagePerPerson {
    if (_participants.isEmpty) return 0;
    // 计算所有费用的总应承担金额
    double totalOwed = 0;
    for (final participant in _participants) {
      totalOwed += participant.totalOwed(_participants);
    }
    return totalOwed / _participants.length;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundGradient = isDark
        ? const [Color(0xFF0F1424), Color(0xFF070910)]
        : const [Color(0xFFE8EDFF), Colors.white];
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.event_group_expense_title),
        actions: [
          IconButton(
            tooltip: '结算预览',
            onPressed: _showSettlementPreview,
            icon: const Icon(Icons.auto_graph_rounded),
          ),
        ],
      ),
      floatingActionButton: AppFloatingActionButton(
        variant: AppFloatingActionButtonVariant.extended,
        onPressed: _showAddExpenseSheet,
        icon: const Icon(Icons.add),
        label: const Text('添加费用'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: backgroundGradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部统计卡片
              _buildStatsCard(context, theme, isDark),
              // 泡泡可视化区域 - 可滑动和缩放
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final participants = _participants.take(7).toList();
                    
                    // 计算泡泡集群的实际大小
                    final clusterSize = ParticipantBubbleCluster.calculateClusterSize(participants);
                    
                    // 计算合适的画布大小，留有足够的滑动空间
                    final participantCount = participants.length;
                    final baseSize = ParticipantBubbleCluster.bubbleDiameter;
                    // 根据成员数量调整画布大小 - 增大画布以提供更多滑动空间
                    final canvasMultiplier = participantCount >= 7 ? 3.5 : 2.5;
                    final canvasWidth = math.max(
                      constraints.maxWidth * canvasMultiplier,
                      baseSize * 6,
                    );
                    final canvasHeight = math.max(
                      constraints.maxHeight * canvasMultiplier,
                      baseSize * 6,
                    );
                    final canvasSize = Size(canvasWidth, canvasHeight);
                    final viewSize = Size(constraints.maxWidth, constraints.maxHeight);

                    // 检查是否需要重新计算初始变换
                    // 如果还没有初始化，或者视图尺寸变化，或者集群尺寸变化，都需要重新计算
                    final viewSizeChanged = _lastViewSize == null ||
                        (_lastViewSize!.width != viewSize.width) ||
                        (_lastViewSize!.height != viewSize.height);
                    final clusterSizeChanged = _lastClusterSize == null ||
                        (_lastClusterSize!.width != clusterSize.width) ||
                        (_lastClusterSize!.height != clusterSize.height);
                    final needsInitialization = !_hasInitializedTransform ||
                        viewSizeChanged ||
                        clusterSizeChanged;

                    // 计算初始变换（仅在首次或尺寸变化时）
                    if (needsInitialization && clusterSize.width > 0 && clusterSize.height > 0) {
                      // 立即计算初始变换
                      final initialTransform = _calculateFitTransform(
                        viewSize: viewSize,
                        clusterSize: clusterSize,
                        canvasSize: canvasSize,
                      );
                      _initialTransform = initialTransform;
                      
                      // 使用 addPostFrameCallback 确保在布局完成后设置，避免闪烁
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          _transformationController.value = initialTransform;
                          _hasInitializedTransform = true;
                          _lastViewSize = viewSize;
                          _lastClusterSize = clusterSize;
                        }
                      });
                    } else if (!_hasInitializedTransform && _initialTransform != null) {
                      // 如果已经计算过初始变换但还没有应用，立即应用
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          _transformationController.value = _initialTransform!;
                          _hasInitializedTransform = true;
                        }
                      });
                    }

                    return Stack(
                      children: [
                        InteractiveViewer(
                          minScale: 0.5,
                          maxScale: 3.0,
                          transformationController: _transformationController,
                          // 设置更大的边界边距，允许更大的滑动范围
                          boundaryMargin: EdgeInsets.all(
                            math.max(constraints.maxWidth, constraints.maxHeight) * 0.8,
                          ),
                          child: Container(
                            width: canvasWidth,
                            height: canvasHeight,
                            child: Center(
                              child: ParticipantBubbleCluster(
                                participants: participants,
                                allParticipants: _participants,
                                onParticipantTap: _showMemberDetails,
                                onExpenseTap: (participant, expense) =>
                                    _showExpenseDetails(
                                      context,
                                      participant,
                                      expense,
                                    ),
                              ),
                            ),
                          ),
                        ),
                        // 回到中心按钮 - 放在右下角，在添加费用按钮上方
                        Positioned(
                          bottom: MediaQuery.paddingOf(context).bottom + 140,
                          right: 16,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                // 重置视图，显示所有泡泡
                                _resetView(viewSize, clusterSize, canvasSize);
                              },
                              borderRadius: BorderRadius.circular(28),
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withValues(alpha: 0.95),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.15),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.center_focus_strong,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, ThemeData theme, bool isDark) {
    final colorScheme = theme.colorScheme;
    final statsBgColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.9);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statsBgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  '总费用',
                  NumberFormatHelper.formatCurrencyCompactIfLarge(_overallTotal),
                  Icons.account_balance_wallet,
                  colorScheme.primary,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.shade300,
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  'AA金额',
                  NumberFormatHelper.formatCurrencyCompactIfLarge(_averagePerPerson),
                  Icons.people,
                  colorScheme.secondary,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.shade300,
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  '成员',
                  '${_participants.length}',
                  Icons.person,
                  colorScheme.tertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark
                ? Colors.white.withValues(alpha: 0.6)
                : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Future<void> _showMemberDetails(Participant participant) async {
    final balance = participant.balance(_participants);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (context, controller) {
            return MemberDetailsSheet(
              participant: participant,
              difference: balance,
              allParticipants: _participants,
              scrollController: controller,
            );
          },
        );
      },
    );
  }

  Future<void> _showExpenseDetails(
    BuildContext context,
    Participant participant,
    ParticipantExpense expense,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(expense.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DialogRow(label: '支付人', value: expense.paidBy),
              DialogRow(
                label: '参与分摊',
                value: '${expense.sharedBy.length} 人',
              ),
              DialogRow(
                label: '每人承担',
                value: NumberFormatHelper.formatCurrencyCompactIfLarge(
                  expense.sharePerPerson,
                ),
              ),
              if (expense.sharedBy.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '参与成员：',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: expense.sharedBy.map((name) {
                    final isPayer = name == expense.paidBy;
                    return Chip(
                      label: Text(name),
                      avatar: isPayer
                          ? const Icon(Icons.account_balance_wallet, size: 16)
                          : null,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 12),
              DialogRow(label: '类别', value: expense.category),
              DialogRow(
                label: '金额',
                value: NumberFormatHelper.formatCurrencyCompactIfLarge(
                  expense.amount,
                ),
              ),
              DialogRow(
                label: '时间',
                value: DateFormatHelper.format(expense.timestamp),
              ),
              if (expense.paymentMethod != null)
                DialogRow(label: '支付方式', value: expense.paymentMethod!),
              if (expense.note != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    expense.note!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('关闭'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddExpenseSheet() async {
    final result = await showModalBottomSheet<AddExpenseResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return AddExpenseSheet(participants: _participants);
      },
    );

    if (!mounted || result == null) return;

    _addExpense(result);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '已添加费用：${result.title} (${NumberFormatHelper.formatCurrencyCompactIfLarge(result.amount)})',
        ),
        action: SnackBarAction(
          label: '撤销',
          onPressed: () {
            // TODO: 实现撤销功能
          },
        ),
      ),
    );
  }

  Future<void> _showSettlementPreview() async {
    final entries = _participants
        .map(
          (participant) => SettlementEntry(
            participant: participant,
            difference: participant.balance(_participants),
          ),
        )
        .toList()
      ..sort((a, b) => b.difference.compareTo(a.difference));

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SettlementPreviewSheet(entries: entries);
      },
    );
  }
}
