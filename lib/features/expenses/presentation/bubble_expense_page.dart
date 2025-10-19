import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/expenses_controller.dart';
import '../data/models/expense.dart';
import 'add_expense_sheet.dart';
import 'settlement_preview_sheet.dart';
import 'widgets/bubble_canvas.dart';
import 'widgets/member_detail_sheet.dart';

class BubbleExpensePage extends ConsumerStatefulWidget {
  const BubbleExpensePage({
    super.key,
    required this.eventId,
    this.title,
  });

  final String eventId;
  final String? title;

  @override
  ConsumerState<BubbleExpensePage> createState() => _BubbleExpensePageState();
}

class _BubbleExpensePageState extends ConsumerState<BubbleExpensePage> {
  late final TransformationController _transformationController;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<ExpensesState>>(
      expensesControllerProvider(widget.eventId),
      (previous, next) {
        next.whenOrNull(
          error: (error, stackTrace) {
            if (!mounted) {
              return;
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('操作失败：${error.toString()}')),
            );
          },
        );
      },
    );

    final asyncState = ref.watch(expensesControllerProvider(widget.eventId));
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? '泡泡分账'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '刷新',
            onPressed: () {
              ref.read(expensesControllerProvider(widget.eventId).notifier).refresh();
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'settlement') {
                final controller =
                    ref.read(expensesControllerProvider(widget.eventId).notifier);
                try {
                  final settlement = await controller.previewSettlement();
                  if (!mounted) {
                    return;
                  }
                  final members = _membersMap(controller.state.valueOrNull);
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) {
                      return SettlementPreviewSheet(
                        settlement: settlement,
                        members: members,
                      );
                    },
                  );
                } catch (error) {
                  if (!mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('无法生成结算预览：$error')),
                  );
                }
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<String>(
                value: 'settlement',
                child: Text('结算预览'),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: asyncState.maybeWhen(
        data: (data) => FloatingActionButton.extended(
          onPressed: () => _openAddExpenseSheet(data.members),
          icon: const Icon(Icons.add),
          label: const Text('新增消费'),
        ),
        orElse: () => const SizedBox.shrink(),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: asyncState.when(
          data: (data) => _buildCanvas(context, data),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _ErrorView(
            message: '加载失败：${error.toString()}',
            onRetry: () => ref
                .read(expensesControllerProvider(widget.eventId).notifier)
                .refresh(),
          ),
        ),
      ),
    );
  }

  Widget _buildCanvas(BuildContext context, ExpensesState state) {
    if (state.members.isEmpty) {
      return const Center(child: Text('暂无成员或消费数据'));
    }
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 0.6,
        maxScale: 2.6,
        boundaryMargin: const EdgeInsets.all(200),
        child: BubbleCanvas(
          members: state.members,
          expenses: state.expenses,
          onMemberTap: (member) => _openMemberDetail(member, state),
        ),
      ),
    );
  }

  void _openMemberDetail(Member member, ExpensesState state) {
    final members = _membersMap(state);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return MemberDetailSheet(
          member: member,
          members: members,
          expenses: state.expenses,
          onDeleteExpense: (expense) async {
            Navigator.pop(context);
            await ref
                .read(expensesControllerProvider(widget.eventId).notifier)
                .deleteExpense(expense.id);
          },
        );
      },
    );
  }

  void _openAddExpenseSheet(List<Member> members) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return AddExpenseSheet(
          members: members,
          onSubmit: (request) => ref
              .read(expensesControllerProvider(widget.eventId).notifier)
              .addExpense(request),
        );
      },
    );
  }

  Map<String, Member> _membersMap(ExpensesState? state) {
    final members = state?.members ?? const <Member>[];
    return {for (final member in members) member.id: member};
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('重试'),
          ),
        ],
      ),
    );
  }
}
