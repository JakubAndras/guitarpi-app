// Value-equality (Equatable) and copyWith behaviour for the domain entities.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bc_ui_flutter/domain/entities/parameter.dart';
import 'package:bc_ui_flutter/domain/entities/effect.dart';
import 'package:bc_ui_flutter/domain/entities/pedalboard.dart';

void main() {
  group('Parameter', () {
    test('is equal when fields are equal', () {
      const a = Parameter(name: 'LEVEL', value: 42);
      const b = Parameter(name: 'LEVEL', value: 42);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('is not equal when a field differs', () {
      const a = Parameter(name: 'LEVEL', value: 42);
      expect(a == const Parameter(name: 'LEVEL', value: 43), isFalse);
      expect(a == const Parameter(name: 'TIME', value: 42), isFalse);
    });

    test('copyWith changes only the given field', () {
      const a = Parameter(name: 'LEVEL', value: 42);
      final b = a.copyWith(value: 7);
      expect(b, const Parameter(name: 'LEVEL', value: 7));
      expect(a.copyWith(name: 'TIME'),
          const Parameter(name: 'TIME', value: 42));
      // Unchanged copy is still equal to the original.
      expect(a.copyWith(), a);
    });
  });

  group('Effect', () {
    const params = [
      Parameter(name: 'LEVEL', value: 0),
      Parameter(name: 'TIME', value: 0),
    ];

    test('is equal when fields are equal (incl. parameter list contents)', () {
      const a = Effect(
        name: 'Echo',
        color: Color(0xFF112233),
        parameters: params,
        isActive: true,
      );
      const b = Effect(
        name: 'Echo',
        color: Color(0xFF112233),
        parameters: [
          Parameter(name: 'LEVEL', value: 0),
          Parameter(name: 'TIME', value: 0),
        ],
        isActive: true,
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('isActive defaults to false', () {
      const a = Effect(
        name: 'Echo',
        color: Color(0xFF112233),
        parameters: params,
      );
      expect(a.isActive, isFalse);
    });

    test('differs when any field differs', () {
      const base = Effect(
        name: 'Echo',
        color: Color(0xFF112233),
        parameters: params,
      );
      expect(base == base.copyWith(isActive: true), isFalse);
      expect(base == base.copyWith(name: 'Delay'), isFalse);
      expect(base == base.copyWith(color: const Color(0xFF000000)), isFalse);
      expect(
        base ==
            base.copyWith(
                parameters: const [Parameter(name: 'LEVEL', value: 9)]),
        isFalse,
      );
    });

    test('copyWith changes only the given field', () {
      const base = Effect(
        name: 'Echo',
        color: Color(0xFF112233),
        parameters: params,
      );
      final active = base.copyWith(isActive: true);
      expect(active.isActive, isTrue);
      expect(active.name, 'Echo');
      expect(active.color, const Color(0xFF112233));
      expect(active.parameters, params);
      expect(base.copyWith(), base);
    });
  });

  group('PedalboardState', () {
    const echo = Effect(
      name: 'Echo',
      color: Color(0xFF112233),
      parameters: [Parameter(name: 'LEVEL', value: 0)],
    );

    test('defaults to inactive with an empty chain', () {
      const s = PedalboardState();
      expect(s.isActive, isFalse);
      expect(s.chain, isEmpty);
    });

    test('is equal when fields are equal', () {
      const a = PedalboardState(isActive: true, chain: [echo]);
      const b = PedalboardState(isActive: true, chain: [echo]);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('differs when isActive or chain differs', () {
      const a = PedalboardState(isActive: true, chain: [echo]);
      expect(a == const PedalboardState(isActive: false, chain: [echo]),
          isFalse);
      expect(a == const PedalboardState(isActive: true, chain: []), isFalse);
    });

    test('copyWith changes only the given field', () {
      const a = PedalboardState(isActive: false, chain: [echo]);
      expect(a.copyWith(isActive: true),
          const PedalboardState(isActive: true, chain: [echo]));
      expect(a.copyWith(chain: const []),
          const PedalboardState(isActive: false, chain: []));
      expect(a.copyWith(), a);
    });
  });
}
