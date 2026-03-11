import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:videoader/main.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: VideoaderApp(),
      ),
    );

    expect(find.text('视频下载'), findsOneWidget);
    expect(find.text('配置'), findsOneWidget);
    expect(find.byIcon(Icons.download_rounded), findsOneWidget);
    expect(find.byIcon(Icons.settings_rounded), findsOneWidget);
  });

  testWidgets('NavigationRail works correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: VideoaderApp(),
      ),
    );

    expect(find.text('视频下载'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pumpAndSettle();

    expect(find.text('环境配置'), findsOneWidget);
  });
}
