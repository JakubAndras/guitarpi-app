import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'parameter.dart';

/// A guitar effect in the pedalboard chain, with its display color, its
/// parameters and whether it is currently switched on.
class Effect extends Equatable {
  final String name;
  final Color color;
  final List<Parameter> parameters;
  final bool isActive;

  const Effect({
    required this.name,
    required this.color,
    required this.parameters,
    this.isActive = false,
  });

  Effect copyWith({
    String? name,
    Color? color,
    List<Parameter>? parameters,
    bool? isActive,
  }) {
    return Effect(
      name: name ?? this.name,
      color: color ?? this.color,
      parameters: parameters ?? this.parameters,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [name, color, parameters, isActive];
}
