import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/persistence/shared_prefs_preset_repository.dart';
import '../../data/transport/bluetooth_classic_transport.dart';
import '../../data/transport/unsupported_transport.dart';
import '../../domain/repositories/effect_transport.dart';
import '../../domain/repositories/preset_repository.dart';

/// Infrastructure (implementation-wiring) providers. These bind domain
/// interfaces to their data-layer implementations, so the `domain/` and `data/`
/// layers themselves stay Riverpod-free. Notifier providers do NOT live here —
/// they are co-located next to their notifier.

/// Channel used to push pedalboard state to the Pi: the Android Bluetooth
/// Classic transport on Android, a safe no-op transport on every other
/// platform.
final effectTransportProvider = Provider<EffectTransport>((ref) {
  if (defaultTargetPlatform == TargetPlatform.android) {
    return BluetoothClassicTransport();
  }
  return UnsupportedTransport();
});

/// Persisted per-effect presets.
final presetRepositoryProvider = Provider<PresetRepository>((ref) {
  return SharedPrefsPresetRepository();
});
