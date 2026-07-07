import 'package:equatable/equatable.dart';

/// A single named parameter of an effect (e.g. LEVEL, TIME) with an integer
/// value in the range 0..100.
class Parameter extends Equatable {
  final String name;
  final int value;

  const Parameter({required this.name, required this.value});

  Parameter copyWith({String? name, int? value}) {
    return Parameter(
      name: name ?? this.name,
      value: value ?? this.value,
    );
  }

  @override
  List<Object?> get props => [name, value];
}
