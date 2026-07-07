import 'package:bc_ui_flutter/model/AppColors.dart';
import 'package:bc_ui_flutter/model/EffectPresetModel.dart';
import 'package:flutter/material.dart';

import '../data/EffectPreset.dart';
import '../model/Effect.dart';
import '../widget/CustomPageBackground.dart';

class PresetPage extends StatefulWidget {
  const PresetPage({super.key});

  @override
  State<PresetPage> createState() => _PresetPage();
}

class _PresetPage extends State<PresetPage> {
  List<String> items = List.from([
    Effect.ECHO,
    Effect.DELAY,
    Effect.DISTORTION,
    Effect.FUZZ,
    Effect.OVERDRIVE,
    Effect.REVERB,
  ]);
  late int expandedWidgetIndex;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Presets'),
        backgroundColor: AppColors.mainColor,
        actions: const [],
      ),
      body: Stack(
        children: [
          const CustomPageBackground(),
          SingleChildScrollView(
            child: ExpansionPanelList.radio(
              expansionCallback: (index, isExpanded) {
                setState(() {
                  expandedWidgetIndex = index;
                  allEffectWithPresets[index].isExpanded = !isExpanded;
                });
              },
              children: allEffectWithPresets
                  .map((effect) => ExpansionPanelRadio(
                      value: effect.name,
                      canTapOnHeader: true,
                      headerBuilder: (context, isExpanded) =>
                          buildPresetHeader(effect),
                      body: Column(
                        children: effect.presets.map(buildPresetItem).toList(),
                      )))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPresetHeader(EffectPresetModel effect) {
    return ListTile(
      title: Text(
        effect.name,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildPresetItem(PresetModel preset) {
    return Column(
      children: [
        const Divider(
          height: 1,
          thickness: 1,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
          child: ListTile(
            title: Text(
              preset.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.edit,
                  ),
                  onPressed: () => edit(preset),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                  ),
                  onPressed: () => remove(preset),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void remove(PresetModel preset) {
    for (int i = 0; i < allEffectWithPresets.length; i++) {
      if (allEffectWithPresets[i].isExpanded) {
        setState(() {
          allEffectWithPresets[i].presets.remove(preset);
        });
      }
    }
  }

  void edit(PresetModel preset) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: TextFormField(
            initialValue: preset.name,
            onFieldSubmitted: (name) {
              Navigator.of(context).pop();
              setState(() {
                preset.name = name;
              });
            },
          ),
        );
      },
    );
  }
}
