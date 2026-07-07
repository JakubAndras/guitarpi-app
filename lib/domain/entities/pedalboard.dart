import 'package:equatable/equatable.dart';

import 'effect.dart';

/// The full pedalboard state: whether the board is active and the ordered
/// chain of effects. The order of [chain] IS the pedalboard order.
class PedalboardState extends Equatable {
  final bool isActive;
  final List<Effect> chain;

  const PedalboardState({
    this.isActive = false,
    this.chain = const [],
  });

  PedalboardState copyWith({bool? isActive, List<Effect>? chain}) {
    return PedalboardState(
      isActive: isActive ?? this.isActive,
      chain: chain ?? this.chain,
    );
  }

  @override
  List<Object?> get props => [isActive, chain];
}
