import '../entities/preset.dart';

/// Abstraction over persisted per-effect presets.
abstract class PresetRepository {
  /// Returns the presets saved for the effect named [effectName]
  /// (empty if none).
  List<Preset> presetsFor(String effectName);

  /// Persists [presets] for the effect named [effectName].
  Future<void> savePresets(String effectName, List<Preset> presets);
}
