import 'package:flutter/material.dart';

import '../presentation/bubble_expense_page.dart';

class ExpensesRoutes {
  const ExpensesRoutes._();

  static Route<void> bubble({
    required String eventId,
    String? title,
  }) {
    return MaterialPageRoute<void>(
      builder: (context) => BubbleExpensePage(eventId: eventId, title: title),
      settings: RouteSettings(name: '/events/$eventId/expenses'),
    );
  }
}
