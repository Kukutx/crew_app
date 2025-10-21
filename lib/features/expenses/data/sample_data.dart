import 'package:crew_app/features/expenses/data/participant.dart';

final List<Participant> sampleParticipants = [
  Participant(
    name: 'Alice',
    isCreator: true,
    expenses: [
      ParticipantExpense(
        title: '第一天加油',
        amount: 86.5,
        category: '油费',
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        paymentMethod: 'Visa',
      ),
      ParticipantExpense(
        title: '路边咖啡',
        amount: 14.2,
        category: '餐饮',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        note: '和大家一起喝咖啡',
      ),
      ParticipantExpense(
        title: '营地预定',
        amount: 120,
        category: '住宿',
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
      ),
    ],
  ),
  Participant(
    name: 'Bruno',
    expenses: [
      ParticipantExpense(
        title: '晚餐烧烤',
        amount: 64.3,
        category: '餐饮',
        timestamp: DateTime.now().subtract(const Duration(hours: 20)),
        paymentMethod: 'Mastercard',
      ),
      ParticipantExpense(
        title: '高速路费',
        amount: 22.4,
        category: '油费',
        timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 2)),
      ),
    ],
  ),
  Participant(
    name: 'Celine',
    expenses: [
      ParticipantExpense(
        title: 'Airbnb 预定',
        amount: 210,
        category: '住宿',
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 12)),
        note: '两晚海边房',
      ),
      ParticipantExpense(
        title: '早餐烘焙坊',
        amount: 28.9,
        category: '餐饮',
        timestamp: DateTime.now().subtract(const Duration(hours: 10)),
      ),
      ParticipantExpense(
        title: '观光门票',
        amount: 48,
        category: '门票',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ],
  ),
  Participant(
    name: 'Diego',
    expenses: [
      ParticipantExpense(
        title: '夜宵零食',
        amount: 18.6,
        category: '餐饮',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      ParticipantExpense(
        title: '滑翔伞体验',
        amount: 160,
        category: '其他',
        timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 8)),
        paymentMethod: 'Amex',
        note: '帮大家预定体验',
      ),
    ],
  ),
];
