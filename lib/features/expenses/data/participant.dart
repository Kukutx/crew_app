class Participant {
  const Participant({
    required this.name,
    required this.expenses,
    this.isHost = false,
  });

  final String name;
  final List<ParticipantExpense> expenses;
  final bool isHost;

  double get total => expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
}

class ParticipantExpense {
  const ParticipantExpense({
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
