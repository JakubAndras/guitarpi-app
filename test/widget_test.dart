// Minimal app smoke test.
//
// We pump the real app but force a non-Android target platform so the
// Bluetooth-only code paths (ConnectionPage.initState, effectTransportProvider)
// resolve to their no-op / unsupported variants and never touch a plugin. The
// transport is additionally overridden with a fake for belt-and-braces, and
// SharedPreferences is seeded so the preset repository is safe to construct.
//
// The pure wire-format serializer has dedicated coverage in
// test/data/pedalboard_wire_dto_test.dart.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bc_ui_flutter/app.dart';
import 'package:bc_ui_flutter/domain/repositories/effect_transport.dart';
import 'package:bc_ui_flutter/core/di/providers.dart';
import 'package:bc_ui_flutter/utils/PresetSharedPreferences.dart';

class MockEffectTransport extends Mock implements EffectTransport {}

void main() {
  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PresetSharedPreferences.init();
  });

  testWidgets('app pumps and shows the bottom navigation', (tester) async {
    // Force a non-Android platform so Bluetooth paths (ConnectionPage
    // initState) resolve to no-ops during the initial build. Reset before the
    // test body returns (framework asserts foundation debug vars are unset).
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    final transport = MockEffectTransport();
    when(() => transport.isSupported).thenReturn(false);
    when(() => transport.isConnected).thenReturn(false);
    when(() => transport.connect(any())).thenAnswer((_) async => false);
    when(() => transport.send(any())).thenReturn(null);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          effectTransportProvider.overrideWithValue(transport),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pump();

    // initState has run; reset the override before the body returns. `expect`
    // triggers no rebuild, so no Bluetooth path is re-evaluated afterwards.
    debugDefaultTargetPlatformOverride = null;

    // The three-tab bottom navigation from HomePage renders.
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });
}
