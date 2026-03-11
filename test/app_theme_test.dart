import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sickandflutter/app/theme.dart';

void main() {
  test('AppTheme buttons only constrain height', () {
    final theme = AppTheme.light();
    final filledStyle = theme.filledButtonTheme.style;
    final outlinedStyle = theme.outlinedButtonTheme.style;

    expect(
      filledStyle?.minimumSize?.resolve(<WidgetState>{}),
      const Size(0, 48),
    );
    expect(
      outlinedStyle?.minimumSize?.resolve(<WidgetState>{}),
      const Size(0, 48),
    );
  });
}
