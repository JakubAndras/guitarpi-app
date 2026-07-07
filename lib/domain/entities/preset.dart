import 'package:equatable/equatable.dart';

import 'parameter.dart';

/// A named, saved snapshot of an effect's parameter values.
class Preset extends Equatable {
  final String name;
  final List<Parameter> parameters;

  const Preset({required this.name, required this.parameters});

  Preset copyWith({String? name, List<Parameter>? parameters}) {
    return Preset(
      name: name ?? this.name,
      parameters: parameters ?? this.parameters,
    );
  }

  @override
  List<Object?> get props => [name, parameters];
}
