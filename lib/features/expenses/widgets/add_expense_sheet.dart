import 'package:crew_app/features/expenses/data/participant.dart';
import 'package:flutter/material.dart';

class AddExpenseResult {
  const AddExpenseResult({
    required this.participant,
    required this.amountText,
    required this.title,
    required this.category,
  });

  final Participant? participant;
  final String amountText;
  final String title;
  final String category;
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
  late Participant? _selectedParticipant;
  late String _category;
  late final TextEditingController _amountController;
  late final TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _selectedParticipant = widget.participants.isEmpty ? null : widget.participants.first;
    _category = '餐饮';
    _amountController = TextEditingController();
    _titleController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
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
            '添加费用',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<Participant>(
            initialValue: _selectedParticipant,
            decoration: const InputDecoration(labelText: '支付人'),
            items: widget.participants
                .map(
                  (participant) => DropdownMenuItem<Participant>(
                    value: participant,
                    child: Text(participant.name),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedParticipant = value;
              });
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '金额 (€)',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: '费用说明',
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(labelText: '类别'),
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
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(
                  AddExpenseResult(
                    participant: _selectedParticipant,
                    amountText: _amountController.text,
                    title: _titleController.text,
                    category: _category,
                  ),
                );
              },
              child: const Text('保存'),
            ),
          ),
        ],
      ),
    );
  }
}
