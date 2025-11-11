import 'package:crew_app/features/expenses/data/member.dart';

final List<Member> sampleMembers = [
  Member(
    name: 'Alice',
    isHost: true,
    expenses: [
      MemberExpense(
        title: '第一天加油',
        amount: 86.5,
        category: '油费',
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        paidBy: 'Alice',
        sharedBy: ['Alice', 'Bruno', 'Celine'], // 三人均摊油费
        paymentMethod: 'Visa',
      ),
      MemberExpense(
        title: '路边咖啡',
        amount: 14.2,
        category: '餐饮',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        paidBy: 'Alice',
        sharedBy: ['Alice', 'Bruno', 'Celine'], // 大家一起喝咖啡
        note: '和大家一起喝咖啡',
      ),
      MemberExpense(
        title: '营地预定',
        amount: 120,
        category: '住宿',
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
        paidBy: 'Alice',
        sharedBy: ['Alice', 'Bruno', 'Celine'], // 三人均摊住宿
      ),
    ],
  ),
  Member(
    name: 'Bruno',
    expenses: [
      MemberExpense(
        title: '晚餐烧烤',
        amount: 64.3,
        category: '餐饮',
        timestamp: DateTime.now().subtract(const Duration(hours: 20)),
        paidBy: 'Bruno',
        sharedBy: ['Alice', 'Bruno', 'Celine'], // 三人均摊晚餐
        paymentMethod: 'Mastercard',
      ),
      MemberExpense(
        title: '高速路费',
        amount: 22.4,
        category: '油费',
        timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 2)),
        paidBy: 'Bruno',
        sharedBy: ['Alice', 'Bruno', 'Celine'], // 三人均摊路费
      ),
    ],
  ),
  Member(
    name: 'Celine',
    expenses: [
      MemberExpense(
        title: 'Airbnb 预定',
        amount: 210,
        category: '住宿',
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 12)),
        paidBy: 'Celine',
        sharedBy: ['Alice', 'Bruno', 'Celine'], // 三人均摊住宿
        note: '两晚海边房',
      ),
      MemberExpense(
        title: '早餐烘焙坊',
        amount: 28.9,
        category: '餐饮',
        timestamp: DateTime.now().subtract(const Duration(hours: 10)),
        paidBy: 'Celine',
        sharedBy: ['Celine'], // 只有Celine吃早餐
      ),
      MemberExpense(
        title: '观光门票',
        amount: 48,
        category: '门票',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        paidBy: 'Celine',
        sharedBy: ['Alice', 'Bruno', 'Celine'], // 三人均摊门票
      ),
    ],
  ),
  // Participant(
  //   name: 'Diego',
  //   expenses: [
  //     ParticipantExpense(
  //       title: '夜宵零食',
  //       amount: 18.6,
  //       category: '餐饮',
  //       timestamp: DateTime.now().subtract(const Duration(hours: 5)),
  //     ),
  //     ParticipantExpense(
  //       title: '滑翔伞体验',
  //       amount: 160,
  //       category: '其他',
  //       timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 8)),
  //       paymentMethod: 'Amex',
  //       note: '帮大家预定体验',
  //     ),
  //   ],
  // ),
  // Participant(
  //   name: 'Marco',
  //   expenses: [
  //     ParticipantExpense(
  //       title: '夜宵零食',
  //       amount: 18.6,
  //       category: '餐饮',
  //       timestamp: DateTime.now().subtract(const Duration(hours: 5)),
  //     ),
  //     ParticipantExpense(
  //       title: '滑翔伞体验',
  //       amount: 160,
  //       category: '其他',
  //       timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 8)),
  //       paymentMethod: 'Amex',
  //       note: '帮大家预定体验',
  //     ),
  //   ],
  // ),
  // Participant(
  //   name: 'Maria',
  //   expenses: [
  //     ParticipantExpense(
  //       title: '夜宵零食',
  //       amount: 18.6,
  //       category: '餐饮',
  //       timestamp: DateTime.now().subtract(const Duration(hours: 5)),
  //     ),
  //     ParticipantExpense(
  //       title: '滑翔伞体验',
  //       amount: 160,
  //       category: '其他',
  //       timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 8)),
  //       paymentMethod: 'Amex',
  //       note: '帮大家预定体验',
  //     ),
  //   ],
  // ),
  // Participant(
  //   name: 'Andrea',
  //   expenses: [
  //     ParticipantExpense(
  //       title: '夜宵零食',
  //       amount: 18.6,
  //       category: '餐饮',
  //       timestamp: DateTime.now().subtract(const Duration(hours: 5)),
  //     ),
  //     ParticipantExpense(
  //       title: '滑翔伞体验',
  //       amount: 160,
  //       category: '其他',
  //       timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 8)),
  //       paymentMethod: 'Amex',
  //       note: '帮大家预定体验',
  //     ),
  //   ],
  // ),
];
