// test/widget/shared/gradient_button_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talent_bridge/shared/widgets/gradient_button.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  // ═══════════════════════════════════════════════════════
  // Rendering
  // ═══════════════════════════════════════════════════════
  group('GradientButton — Rendering', () {
    testWidgets('renders label text correctly', (t) async {
      await t.pumpWidget(_wrap(GradientButton(text: 'Sign In', onPressed: () {})));
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('renders icon when provided', (t) async {
      await t.pumpWidget(_wrap(GradientButton(
        text: 'Login',
        icon: Icons.login_rounded,
        onPressed: () {},
      )));
      expect(find.byIcon(Icons.login_rounded), findsOneWidget);
    });

    testWidgets('does not render an icon when icon is null', (t) async {
      await t.pumpWidget(_wrap(GradientButton(text: 'No Icon', onPressed: () {})));
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('shows CircularProgressIndicator when isLoading is true', (t) async {
      await t.pumpWidget(_wrap(
          const GradientButton(text: 'Loading...', isLoading: true)));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading...'), findsNothing);
    });

    testWidgets('hides spinner and shows text when isLoading is false', (t) async {
      await t.pumpWidget(_wrap(
          GradientButton(text: 'Submit', isLoading: false, onPressed: () {})));
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('expands to full width by default', (t) async {
      await t.pumpWidget(_wrap(GradientButton(text: 'Full Width', onPressed: () {})));
      final box = t.renderObject<RenderBox>(find.byType(GradientButton));
      expect(box.size.width, greaterThan(100));
    });

    testWidgets('respects custom height', (t) async {
      await t.pumpWidget(_wrap(
          GradientButton(text: 'Tall', height: 80, onPressed: () {})));
      // Find the outermost SizedBox that contains the button
      final sizedBoxes = find.byType(SizedBox).evaluate().toList();
      final hasTallBox = sizedBoxes.any((e) {
        final w = e.widget as SizedBox;
        return w.height == 80;
      });
      expect(hasTallBox, isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════
  // Interaction
  // ═══════════════════════════════════════════════════════
  group('GradientButton — Interaction', () {
    testWidgets('calls onPressed callback when tapped', (t) async {
      bool tapped = false;
      await t.pumpWidget(_wrap(
          GradientButton(text: 'Tap Me', onPressed: () => tapped = true)));
      await t.tap(find.byType(GradientButton));
      await t.pump();
      expect(tapped, isTrue);
    });

    testWidgets('does NOT call onPressed when isLoading is true', (t) async {
      bool tapped = false;
      await t.pumpWidget(_wrap(
        GradientButton(
          text: 'Loading',
          isLoading: true,
          onPressed: () => tapped = true,
        ),
      ));
      await t.tap(find.byType(GradientButton), warnIfMissed: false);
      await t.pump();
      expect(tapped, isFalse);
    });

    testWidgets('does NOT call onPressed when onPressed is null', (t) async {
      // Should not throw
      await t.pumpWidget(_wrap(const GradientButton(text: 'Disabled')));
      await t.tap(find.byType(GradientButton), warnIfMissed: false);
      await t.pump();
      expect(t.takeException(), isNull);
    });
  });

  // ═══════════════════════════════════════════════════════
  // Custom gradient
  // ═══════════════════════════════════════════════════════
  group('GradientButton — Custom Colors', () {
    testWidgets('accepts custom gradient colours without throwing', (t) async {
      await t.pumpWidget(_wrap(
        GradientButton(
          text: 'Custom',
          colors: const [Colors.purple, Colors.deepPurple],
          onPressed: () {},
        ),
      ));
      expect(find.text('Custom'), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  });
}
