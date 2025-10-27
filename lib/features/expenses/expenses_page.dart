import 'package:crew_app/features/expenses/data/participant.dart';
import 'package:crew_app/features/expenses/data/sample_data.dart';
import 'package:crew_app/features/expenses/widgets/add_expense_sheet.dart';
import 'package:crew_app/features/expenses/widgets/dialog_row.dart';
import 'package:crew_app/features/expenses/widgets/member_details_sheet.dart';
import 'package:crew_app/features/expenses/widgets/participant_bubble.dart';
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

class _ExpensesPageState extends State<ExpensesPage> {
  late final List<Participant> _participants;
  late final double _maxTotal;
  late final double _overallTotal;

  @override
  void initState() {
    super.initState();
    _participants = sampleParticipants;
    _overallTotal = _participants.fold<double>(
      0,
      (previousValue, element) => previousValue + element.total,
    );
    _maxTotal = _participants.fold<double>(
      0,
      (previousValue, element) => previousValue > element.total ? previousValue : element.total,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F8F0), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.event_group_expense_intro,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      loc.event_group_expense_hint,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 720;
                    return SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        8,
                        16,
                        MediaQuery.paddingOf(context).bottom + 96,
                      ),
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOut,
                        child: Wrap(
                          alignment: isWide ? WrapAlignment.center : WrapAlignment.start,
                          spacing: isWide ? 32 : 20,
                          runSpacing: isWide ? 32 : 20,
                          children: _participants
                              .map(
                                (participant) => ParticipantBubble(
                                  participant: participant,
                                  maxTotal: _maxTotal,
                                  onTap: () => _showMemberDetails(participant),
                                  onExpenseTap: (expense) =>
                                      _showExpenseDetails(context, participant, expense),
                                ),
                              )
                              .toList(),
                        ),
                      ),
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

  Future<void> _showMemberDetails(Participant participant) async {
    final evenShare = _overallTotal / _participants.length;
    final difference = participant.total - evenShare;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
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
              difference: difference,
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
    final currency = NumberFormatHelper.currency;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(expense.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DialogRow(label: '消费人', value: participant.name),
              DialogRow(label: '类别', value: expense.category),
              DialogRow(label: '金额', value: currency.format(expense.amount)),
              DialogRow(
                label: '时间',
                value: FormattedDate.format(expense.timestamp),
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return AddExpenseSheet(participants: _participants);
      },
    );

    if (!mounted || result == null) return;

    final participant = result.participant;
    final amountText = result.amountText.isEmpty ? '新' : result.amountText;
    final name = participant?.name ?? '未知成员';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          participant == null
              ? '请选择支付人'
              : '已为 $name 添加 $amountText 费用',
        ),
      ),
    );
  }

  Future<void> _showSettlementPreview() async {
    final evenShare = _overallTotal / _participants.length;
    final entries = _participants
        .map(
          (participant) => SettlementEntry(
            participant: participant,
            difference: participant.total - evenShare,
          ),
        )
        .toList()
      ..sort((a, b) => b.difference.compareTo(a.difference));

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SettlementPreviewSheet(entries: entries);
      },
    );
  }
}
