import '../../domain/entities/pedalboard.dart';

/// Serializes a [PedalboardState] into the EXACT wire format expected by the
/// Pi firmware:
///
/// ```json
/// { "isPedalBoardActive": <bool>,
///   "effects": [ { "name": <str>, "isActive": <bool>, "order": <int>,
///                  "parameters": [ {"name":<str>,"value":<int>} ] } ] }
/// ```
///
/// `order` is the index of the effect in the chain.
Map<String, dynamic> pedalboardToWireJson(PedalboardState s) {
  return {
    'isPedalBoardActive': s.isActive,
    'effects': [
      for (int i = 0; i < s.chain.length; i++)
        {
          'name': s.chain[i].name,
          'isActive': s.chain[i].isActive,
          'order': i,
          'parameters': [
            for (final p in s.chain[i].parameters)
              {
                'name': p.name,
                'value': p.value,
              },
          ],
        },
    ],
  };
}
