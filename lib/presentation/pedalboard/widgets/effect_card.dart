import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/effect.dart';
import '../../../domain/entities/parameter.dart';
import '../../../domain/entities/preset.dart';
import '../../providers.dart';
import 'effect_card_header.dart';
import 'effect_preset_bar.dart';
import 'effect_reorder_bar.dart';
import 'parameter_slider.dart';
import 'pedalboard_metrics.dart';

/// A single effect card — the successor to the old `EffectWidget`, now split
/// into cohesive subwidgets ([EffectCardHeader], [EffectReorderBar],
/// [ParameterSlider], [EffectPresetBar]) plus the inline on/off button.
///
/// All effect state (on/off, parameter values) is read from `pedalboardProvider`
/// and mutated through its notifier exactly as before; only the currently
/// selected preset and the loaded preset list are local UI state, loaded/saved
/// through `presetRepositoryProvider`. Layout numbers all come from
/// [PedalboardMetrics], so one tree serves both orientations.
class EffectCard extends ConsumerStatefulWidget {
  final String name;
  final bool canMoveLeft;
  final bool canMoveRight;

  const EffectCard({
    required this.name,
    required this.canMoveLeft,
    required this.canMoveRight,
    required Key key,
  }) : super(key: key);

  @override
  ConsumerState<EffectCard> createState() => _EffectCardState();
}

class _EffectCardState extends ConsumerState<EffectCard>
    with AutomaticKeepAliveClientMixin {
  List<Preset> presets = [];
  Preset? currentPreset;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    presets = ref.read(presetRepositoryProvider).presetsFor(widget.name);
  }

  /// The effect this card renders, from the current pedalboard state.
  Effect get _effect => ref
      .read(pedalboardProvider)
      .chain
      .firstWhere((e) => e.name == widget.name);

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final metrics = PedalboardMetrics(context);

    // Rebuild when this effect's state changes (on/off, parameter values).
    final effect = ref.watch(pedalboardProvider.select(
      (s) => s.chain.firstWhere((e) => e.name == widget.name),
    ));
    final notifier = ref.read(pedalboardProvider.notifier);
    final color = effect.color;
    final isActive = effect.isActive;

    return Padding(
      padding: metrics.cardPadding,
      child: SizedBox(
        width: metrics.cardWidth,
        height: metrics.cardHeight,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
            side: BorderSide(
              color: isActive == true ? color : Colors.white12,
              width: 2.5,
            ),
          ),
          elevation: 0,
          color: Color.fromRGBO(43, 41, 41, 70),
          shadowColor: Colors.white38,
          child: Column(
            children: [
              EffectCardHeader(
                name: widget.name,
                color: color,
                isActive: isActive,
                metrics: metrics,
              ),
              const Divider(
                height: 2,
                thickness: 2,
              ),
              EffectReorderBar(
                name: widget.name,
                canMoveLeft: widget.canMoveLeft,
                canMoveRight: widget.canMoveRight,
                metrics: metrics,
              ),
              // Effect's parameters
              Container(
                height: metrics.parametersHeight,
                alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Center(
                  child: Column(
                    children: [
                      for (Parameter parameter in effect.parameters)
                        ParameterSlider(
                          effectName: widget.name,
                          parameter: parameter,
                          color: color,
                          metrics: metrics,
                          onChangeEnd: (value) {
                            setState(() {
                              currentPreset = null;
                            });
                            notifier.setParameter(
                                widget.name, parameter.name, value);
                          },
                        ),
                    ],
                  ),
                ),
              ),
              EffectPresetBar(
                color: color,
                metrics: metrics,
                presets: presets,
                currentPreset: currentPreset,
                onSelect: selectPreset,
                onSave: createPreset,
                onDelete: deletePreset,
              ),
              const Divider(
                height: 2,
                thickness: 2,
              ),
              // ON/OFF button
              Padding(
                padding: metrics.onOffPadding(isActive),
                child: SizedBox(
                  width: metrics.onOffWidth,
                  height: metrics.onOffHeight,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8.0),
                        ),
                        boxShadow: [
                          BoxShadow(
                              color:
                                  isActive == true ? color : Colors.transparent,
                              offset: const Offset(0.0, 4.0),
                              blurRadius: 7.0,
                              spreadRadius: 0.0)
                        ],
                    ),
                    child: Stack(
                      children: <Widget>[
                        SizedBox.expand(
                          child: Material(
                            type: MaterialType.transparency,
                            child: InkWell(
                              onTap: () {
                                notifier.setEffectActive(
                                    widget.name, !isActive);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void createPreset() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: SizedBox(
            height: PedalboardMetrics(context).presetDialogHeight,
            child: Column(
              children: [
                const Text(
                  "Preset name:",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextFormField(
                  maxLength: 12,
                  initialValue: '',
                  onFieldSubmitted: (name) async {
                    if (name == "") {
                      return;
                    }
                    if (presets.any((preset) => preset.name == name)) {
                      return;
                    }
                    Navigator.of(context).pop();

                    final parameters = _effect.parameters
                        .map((p) => Parameter(name: p.name, value: p.value))
                        .toList();
                    final newPreset =
                        Preset(name: name, parameters: parameters);
                    final updated = [...presets, newPreset];

                    await ref
                        .read(presetRepositoryProvider)
                        .savePresets(widget.name, updated);

                    if (!mounted) return;
                    setState(() {
                      presets = updated;
                      currentPreset = newPreset;
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void deletePreset() async {
    final target = currentPreset;
    if (target == null) return;
    final updated = presets.where((p) => p != target).toList();
    await ref
        .read(presetRepositoryProvider)
        .savePresets(widget.name, updated);
    if (!mounted) return;
    setState(() {
      presets = updated;
      currentPreset = null;
    });
  }

  void selectPreset(String? name) {
    if (name == null) {
      return;
    }
    final preset = presets.firstWhere((element) => element.name == name);
    setState(() {
      currentPreset = preset;
    });
    ref
        .read(pedalboardProvider.notifier)
        .applyPreset(widget.name, preset.parameters);
  }
}
