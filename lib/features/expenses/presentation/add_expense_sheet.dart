import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/expenses_repository.dart';
import '../data/models/expense.dart';

class AddExpenseSheet extends StatefulWidget {
  const AddExpenseSheet({
    super.key,
    required this.members,
    required this.onSubmit,
  });

  final List<Member> members;
  final Future<void> Function(AddExpenseRequest request) onSubmit;

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _shareControllers = <String, TextEditingController>{};
  final _formatter = NumberFormat.currency(symbol: '€');
  String? _payerId;
  final Set<String> _selectedParticipants = <String>{};
  bool _evenSplit = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    for (final controller in _shareControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 16),
              Text('新增消费', style: theme.textTheme.titleLarge),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: '标题',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '请输入标题';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: '金额 (€)',
                      ),
                      validator: (value) {
                        final amount = double.tryParse(value ?? '');
                        if (amount == null || amount <= 0) {
                          return '请输入大于 0 的金额';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _payerId,
                      decoration: const InputDecoration(labelText: '支付者'),
                      items: widget.members
                          .map(
                            (member) => DropdownMenuItem(
                              value: member.id,
                              child: Text(member.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _payerId = value;
                          if (value != null) {
                            _selectedParticipants.add(value);
                          }
                        });
                      },
                      validator: (value) => value == null ? '请选择支付者' : null,
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '参与者',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: widget.members
                          .map(
                            (member) => FilterChip(
                              label: Text(member.name),
                              selected: _selectedParticipants.contains(member.id),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedParticipants.add(member.id);
                                  } else {
                                    _selectedParticipants.remove(member.id);
                                    _shareControllers.remove(member.id)?.dispose();
                                  }
                                  if (!_selectedParticipants.contains(_payerId)) {
                                    _payerId = null;
                                  }
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile.adaptive(
                      title: const Text('均摊'),
                      value: _evenSplit,
                      onChanged: (value) {
                        setState(() {
                          _evenSplit = value;
                        });
                      },
                    ),
                    if (!_evenSplit)
                      Column(
                        children: _selectedParticipants
                            .map(
                              (memberId) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: TextFormField(
                                  controller: _shareControllers.putIfAbsent(
                                    memberId,
                                    () => TextEditingController(),
                                  ),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(
                                    labelText:
                                        '${widget.members.firstWhere((member) => member.id == memberId).name} 分摊金额 (€)',
                                  ),
                                  validator: (value) {
                                    if (!_evenSplit) {
                                      final amount = double.tryParse(value ?? '');
                                      if (amount == null || amount < 0) {
                                        return '请输入有效金额';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () {
                                Navigator.pop(context);
                              },
                        child: const Text('取消'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _isSubmitting ? null : _handleSubmit,
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('保存'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedParticipants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择至少一位参与者')),
      );
      return;
    }
    final amount = double.parse(_amountController.text);
    final shares = <ExpenseShare>[];
    if (_evenSplit) {
      final perPerson = amount / _selectedParticipants.length;
      for (final memberId in _selectedParticipants) {
        shares.add(
          ExpenseShare(
            memberId: memberId,
            assigned: perPerson,
            computed: perPerson,
          ),
        );
      }
    } else {
      double totalAssigned = 0;
      for (final memberId in _selectedParticipants) {
        final controller = _shareControllers[memberId];
        final value = double.tryParse(controller?.text ?? '');
        if (value == null || value < 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('请输入 ${_memberName(memberId)} 的有效金额')), 
          );
          return;
        }
        shares.add(
          ExpenseShare(
            memberId: memberId,
            assigned: value,
            computed: value,
          ),
        );
        totalAssigned += value;
      }
      if ((totalAssigned - amount).abs() > 0.01) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('自定义份额之和需等于 ${_formatter.format(amount)}')), 
        );
        return;
      }
    }
    final payerId = _payerId ?? _selectedParticipants.first;
    final request = AddExpenseRequest(
      title: _titleController.text.trim(),
      amount: amount,
      payerId: payerId,
      shares: shares,
    );
    setState(() {
      _isSubmitting = true;
    });
    try {
      await widget.onSubmit(request);
      if (mounted) {
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _memberName(String id) {
    return widget.members.firstWhere((member) => member.id == id).name;
  }
}
