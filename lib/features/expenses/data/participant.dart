class Participant {
  const Participant({
    required this.name,
    required this.expenses,
    this.isHost = false,
  });

  final String name;
  final List<ParticipantExpense> expenses;
  final bool isHost;

  /// 总支付金额（实际支付的费用总和）
  double get totalPaid => expenses.fold<double>(
        0,
        (sum, expense) => sum + expense.amount,
      );

  /// 总应承担金额（所有费用中应承担的部分）
  double totalOwed(List<Participant> allParticipants) {
    double total = 0;
    for (final participant in allParticipants) {
      for (final expense in participant.expenses) {
        if (expense.sharedBy.contains(name)) {
          total += expense.amount / expense.sharedBy.length;
        }
      }
    }
    return total;
  }

  /// 差额（正数表示应收，负数表示应付）
  double balance(List<Participant> allParticipants) {
    return totalPaid - totalOwed(allParticipants);
  }
}

class ParticipantExpense {
  const ParticipantExpense({
    required this.title,
    required this.amount,
    required this.category,
    required this.timestamp,
    required this.paidBy, // 支付人
    required this.sharedBy, // 参与分摊的成员列表
    this.paymentMethod,
    this.note,
  });

  final String title;
  final double amount;
  final String category;
  final DateTime timestamp;
  final String paidBy; // 支付人
  final List<String> sharedBy; // 参与分摊的成员列表（包含支付人）
  final String? paymentMethod;
  final String? note;

  /// 每个成员应承担的金额
  double get sharePerPerson => amount / sharedBy.length;

  /// 检查某个成员是否参与此费用
  bool isSharedBy(String participantName) => sharedBy.contains(participantName);
}
