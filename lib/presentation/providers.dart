import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/persistence/shared_prefs_preset_repository.dart';
import '../data/transport/bluetooth_classic_transport.dart';
import '../data/transport/unsupported_transport.dart';
import '../domain/entities/pedalboard.dart';
import '../domain/repositories/effect_transport.dart';
import '../domain/repositories/preset_repository.dart';
import 'pedalboard/pedalboard_notifier.dart';

/// The channel used to push pedalboard state to the Pi. Returns the Android
/// Bluetooth Classic transport on Android, otherwise a safe no-op transport.
/// Replaces direct use of `flutter_bluetooth_serial` / `BluetoothServer`.
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

/// The address of the device the user chose to connect to. Replaces the old
/// `BluetoothServer.server` global static (we only need the address here).
final selectedDeviceAddressProvider = StateProvider<String?>((ref) => null);

/// Whether the transport is currently connected (best-effort). Set by
/// [PedalboardNotifier.connect].
final connectionStatusProvider = StateProvider<bool>((ref) => false);

/// The single source of truth for the pedalboard (active flag + ordered chain,
/// per-effect parameters and on/off state).
final pedalboardProvider =
    NotifierProvider<PedalboardNotifier, PedalboardState>(
  PedalboardNotifier.new,
);
