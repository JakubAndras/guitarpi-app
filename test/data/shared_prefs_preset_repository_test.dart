// Round-trip test for the shared_preferences-backed preset repository.
//
// The repo reads/writes through the existing PresetSharedPreferences static,
// which must be `init()`-ed against a SharedPreferences instance. We seed an
// empty in-memory store with SharedPreferences.setMockInitialValues({}).

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bc_ui_flutter/domain/entities/parameter.dart';
import 'package:bc_ui_flutter/domain/entities/preset.dart';
import 'package:bc_ui_flutter/data/persistence/shared_prefs_preset_repository.dart';
import 'package:bc_ui_flutter/utils/PresetSharedPreferences.dart';

void main() {
  // Required so the SharedPreferences mock method channel is available.
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPrefsPresetRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PresetSharedPreferences.init();
    repo = SharedPrefsPresetRepository();
  });

  test('presetsFor returns empty when nothing is stored', () {
    expect(repo.presetsFor('Echo'), isEmpty);
  });

  test('round-trips saved presets back to domain Presets', () async {
    final presets = [
      const Preset(
        name: 'Clean',
        parameters: [
          Parameter(name: 'LEVEL', value: 10),
          Parameter(name: 'TIME', value: 20),
        ],
      ),
      const Preset(
        name: 'Wild',
        parameters: [
          Parameter(name: 'LEVEL', value: 90),
          Parameter(name: 'TIME', value: 80),
        ],
      ),
    ];

    await repo.savePresets('Echo', presets);

    final loaded = repo.presetsFor('Echo');
    expect(loaded, presets);
  });

  test('presets are namespaced per effect name', () async {
    await repo.savePresets('Echo', const [
      Preset(name: 'E1', parameters: [Parameter(name: 'LEVEL', value: 1)]),
    ]);
    await repo.savePresets('Delay', const [
      Preset(name: 'D1', parameters: [Parameter(name: 'LEVEL', value: 2)]),
    ]);

    expect(repo.presetsFor('Echo').single.name, 'E1');
    expect(repo.presetsFor('Delay').single.name, 'D1');
    expect(repo.presetsFor('Fuzz'), isEmpty);
  });
}
