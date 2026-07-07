// Wire-format contract with the Pi firmware. The exact map shape MUST NOT
// change (see refactor-spec §Wire format).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bc_ui_flutter/domain/entities/effect.dart';
import 'package:bc_ui_flutter/domain/entities/parameter.dart';
import 'package:bc_ui_flutter/domain/entities/pedalboard.dart';
import 'package:bc_ui_flutter/data/dto/pedalboard_wire_dto.dart';

void main() {
  test('empty chain serializes to an empty effects list', () {
    const state = PedalboardState(isActive: false, chain: []);
    final json = pedalboardToWireJson(state);
    expect(json, {
      'isPedalBoardActive': false,
      'effects': <dynamic>[],
    });
  });

  test('isPedalBoardActive reflects the state flag', () {
    expect(
      pedalboardToWireJson(
          const PedalboardState(isActive: true, chain: []))['isPedalBoardActive'],
      true,
    );
    expect(
      pedalboardToWireJson(const PedalboardState(
          isActive: false, chain: []))['isPedalBoardActive'],
      false,
    );
  });

  test('single effect produces the exact expected map shape', () {
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

    // Full structural equality — this is the firmware contract. Note the
    // Color is intentionally NOT part of the wire format.
    expect(pedalboardToWireJson(state), {
      'isPedalBoardActive': true,
      'effects': [
        {
          'name': 'Echo',
          'isActive': true,
          'order': 0,
          'parameters': [
            {'name': 'LEVEL', 'value': 42},
          ],
        },
      ],
    });
  });

  test('multi-effect chain assigns order = index for each effect', () {
    const state = PedalboardState(
      isActive: true,
      chain: [
        Effect(
          name: 'Distortion',
          color: Color(0xFF111111),
          isActive: true,
          parameters: [Parameter(name: 'LEVEL', value: 10)],
        ),
        Effect(
          name: 'Delay',
          color: Color(0xFF222222),
          isActive: false,
          parameters: [
            Parameter(name: 'LEVEL', value: 20),
            Parameter(name: 'TIME', value: 30),
          ],
        ),
        Effect(
          name: 'Reverb',
          color: Color(0xFF333333),
          isActive: true,
          parameters: [
            Parameter(name: 'TIME', value: 40),
            Parameter(name: 'WET', value: 50),
          ],
        ),
      ],
    );

    final effects = pedalboardToWireJson(state)['effects'] as List;
    expect(effects.length, 3);
    for (var i = 0; i < effects.length; i++) {
      expect(effects[i]['order'], i);
    }
    expect(effects.map((e) => e['name']).toList(),
        ['Distortion', 'Delay', 'Reverb']);
    expect(effects[1]['isActive'], false);
  });

  test('multiple parameters are serialized in order', () {
    const state = PedalboardState(
      isActive: true,
      chain: [
        Effect(
          name: 'Fuzz',
          color: Color(0xFF444444),
          isActive: true,
          parameters: [
            Parameter(name: 'LEVEL', value: 1),
            Parameter(name: 'FUZZ', value: 2),
          ],
        ),
      ],
    );

    final effect = (pedalboardToWireJson(state)['effects'] as List).first;
    expect(effect['parameters'], [
      {'name': 'LEVEL', 'value': 1},
      {'name': 'FUZZ', 'value': 2},
    ]);
  });
}
