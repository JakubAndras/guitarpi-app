// Core unit tests for PedalboardNotifier using a ProviderContainer with a
// mocktail mock EffectTransport and a fake PresetRepository. No real Bluetooth,
// no device, no plugins.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bc_ui_flutter/domain/entities/parameter.dart';
import 'package:bc_ui_flutter/domain/entities/pedalboard.dart';
import 'package:bc_ui_flutter/domain/entities/preset.dart';
import 'package:bc_ui_flutter/domain/repositories/effect_transport.dart';
import 'package:bc_ui_flutter/domain/repositories/preset_repository.dart';
import 'package:bc_ui_flutter/core/di/providers.dart';
import 'package:bc_ui_flutter/presentation/connection/connection_notifier.dart';
import 'package:bc_ui_flutter/presentation/pedalboard/pedalboard_notifier.dart';

class MockEffectTransport extends Mock implements EffectTransport {}

class FakePresetRepository implements PresetRepository {
  @override
  List<Preset> presetsFor(String effectName) => [];

  @override
  Future<void> savePresets(String effectName, List<Preset> presets) async {}
}

void main() {
  setUpAll(() {
    // Fallback for the Map<String,dynamic> argument used with any().
    registerFallbackValue(<String, dynamic>{});
  });

  late MockEffectTransport transport;
  late ProviderContainer container;
  // The notifier instance is stable for the container created in setUp.
  late PedalboardNotifier notifier;
  // Reads the current state freshly on each access.
  PedalboardState state() => container.read(pedalboardProvider);

  ProviderContainer makeContainer() {
    final c = ProviderContainer(
      overrides: [
        effectTransportProvider.overrideWithValue(transport),
        presetRepositoryProvider.overrideWithValue(FakePresetRepository()),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  setUp(() {
    transport = MockEffectTransport();
    when(() => transport.isSupported).thenReturn(true);
    when(() => transport.isConnected).thenReturn(true);
    when(() => transport.connect(any())).thenAnswer((_) async => true);
    when(() => transport.send(any())).thenReturn(null);
    container = makeContainer();
    notifier = container.read(pedalboardProvider.notifier);
  });

  group('initial state', () {
    test('empty chain, inactive', () {
      expect(state().isActive, isFalse);
      expect(state().chain, isEmpty);
    });
  });

  group('addEffect / removeEffect', () {
    test('adds to the FRONT (index 0)', () {
      notifier.addEffect('Echo');
      notifier.addEffect('Delay');
      expect(state().chain.map((e) => e.name).toList(), ['Delay', 'Echo']);
    });

    test('ignores duplicates', () {
      notifier.addEffect('Echo');
      notifier.addEffect('Echo');
      expect(state().chain.map((e) => e.name).toList(), ['Echo']);
    });

    test('ignores unknown effect names', () {
      notifier.addEffect('Nonexistent');
      expect(state().chain, isEmpty);
    });

    test('removeEffect removes the effect', () {
      notifier.addEffect('Echo');
      notifier.addEffect('Delay');
      notifier.removeEffect('Echo');
      expect(state().chain.map((e) => e.name).toList(), ['Delay']);
    });
  });

  group('moveLeft / moveRight', () {
    // Build chain order [A, B, C] where A was added last.
    void buildThree() {
      notifier.addEffect('Reverb'); // -> [Reverb]
      notifier.addEffect('Delay'); // -> [Delay, Reverb]
      notifier.addEffect('Echo'); // -> [Echo, Delay, Reverb]
    }

    test('moveLeft moves an effect one step towards the front', () {
      buildThree();
      expect(state().chain.map((e) => e.name).toList(),
          ['Echo', 'Delay', 'Reverb']);
      notifier.moveLeft('Reverb');
      expect(state().chain.map((e) => e.name).toList(),
          ['Echo', 'Reverb', 'Delay']);
    });

    test('moveLeft on the front element is a no-op', () {
      buildThree();
      notifier.moveLeft('Echo');
      expect(state().chain.map((e) => e.name).toList(),
          ['Echo', 'Delay', 'Reverb']);
    });

    test('moveRight moves an effect one step towards the back', () {
      buildThree();
      notifier.moveRight('Echo');
      expect(state().chain.map((e) => e.name).toList(),
          ['Delay', 'Echo', 'Reverb']);
    });

    test('moveRight on the back element is a no-op', () {
      buildThree();
      notifier.moveRight('Reverb');
      expect(state().chain.map((e) => e.name).toList(),
          ['Echo', 'Delay', 'Reverb']);
    });
  });

  group('togglePedalboard', () {
    test('flips isActive', () {
      expect(state().isActive, isFalse);
      notifier.togglePedalboard();
      expect(state().isActive, isTrue);
      notifier.togglePedalboard();
      expect(state().isActive, isFalse);
    });
  });

  group('setParameter', () {
    test('updates the targeted parameter value only', () {
      notifier.addEffect('Echo'); // params LEVEL, TIME
      notifier.setParameter('Echo', 'TIME', 55);
      final echo = state().chain.firstWhere((e) => e.name == 'Echo');
      expect(echo.parameters,
          contains(const Parameter(name: 'TIME', value: 55)));
      expect(echo.parameters,
          contains(const Parameter(name: 'LEVEL', value: 0)));
    });
  });

  group('applyPreset', () {
    test('applies preset parameter values to the effect', () {
      notifier.addEffect('Echo');
      notifier.applyPreset('Echo', const [
        Parameter(name: 'LEVEL', value: 12),
        Parameter(name: 'TIME', value: 34),
      ]);
      final echo = state().chain.firstWhere((e) => e.name == 'Echo');
      expect(echo.parameters, const [
        Parameter(name: 'LEVEL', value: 12),
        Parameter(name: 'TIME', value: 34),
      ]);
    });
  });

  // ---- SEND-TRIGGER SEMANTICS (the critical part) --------------------------
  group('send semantics', () {
    test('togglePedalboard ALWAYS sends (both directions)', () {
      notifier.togglePedalboard(); // off -> on
      notifier.togglePedalboard(); // on -> off
      verify(() => transport.send(any())).called(2);
    });

    test('addEffect sends only when the board is active', () {
      notifier.addEffect('Echo'); // board inactive
      verifyNever(() => transport.send(any()));

      notifier.togglePedalboard(); // -> active (1 send)
      clearInteractions(transport);

      notifier.addEffect('Delay'); // active -> sends
      verify(() => transport.send(any())).called(1);
    });

    test('removeEffect sends only when the board is active', () {
      notifier.addEffect('Echo');
      notifier.removeEffect('Echo'); // inactive -> no send
      verifyNever(() => transport.send(any()));

      notifier.addEffect('Echo');
      notifier.togglePedalboard(); // active
      clearInteractions(transport);
      notifier.removeEffect('Echo'); // active -> sends
      verify(() => transport.send(any())).called(1);
    });

    test('moveLeft/moveRight send only when the board is active', () {
      notifier.addEffect('Reverb');
      notifier.addEffect('Delay');
      notifier.addEffect('Echo');
      notifier.moveLeft('Reverb'); // inactive
      notifier.moveRight('Echo'); // inactive
      verifyNever(() => transport.send(any()));

      notifier.togglePedalboard(); // active
      clearInteractions(transport);
      notifier.moveLeft('Reverb'); // active -> sends
      notifier.moveRight('Echo'); // active -> sends
      verify(() => transport.send(any())).called(2);
    });

    test('setEffectActive sends only when the board is active', () {
      notifier.addEffect('Echo');
      notifier.setEffectActive('Echo', true); // board inactive -> no send
      verifyNever(() => transport.send(any()));

      notifier.togglePedalboard(); // active
      clearInteractions(transport);
      notifier.setEffectActive('Echo', false); // active -> sends
      verify(() => transport.send(any())).called(1);
    });

    test(
        'setParameter sends only when board active AND that effect active',
        () {
      notifier.addEffect('Echo');

      // board inactive, effect inactive -> no send
      notifier.setParameter('Echo', 'LEVEL', 10);
      verifyNever(() => transport.send(any()));

      // board active, effect still inactive -> no send
      notifier.togglePedalboard();
      clearInteractions(transport);
      notifier.setParameter('Echo', 'LEVEL', 20);
      verifyNever(() => transport.send(any()));

      // board active AND effect active -> sends
      notifier.setEffectActive('Echo', true); // this itself sends once
      clearInteractions(transport);
      notifier.setParameter('Echo', 'LEVEL', 30);
      verify(() => transport.send(any())).called(1);
    });

    test('applyPreset sends only when board active AND effect active', () {
      notifier.addEffect('Echo');
      notifier.applyPreset('Echo', const [Parameter(name: 'LEVEL', value: 5)]);
      verifyNever(() => transport.send(any()));

      notifier.togglePedalboard();
      notifier.setEffectActive('Echo', true);
      clearInteractions(transport);
      notifier
          .applyPreset('Echo', const [Parameter(name: 'LEVEL', value: 9)]);
      verify(() => transport.send(any())).called(1);
    });
  });

  group('ConnectionNotifier', () {
    test('connect() calls transport and exposes connected via AsyncData(true)',
        () async {
      await container.read(connectionProvider.notifier).connect('AA:BB:CC:DD:EE:FF');
      verify(() => transport.connect('AA:BB:CC:DD:EE:FF')).called(1);
      expect(container.read(connectionProvider).valueOrNull, isTrue);
    });

    test('a false connect result surfaces as AsyncData(false)', () async {
      when(() => transport.connect(any())).thenAnswer((_) async => false);
      await container.read(connectionProvider.notifier).connect('AA:BB:CC:DD:EE:FF');
      expect(container.read(connectionProvider).valueOrNull, isFalse);
    });

    test('a thrown connect error surfaces as AsyncError (guarded, no throw)',
        () async {
      when(() => transport.connect(any())).thenThrow(Exception('boom'));
      await container.read(connectionProvider.notifier).connect('AA:BB:CC:DD:EE:FF');
      expect(container.read(connectionProvider).hasError, isTrue);
    });
  });
}
