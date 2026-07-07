import 'dart:convert';

import '../../domain/entities/parameter.dart';
import '../../domain/entities/preset.dart';
import '../../domain/repositories/preset_repository.dart';
import '../../model/EffectPresetModel.dart';
import '../../utils/PresetSharedPreferences.dart';

/// [PresetRepository] backed by the existing `shared_preferences` scheme.
///
/// It reads/writes through [PresetSharedPreferences] and the legacy
/// [EffectPresetModel] JSON so previously stored presets remain compatible.
/// Storage key = effect name; value = JSON of `EffectPresetModel`.
class SharedPrefsPresetRepository implements PresetRepository {
  @override
  List<Preset> presetsFor(String effectName) {
    final jsonString = PresetSharedPreferences.getAllEffectPresets(effectName);
    if (jsonString == null) return [];
    final model = EffectPresetModel.fromJson(jsonDecode(jsonString));
    return model.presets.map(_toDomainPreset).toList();
  }

  @override
  Future<void> savePresets(String effectName, List<Preset> presets) async {
    final model = EffectPresetModel(
      effectName,
      presets.map(_toModelPreset).toList(),
    );
    await PresetSharedPreferences.setAllEffectPresets(jsonEncode(model));
  }

  Preset _toDomainPreset(PresetModel model) {
    return Preset(
      name: model.name,
      parameters: model.parameters
          .map((p) => Parameter(name: p.name, value: p.value))
          .toList(),
    );
  }

  PresetModel _toModelPreset(Preset preset) {
    return PresetModel(
      preset.name,
      preset.parameters
          .map((p) => ParameterModel(p.name, p.value))
          .toList(),
    );
  }
}
