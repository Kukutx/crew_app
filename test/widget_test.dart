
import 'package:crew_app/app/view/crew_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Home navigation bar renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(CrewApp());

    expect(find.byIcon(Icons.event), findsOneWidget);
    expect(find.byIcon(Icons.map), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
  });
}
