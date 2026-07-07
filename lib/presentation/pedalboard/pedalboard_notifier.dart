import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/effect_catalog.dart';
import '../../data/dto/pedalboard_wire_dto.dart';
import '../../domain/entities/effect.dart';
import '../../domain/entities/parameter.dart';
import '../../domain/entities/pedalboard.dart';
import '../providers.dart';

/// Owns ALL pedalboard state that used to live in widget fields
/// (`MainPage.items`, `EffectWidget.isActive`/`parameters`) and in global
/// statics (`SliderController`).
///
/// The 6 built-in effects (with their full parameter definitions) come from
/// [buildEffectCatalog] and are kept in [_catalog] so an effect keeps its
/// parameter values / on-off state even while it is not in the chain — matching
/// the old behaviour where the [EffectWidget] objects were never discarded.
/// [_order] holds the names currently in the chain, in order; the exposed
/// [PedalboardState.chain] is projected from the catalog through this order.
class PedalboardNotifier extends Notifier<PedalboardState> {
  final Map<String, Effect> _catalog = {};
  final List<String> _order = [];

  @override
  PedalboardState build() {
    for (final effect in buildEffectCatalog()) {
      _catalog[effect.name] = effect;
    }
    return const PedalboardState(isActive: false, chain: []);
  }

  /// Recomputes [state] from [_catalog] + [_order], keeping the current active
  /// flag unless [isActive] is provided.
  void _emit({bool? isActive}) {
    state = PedalboardState(
      isActive: isActive ?? state.isActive,
      chain: [for (final name in _order) _catalog[name]!],
    );
  }

  /// Fire-and-forget push of the current state to the Pi (never throws).
  void _send() {
    ref.read(effectTransportProvider).send(pedalboardToWireJson(state));
  }

  /// Toggle the whole pedalboard on/off. The old code always sent on toggle.
  void togglePedalboard() {
    _emit(isActive: !state.isActive);
    _send();
  }

  /// Add an effect to the FRONT of the chain (index 0), if not already present.
  void addEffect(String name) {
    if (!_catalog.containsKey(name)) return;
    if (!_order.contains(name)) {
      _order.insert(0, name);
    }
    _emit();
    if (state.isActive) _send();
  }

  void removeEffect(String name) {
    _order.remove(name);
    _emit();
    if (state.isActive) _send();
  }

  /// Move [name] one position towards the front. Replicates the old swap logic.
  void moveLeft(String name) {
    for (int i = 1; i < _order.length; i++) {
      if (_order[i] == name) {
        final tmp = _order[i - 1];
        _order.removeAt(i - 1);
        _order.insert(i, tmp);
        break;
      }
    }
    _emit();
    if (state.isActive) _send();
  }

  /// Move [name] one position towards the back. Replicates the old swap logic.
  void moveRight(String name) {
    for (int i = 0; i < _order.length - 1; i++) {
      if (_order[i] == name) {
        final tmp = _order[i];
        _order.removeAt(i);
        _order.insert(i + 1, tmp);
        break;
      }
    }
    _emit();
    if (state.isActive) _send();
  }

  void setEffectActive(String name, bool active) {
    final effect = _catalog[name];
    if (effect == null) return;
    _catalog[name] = effect.copyWith(isActive: active);
    _emit();
    // Old on/off button sent whenever the pedalboard was active.
    if (state.isActive) _send();
  }

  void setParameter(String effectName, String paramName, int value) {
    final effect = _catalog[effectName];
    if (effect == null) return;
    _catalog[effectName] = effect.copyWith(
      parameters: [
        for (final p in effect.parameters)
          if (p.name == paramName) p.copyWith(value: value) else p,
      ],
    );
    _emit();
    // Old slider send required BOTH the pedalboard and the effect to be active.
    if (state.isActive && _catalog[effectName]!.isActive) _send();
  }

  /// Apply a preset's parameter values to an effect in one step (matches the
  /// old `selectPreset`, which updated every parameter then sent once).
  void applyPreset(String effectName, List<Parameter> parameters) {
    final effect = _catalog[effectName];
    if (effect == null) return;
    _catalog[effectName] = effect.copyWith(
      parameters: [
        for (final p in effect.parameters)
          p.copyWith(
            value: parameters
                .firstWhere((pp) => pp.name == p.name, orElse: () => p)
                .value,
          ),
      ],
    );
    _emit();
    if (state.isActive && _catalog[effectName]!.isActive) _send();
  }

  /// Connect the transport to the currently selected device address and record
  /// the result in [connectionStatusProvider].
  Future<void> connect() async {
    final transport = ref.read(effectTransportProvider);
    final address = ref.read(selectedDeviceAddressProvider);
    if (address == null) {
      ref.read(connectionStatusProvider.notifier).state = false;
      return;
    }
    final ok = await transport.connect(address);
    ref.read(connectionStatusProvider.notifier).state = ok;
  }
}
