// Placeholder smoke test — replaced with real coverage in the tests phase.
// Exercises the pure wire-format serializer (no Flutter/plugin dependencies).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bc_ui_flutter/domain/entities/effect.dart';
import 'package:bc_ui_flutter/domain/entities/parameter.dart';
import 'package:bc_ui_flutter/domain/entities/pedalboard.dart';
import 'package:bc_ui_flutter/data/dto/pedalboard_wire_dto.dart';

void main() {
  test('pedalboardToWireJson produces the expected wire shape', () {
    const state = PedalboardState(
      isActive: true,
      chain: [
        Effect(
          name: 'Echo',
          color: Color(0xFF000000),
          isActive: true,
          parameters: [Parameter(name: 'LEVEL', value: 42)],
        ),
      ],
    );

    final json = pedalboardToWireJson(state);

    expect(json['isPedalBoardActive'], true);
    final effects = json['effects'] as List;
    expect(effects.length, 1);
    expect(effects.first['name'], 'Echo');
    expect(effects.first['order'], 0);
    expect(effects.first['parameters'], [
      {'name': 'LEVEL', 'value': 42},
    ]);
  });
}
