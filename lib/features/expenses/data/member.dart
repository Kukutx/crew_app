/// 费用成员模型
class Member {
  const Member({
    required this.name,
    required this.expenses,
    this.isHost = false,
  });

  final String name;
  final List<MemberExpense> expenses;
  final bool isHost;

  /// 总支付金额（实际支付的费用总和）
  double get totalPaid => expenses.fold<double>(
        0,
        (sum, expense) => sum + expense.amount,
      );

  /// 总应承担金额（所有费用中应承担的部分）
  /// 优化：使用 Map 缓存计算结果，避免重复计算
  double totalOwed(List<Member> allMembers) {
    // 使用 Map 缓存每个费用的分摊结果
    final expenseShareCache = <String, double>{};
    double total = 0;
    
    for (final member in allMembers) {
      for (final expense in member.expenses) {
        // 使用费用标题作为缓存键（如果标题可能重复，可以改用 expense 对象）
        final cacheKey = '${member.name}_${expense.title}_${expense.amount}';
        if (!expenseShareCache.containsKey(cacheKey)) {
          expenseShareCache[cacheKey] = expense.amount / expense.sharedBy.length;
        }
        
        if (expense.sharedBy.contains(name)) {
          total += expenseShareCache[cacheKey]!;
        }
      }
    }
    return total;
  }

  /// 差额（正数表示应收，负数表示应付）
  double balance(List<Member> allMembers) {
    return totalPaid - totalOwed(allMembers);
  }
}

/// 成员费用模型
class MemberExpense {
  const MemberExpense({
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
  double get sharePerPerson => sharedBy.isEmpty ? 0 : amount / sharedBy.length;

  /// 检查某个成员是否参与此费用
  bool isSharedBy(String memberName) => sharedBy.contains(memberName);
}

