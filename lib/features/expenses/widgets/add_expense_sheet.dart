import 'package:crew_app/features/expenses/data/participant.dart';
import 'package:crew_app/shared/utils/number_format_helper.dart';
import 'package:flutter/material.dart';

class AddExpenseResult {
  const AddExpenseResult({
    required this.paidBy,
    required this.sharedBy,
    required this.amount,
    required this.title,
    required this.category,
    this.paymentMethod,
    this.note,
  });

  final String paidBy;
  final List<String> sharedBy;
  final double amount;
  final String title;
  final String category;
  final String? paymentMethod;
  final String? note;
}

class AddExpenseSheet extends StatefulWidget {
  const AddExpenseSheet({
    super.key,
    required this.participants,
  });

  final List<Participant> participants;

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  String? _selectedPayer;
  final Set<String> _selectedParticipants = {};
  String _category = '餐饮';
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _paymentMethodController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.participants.isNotEmpty) {
      _selectedPayer = widget.participants.first.name;
      // 默认选择所有成员参与分摊
      _selectedParticipants.addAll(widget.participants.map((p) => p.name));
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _paymentMethodController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  double? get _amount {
    final text = _amountController.text.trim();
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  double get _sharePerPerson {
    final amount = _amount;
    if (amount == null || _selectedParticipants.isEmpty) return 0;
    return amount / _selectedParticipants.length;
  }

  void _toggleParticipant(String name) {
    setState(() {
      if (_selectedParticipants.contains(name)) {
        if (_selectedParticipants.length > 1) {
          _selectedParticipants.remove(name);
        }
      } else {
        _selectedParticipants.add(name);
      }
    });
  }

  void _selectAll() {
    setState(() {
      _selectedParticipants.clear();
      _selectedParticipants.addAll(widget.participants.map((p) => p.name));
    });
  }

  void _deselectAll() {
    setState(() {
      _selectedParticipants.clear();
      if (_selectedPayer != null) {
        _selectedParticipants.add(_selectedPayer!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final dragHandleColor = isDark ? Colors.white24 : Colors.grey.shade300;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // 拖拽手柄
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Center(
                  child: Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: dragHandleColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              // 标题
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(
                  children: [
                    Text(
                      '添加费用',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (_amount != null && _selectedParticipants.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '每人 ${NumberFormatHelper.formatCurrencyCompactIfLarge(_sharePerPerson)}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // 表单内容
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    // 支付人选择
                    DropdownButtonFormField<String>(
                      value: _selectedPayer,
                      decoration: const InputDecoration(
                        labelText: '支付人',
                        hintText: '选择支付此费用的人',
                        prefixIcon: Icon(Icons.person),
                      ),
                      items: widget.participants
                          .map(
                            (participant) => DropdownMenuItem<String>(
                              value: participant.name,
                              child: Text(participant.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPayer = value;
                          // 如果支付人不在参与列表中，自动添加
                          if (value != null && !_selectedParticipants.contains(value)) {
                            _selectedParticipants.add(value);
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    // 金额输入
                    TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: '金额 (€)',
                        hintText: '0.00',
                        prefixIcon: Icon(Icons.euro),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 20),
                    // 费用说明
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: '费用说明',
                        hintText: '例如：第一天加油',
                        prefixIcon: Icon(Icons.description),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 类别选择
                    DropdownButtonFormField<String>(
                      value: _category,
                      decoration: const InputDecoration(
                        labelText: '类别',
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: const [
                        DropdownMenuItem(value: '餐饮', child: Text('餐饮')),
                        DropdownMenuItem(value: '油费', child: Text('油费')),
                        DropdownMenuItem(value: '住宿', child: Text('住宿')),
                        DropdownMenuItem(value: '门票', child: Text('门票')),
                        DropdownMenuItem(value: '其他', child: Text('其他')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _category = value ?? _category;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    // 参与分摊成员
                    Text(
                      '参与分摊成员',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // 快速选择按钮
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: _selectAll,
                          icon: const Icon(Icons.select_all, size: 18),
                          label: const Text('全选'),
                        ),
                        TextButton.icon(
                          onPressed: _deselectAll,
                          icon: const Icon(Icons.deselect, size: 18),
                          label: const Text('仅支付人'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // 成员选择网格
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: widget.participants.map((participant) {
                        final isSelected = _selectedParticipants.contains(participant.name);
                        final isPayer = participant.name == _selectedPayer;
                        return FilterChip(
                          selected: isSelected,
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isPayer)
                                const Padding(
                                  padding: EdgeInsets.only(right: 4),
                                  child: Icon(Icons.account_balance_wallet, size: 16),
                                ),
                              Text(participant.name),
                            ],
                          ),
                          onSelected: (selected) {
                            if (isPayer && !selected) {
                              // 支付人必须参与分摊
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('支付人必须参与分摊'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              return;
                            }
                            _toggleParticipant(participant.name);
                          },
                          avatar: isSelected
                              ? const Icon(Icons.check_circle, size: 18)
                              : const Icon(Icons.radio_button_unchecked, size: 18),
                        );
                      }).toList(),
                    ),
                    if (_amount != null && _selectedParticipants.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      // 分摊预览卡片
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '分摊预览',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '总金额：${NumberFormatHelper.formatCurrencyCompactIfLarge(_amount!)}',
                              style: theme.textTheme.bodyMedium,
                            ),
                            Text(
                              '参与人数：${_selectedParticipants.length} 人',
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '每人应承担：${NumberFormatHelper.formatCurrencyCompactIfLarge(_sharePerPerson)}',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    // 支付方式（可选）
                    TextField(
                      controller: _paymentMethodController,
                      decoration: const InputDecoration(
                        labelText: '支付方式（可选）',
                        hintText: '例如：Visa, 微信, 支付宝',
                        prefixIcon: Icon(Icons.payment),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 备注（可选）
                    TextField(
                      controller: _noteController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: '备注（可选）',
                        hintText: '添加备注信息',
                        prefixIcon: Icon(Icons.note),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // 保存按钮
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _canSave() ? _saveExpense : null,
                        icon: const Icon(Icons.save),
                        label: const Text('保存费用'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _canSave() {
    return _selectedPayer != null &&
        _amount != null &&
        _amount! > 0 &&
        _titleController.text.trim().isNotEmpty &&
        _selectedParticipants.isNotEmpty;
  }

  void _saveExpense() {
    if (!_canSave()) return;

    final result = AddExpenseResult(
      paidBy: _selectedPayer!,
      sharedBy: _selectedParticipants.toList(),
      amount: _amount!,
      title: _titleController.text.trim(),
      category: _category,
      paymentMethod: _paymentMethodController.text.trim().isEmpty
          ? null
          : _paymentMethodController.text.trim(),
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    );

    Navigator.of(context).pop(result);
  }
}
