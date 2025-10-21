import 'dart:math' as math;

import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> with TickerProviderStateMixin {
  late final List<_Participant> _participants;
  late final double _maxTotal;
  late final double _overallTotal;

  @override
  void initState() {
    super.initState();
    _participants = _sampleParticipants;
    _overallTotal = _participants.fold<double>(
      0,
      (previousValue, element) => previousValue + element.total,
    );
    _maxTotal = _participants.fold<double>(
      0,
      (previousValue, element) => math.max(previousValue, element.total),
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
      floatingActionButton: FloatingActionButton.extended(
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
                                (participant) => _ParticipantBubble(
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

  void _showMemberDetails(_Participant participant) {
    final evenShare = _overallTotal / _participants.length;
    final difference = participant.total - evenShare;
    final currency = NumberFormatHelper.currency;

    showModalBottomSheet<void>(
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
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _Avatar(name: participant.name),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              participant.name,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Text(
                              '${currency.format(participant.total)} · ${participant.expenses.length} 笔消费',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.black54,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView.separated(
                      controller: controller,
                      itemCount: participant.expenses.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final expense = participant.expenses[index];
                        return _ExpenseListTile(expense: expense);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F8F0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SummaryRow(
                          label: '总计',
                          value: currency.format(participant.total),
                        ),
                        const SizedBox(height: 12),
                        _SummaryRow(
                          label: '平摊后差额',
                          value: difference >= 0
                              ? '+${currency.format(difference.abs())}'
                              : '-${currency.format(difference.abs())}',
                          valueColor:
                              difference >= 0 ? const Color(0xFF1B8A5C) : Colors.redAccent,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          difference >= 0
                              ? '需要收回 ${currency.format(difference.abs())}'
                              : '仍需补交 ${currency.format(difference.abs())}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showExpenseDetails(
    BuildContext context,
    _Participant participant,
    _ParticipantExpense expense,
  ) {
    final currency = NumberFormatHelper.currency;
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(expense.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DialogRow(label: '消费人', value: participant.name),
              _DialogRow(label: '类别', value: expense.category),
              _DialogRow(label: '金额', value: currency.format(expense.amount)),
              _DialogRow(
                label: '时间',
                value: _FormattedDate.format(expense.timestamp),
              ),
              if (expense.paymentMethod != null)
                _DialogRow(label: '支付方式', value: expense.paymentMethod!),
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

  void _showAddExpenseSheet() {
    final theme = Theme.of(context);
    _Participant? selectedParticipant = _participants.first;
    final amountController = TextEditingController();
    final titleController = TextEditingController();
    String category = '餐饮';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '添加费用',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<_Participant>(
                    initialValue : selectedParticipant,
                    decoration: const InputDecoration(labelText: '支付人'),
                    items: _participants
                        .map(
                          (participant) => DropdownMenuItem<_Participant>(
                            value: participant,
                            child: Text(participant.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setModalState(() {
                        selectedParticipant = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '金额 (€)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: '费用说明',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue : category,
                    decoration: const InputDecoration(labelText: '类别'),
                    items: const [
                      DropdownMenuItem(value: '餐饮', child: Text('餐饮')),
                      DropdownMenuItem(value: '油费', child: Text('油费')),
                      DropdownMenuItem(value: '住宿', child: Text('住宿')),
                      DropdownMenuItem(value: '门票', child: Text('门票')),
                      DropdownMenuItem(value: '其他', child: Text('其他')),
                    ],
                    onChanged: (value) {
                      setModalState(() {
                        category = value ?? category;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            content: Text(
                              selectedParticipant == null
                                  ? '请选择支付人'
                                  : '已为 ${selectedParticipant!.name} 添加 ${amountController.text.isEmpty ? '新' : amountController.text} 费用',
                            ),
                          ),
                        );
                      },
                      child: const Text('保存'),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    ).whenComplete(() {
      amountController.dispose();
      titleController.dispose();
    });
  }

  void _showSettlementPreview() {
    final evenShare = _overallTotal / _participants.length;
    final currency = NumberFormatHelper.currency;
    final entries = _participants
        .map(
          (participant) => _SettlementEntry(
            participant: participant,
            difference: participant.total - evenShare,
          ),
        )
        .toList()
      ..sort((a, b) => b.difference.compareTo(a.difference));

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '结算预览',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final color = entry.difference >= 0
                        ? const Color(0xFF1B8A5C)
                        : Colors.redAccent;
                    return ListTile(
                      leading: _Avatar(name: entry.participant.name),
                      title: Text(entry.participant.name),
                      subtitle: Text(
                        entry.difference >= 0
                            ? '应收 ${currency.format(entry.difference.abs())}'
                            : '需补 ${currency.format(entry.difference.abs())}',
                      ),
                      trailing: Text(
                        '${entry.difference >= 0 ? '+' : '-'}${currency.format(entry.difference.abs())}',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: entries.map((entry) {
                  final isPositive = entry.difference >= 0;
                  return Chip(
                    avatar: CircleAvatar(
                      backgroundColor:
                          isPositive ? const Color(0xFF1B8A5C) : Colors.redAccent,
                      child: Icon(
                        isPositive ? Icons.arrow_downward : Icons.arrow_upward,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: const Color(0xFFE8F8F0),
                    label: Text(
                      '${entry.participant.name} ${isPositive ? '收回' : '补给'} ${currency.format(entry.difference.abs())}',
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ParticipantBubble extends StatefulWidget {
  const _ParticipantBubble({
    required this.participant,
    required this.maxTotal,
    required this.onTap,
    required this.onExpenseTap,
  });

  final _Participant participant;
  final double maxTotal;
  final VoidCallback onTap;
  final ValueChanged<_ParticipantExpense> onExpenseTap;

  @override
  State<_ParticipantBubble> createState() => _ParticipantBubbleState();
}

class _ParticipantBubbleState extends State<_ParticipantBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2600 + (widget.participant.total * 4).toInt()),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final participant = widget.participant;
    final normalized = widget.maxTotal == 0
        ? 0.0
        : (participant.total / widget.maxTotal).clamp(0.0, 1.0);
    final bubbleSize = 120.0 + (normalized * 120);
    final expenses = participant.expenses;
    final baseRadius = bubbleSize / 2 + 36;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final floatOffset = math.sin(_controller.value * math.pi * 2) * 6;
        return Transform.translate(
          offset: Offset(0, floatOffset),
          child: child,
        );
      },
      child: SizedBox(
        width: bubbleSize + 140,
        height: bubbleSize + 140,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            ...List.generate(expenses.length, (index) {
              final expense = expenses[index];
              final ratio = participant.total == 0
                  ? 0.0
                  : (expense.amount / participant.total).clamp(0.0, 1.0);
              final size = 38.0 + ratio * 60;
              final angle = (2 * math.pi / expenses.length) * index;
              final dx = math.cos(angle) * (baseRadius + (index.isEven ? 10 : -6));
              final dy = math.sin(angle) * (baseRadius + (index.isOdd ? 6 : -8));
              return Positioned(
                left: (bubbleSize + 140) / 2 + dx - size / 2,
                top: (bubbleSize + 140) / 2 + dy - size / 2,
                child: GestureDetector(
                  onTap: () => widget.onExpenseTap(expense),
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xAA66D69D),
                          Colors.white.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: const Color(0x5566D69D),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x4466D69D),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        NumberFormatHelper.shortCurrency(expense.amount),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: const Color(0xFF1B5E3B),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                ),
              );
            }),
            GestureDetector(
              onTap: widget.onTap,
              child: Container(
                width: bubbleSize,
                height: bubbleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF42BD82), Color(0xFF1B8A5C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x5532A56C),
                      blurRadius: 20,
                      offset: Offset(0, 18),
                    ),
                  ],
                  border: participant.isCreator
                      ? Border.all(
                          color: Colors.white.withValues(alpha: .8),
                          width: 3,
                        )
                      : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Avatar(
                        name: participant.name,
                        isPrimary: true,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        participant.name,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        NumberFormatHelper.currency.format(participant.total),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Participant {
  const _Participant({
    required this.name,
    required this.expenses,
    this.isCreator = false,
  });

  final String name;
  final List<_ParticipantExpense> expenses;
  final bool isCreator;

  double get total => expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
}

class _ParticipantExpense {
  const _ParticipantExpense({
    required this.title,
    required this.amount,
    required this.category,
    required this.timestamp,
    this.paymentMethod,
    this.note,
  });

  final String title;
  final double amount;
  final String category;
  final DateTime timestamp;
  final String? paymentMethod;
  final String? note;
}

class _ExpenseListTile extends StatelessWidget {
  const _ExpenseListTile({required this.expense});

  final _ParticipantExpense expense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = NumberFormatHelper.currency;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 12,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B8A5C).withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  expense.category,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: const Color(0xFF1B8A5C),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                currency.format(expense.amount),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            expense.title,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            _FormattedDate.relative(expense.timestamp),
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
          ),
          if (expense.paymentMethod != null || expense.note != null) ...[
            const SizedBox(height: 12),
            if (expense.paymentMethod != null)
              Text(
                '支付方式：${expense.paymentMethod}',
                style: theme.textTheme.bodySmall,
              ),
            if (expense.note != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  expense.note!,
                  style: theme.textTheme.bodySmall,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _DialogRow extends StatelessWidget {
  const _DialogRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              '$label：',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: valueColor,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.name,
    this.isPrimary = false,
  });

  final String name;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final initials = name.isEmpty
        ? ''
        : name.trim().split(RegExp(r'\s+')).map((part) => part[0]).take(2).join();
    return CircleAvatar(
      radius: isPrimary ? 32 : 24,
      backgroundColor: isPrimary ? Colors.white.withValues(alpha: .24) : const Color(0xFF1B8A5C),
      child: Text(
        initials,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isPrimary ? Colors.white : Colors.white,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _SettlementEntry {
  const _SettlementEntry({
    required this.participant,
    required this.difference,
  });

  final _Participant participant;
  final double difference;
}

class NumberFormatHelper {
  static final NumberFormat currency = NumberFormat.simpleCurrency(locale: 'de_DE');
  static final NumberFormat _bubbleCurrency = NumberFormat.currency(
    locale: 'de_DE',
    symbol: '€',
    decimalDigits: 0,
  );
  static final NumberFormat _compactCurrency =
      NumberFormat.compactSimpleCurrency(locale: 'de_DE', name: 'EUR');

  static String shortCurrency(double value) {
    if (value >= 1000) {
      return _compactCurrency.format(value);
    }
    return _bubbleCurrency.format(value);
  }
}

class _FormattedDate {
  static final DateFormat _date = DateFormat('MM月dd日 HH:mm');
  static final DateFormat _relativeFormat = DateFormat('MM月dd日');

  static String format(DateTime date) => _date.format(date);

  static String relative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} 分钟前';
      }
      return '${difference.inHours} 小时前';
    }
    if (difference.inDays == 1) {
      return '昨天 · ${DateFormat('HH:mm').format(date)}';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays} 天前';
    }
    return _relativeFormat.format(date);
  }
}

final List<_Participant> _sampleParticipants = [
  _Participant(
    name: 'Alice',
    isCreator: true,
    expenses: [
      _ParticipantExpense(
        title: '第一天加油',
        amount: 86.5,
        category: '油费',
        timestamp: DateTime.now().subtract(Duration(hours: 6)),
        paymentMethod: 'Visa',
      ),
      _ParticipantExpense(
        title: '路边咖啡',
        amount: 14.2,
        category: '餐饮',
        timestamp: DateTime.now().subtract(Duration(hours: 3)),
        note: '和大家一起喝咖啡',
      ),
      _ParticipantExpense(
        title: '营地预定',
        amount: 120,
        category: '住宿',
        timestamp: DateTime.now().subtract(Duration(days: 1, hours: 4)),
      ),
    ],
  ),
  _Participant(
    name: 'Bruno',
    expenses: [
      _ParticipantExpense(
        title: '晚餐烧烤',
        amount: 64.3,
        category: '餐饮',
        timestamp: DateTime.now().subtract(Duration(hours: 20)),
        paymentMethod: 'Mastercard',
      ),
      _ParticipantExpense(
        title: '高速路费',
        amount: 22.4,
        category: '油费',
        timestamp: DateTime.now().subtract(Duration(days: 2, hours: 2)),
      ),
    ],
  ),
  _Participant(
    name: 'Celine',
    expenses: [
      _ParticipantExpense(
        title: 'Airbnb 预定',
        amount: 210,
        category: '住宿',
        timestamp: DateTime.now().subtract(Duration(days: 1, hours: 12)),
        note: '两晚海边房',
      ),
      _ParticipantExpense(
        title: '早餐烘焙坊',
        amount: 28.9,
        category: '餐饮',
        timestamp: DateTime.now().subtract(Duration(hours: 10)),
      ),
      _ParticipantExpense(
        title: '观光门票',
        amount: 48,
        category: '门票',
        timestamp: DateTime.now().subtract(Duration(days: 3)),
      ),
    ],
  ),
  _Participant(
    name: 'Diego',
    expenses: [
      _ParticipantExpense(
        title: '夜宵零食',
        amount: 18.6,
        category: '餐饮',
        timestamp: DateTime.now().subtract(Duration(hours: 5)),
      ),
      _ParticipantExpense(
        title: '滑翔伞体验',
        amount: 160,
        category: '其他',
        timestamp: DateTime.now().subtract(Duration(days: 2, hours: 8)),
        paymentMethod: 'Amex',
        note: '帮大家预定体验',
      ),
    ],
  ),
];

