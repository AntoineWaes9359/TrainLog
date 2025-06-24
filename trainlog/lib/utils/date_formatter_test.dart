import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'date_formatter.dart';

void main() {
  group('DateFormatter Tests', () {
    final testDate = DateTime(2024, 1, 15, 14, 30); // 15 janvier 2024, 14:30

    testWidgets(
        'formatShortDateOnly returns correct format for different locales',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              // Test français
              final frenchResult =
                  DateFormatter.formatShortDateOnly(context, testDate);
              expect(frenchResult, '15/01/2024');

              // Test anglais US
              final englishResult =
                  DateFormatter.formatShortDateOnly(context, testDate);
              expect(englishResult, '01/15/2024');

              return Container();
            },
          ),
          localizationsDelegates: const [],
          locale: const Locale('fr', 'FR'),
        ),
      );
    });

    testWidgets('formatTime returns correct format for different locales',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              // Test français (format 24h)
              final frenchResult = DateFormatter.formatTime(context, testDate);
              expect(frenchResult, '14:30');

              // Test anglais US (format 12h)
              final englishResult = DateFormatter.formatTime(context, testDate);
              expect(englishResult, '2:30 PM');

              return Container();
            },
          ),
          localizationsDelegates: const [],
          locale: const Locale('en', 'US'),
        ),
      );
    });

    testWidgets(
        'formatShortDateWithTime returns correct format for different locales',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              // Test français
              final frenchResult =
                  DateFormatter.formatShortDateWithTime(context, testDate);
              expect(frenchResult, '15/01/2024 14:30');

              // Test anglais US
              final englishResult =
                  DateFormatter.formatShortDateWithTime(context, testDate);
              expect(englishResult, '01/15/2024 2:30 PM');

              return Container();
            },
          ),
          localizationsDelegates: const [],
          locale: const Locale('fr', 'FR'),
        ),
      );
    });
  });
}
