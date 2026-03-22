import 'package:flutter_test/flutter_test.dart';

import 'package:form_flutter/main.dart';

void main() {
  testWidgets('renders the form package playground', (WidgetTester tester) async {
    await tester.pumpWidget(const FormFlutterApp());

    expect(find.text('form_flutter'), findsOneWidget);
    expect(find.text('A package direction for building serious Flutter forms.'), findsOneWidget);
    expect(find.text('Validate package flow'), findsOneWidget);
  });
}
