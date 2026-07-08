import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';

/// Owns the Bluetooth connection lifecycle as an [AsyncValue]:
///
/// - `AsyncData(false)` — idle / not connected (initial),
/// - `AsyncLoading` — a connection attempt is in flight,
/// - `AsyncData(true)` — connected,
/// - `AsyncError` — the last attempt failed.
///
/// The selected device address is passed straight into [connect] rather than
/// held as separate global state, so this notifier is the single owner of all
/// connection state.
class ConnectionNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async => false;

  /// Attempt to connect to [address]. Reflects the outcome in [state] via
  /// [AsyncValue.guard] (never throws).
  Future<void> connect(String address) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(effectTransportProvider).connect(address),
    );
  }

  Future<void> disconnect() async {
    await ref.read(effectTransportProvider).disconnect();
    state = const AsyncData(false);
  }
}

/// Connection state, co-located with its notifier.
final connectionProvider =
    AsyncNotifierProvider<ConnectionNotifier, bool>(ConnectionNotifier.new);
