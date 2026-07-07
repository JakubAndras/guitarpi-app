import 'package:bc_ui_flutter/model/AppColors.dart';
import 'package:decorated_icon/decorated_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/effect.dart';
import '../domain/entities/parameter.dart';
import '../domain/entities/preset.dart';
import '../presentation/providers.dart';
import './SliderWidget.dart';

/// A single effect card. All effect state (on/off, parameter values) is read
/// from `pedalboardProvider`; only the currently selected preset and the loaded
/// preset list are local UI state. Presets are loaded/saved through
/// `presetRepositoryProvider`.
class EffectWidget extends ConsumerStatefulWidget {
  final String name;
  final bool canMoveLeft;
  final bool canMoveRight;

  const EffectWidget({
    required this.name,
    required this.canMoveLeft,
    required this.canMoveRight,
    required Key key,
  }) : super(key: key);

  @override
  ConsumerState<EffectWidget> createState() => _EffectWidgetState();
}

class _EffectWidgetState extends ConsumerState<EffectWidget>
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

    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final mobileWidth = MediaQuery.of(context).size.width;
    final mobileHeight = MediaQuery.of(context).size.height;

    // Rebuild when this effect's state changes (on/off, parameter values).
    final effect = ref.watch(pedalboardProvider.select(
      (s) => s.chain.firstWhere((e) => e.name == widget.name),
    ));
    final notifier = ref.read(pedalboardProvider.notifier);
    final color = effect.color;
    final isActive = effect.isActive;

    return Padding(
      padding: isPortrait
          ? const EdgeInsets.fromLTRB(0, 10, 3, 6)
          : const EdgeInsets.fromLTRB(0, 0, 4, 2),
      child: SizedBox(
        width: isPortrait ? mobileWidth - 6 : mobileWidth * 0.3,
        height: isPortrait ? mobileHeight : mobileHeight * 0.8,
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
              Container(
                height: isPortrait ? 90 : mobileHeight * 0.12,
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                alignment: Alignment.center,
                child: Row(
                  children: [
                    // Delete effect button
                    Padding(
                      padding: isPortrait
                          ? const EdgeInsets.fromLTRB(20, 3, 0, 0)
                          : const EdgeInsets.fromLTRB(7, 4, 0, 0),
                      child: SizedBox(
                        width: isPortrait
                            ? mobileWidth * 0.11
                            : mobileWidth * 0.044,
                        child: IconButton(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                          icon: DecoratedIcon(
                            Icons.delete,
                            color: AppColors.white,
                            size: isPortrait ? 40 : 24,
                            shadows: const [
                              BoxShadow(
                                blurRadius: 7,
                                color: Colors.redAccent,
                                offset: Offset(0, -2),
                              ),
                              BoxShadow(
                                blurRadius: 7,
                                color: Colors.redAccent,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          onPressed: () => notifier.removeEffect(widget.name),
                        ),
                      ),
                    ),
                    // Effect's name text
                    Container(
                      width: isPortrait ? 255 : 140,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                      child: Text(
                        widget.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isPortrait ? 42.0 : 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                          color: AppColors.white,
                          shadows: <Shadow>[
                            Shadow(
                              offset: Offset(2, 2),
                              blurRadius: 8.0,
                              color: color,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Is effect active indicator
                    Padding(
                      padding: isPortrait
                          ? const EdgeInsets.fromLTRB(6, 3, 0, 0)
                          : const EdgeInsets.fromLTRB(8, 3, 0, 0),
                      child: SizedBox(
                        width: isPortrait ? 26 : 16,
                        height: isPortrait ? 26 : 16,
                        child: Container(
                          decoration: BoxDecoration(
                              color: isActive == true
                                  ? Colors.green
                                  : Colors.grey,
                              border: Border.all(
                                color: Colors.white54,
                                width: 2,
                              ),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(42.0),
                              ),
                              boxShadow: [
                                BoxShadow(
                                    color: isActive == true
                                        ? Colors.green
                                        : Colors.transparent,
                                    offset: const Offset(0.0, 0.0),
                                    blurRadius: 4.0,
                                    spreadRadius: 0.0)
                              ]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(
                height: 2,
                thickness: 2,
              ),
              // Icons to change effect ordering
              SizedBox(
                height: isPortrait ? 46 : 28,
                child: Row(
                  children: [
                    IconButton(
                      padding: isPortrait
                          ? const EdgeInsets.fromLTRB(10, 10, 0, 0)
                          : const EdgeInsets.fromLTRB(0, 4, 4, 0),
                      icon: DecoratedIcon(
                        Icons.arrow_back_outlined,
                        color: widget.canMoveLeft == true
                            ? AppColors.white
                            : AppColors.secondaryColor,
                        size: isPortrait ? 32 : 22,
                        shadows: const [],
                      ),
                      onPressed: () => notifier.moveLeft(widget.name),
                    ),
                    SizedBox(
                      width:
                          isPortrait ? mobileWidth - 110 : mobileWidth * 0.163,
                    ),
                    IconButton(
                      padding: isPortrait
                          ? const EdgeInsets.fromLTRB(0, 10, 10, 0)
                          : const EdgeInsets.fromLTRB(4, 4, 0, 0),
                      icon: DecoratedIcon(
                        Icons.arrow_forward_outlined,
                        color: widget.canMoveRight == true
                            ? AppColors.white
                            : AppColors.secondaryColor,
                        size: isPortrait ? 32 : 22,
                        shadows: const [],
                      ),
                      onPressed: () => notifier.moveRight(widget.name),
                    ),
                  ],
                ),
              ),
              // Effect's parameters
              Container(
                height: isPortrait ? mobileHeight * 0.245 : mobileHeight * 0.25,
                alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Center(
                  child: Column(
                    children: [
                      for (Parameter parameter in effect.parameters)
                        createSliderWidget(parameter, isPortrait, color)
                    ],
                  ),
                ),
              ),
              // Preset stuff
              Padding(
                padding: isPortrait
                    ? const EdgeInsets.fromLTRB(0, 5, 0, 3)
                    : const EdgeInsets.fromLTRB(0, 0, 0, 1),
                child: Row(
                  children: [
                    // Selected preset
                    Container(
                      width: isPortrait ? 280 : mobileWidth * 0.205,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: isPortrait
                            ? const EdgeInsets.fromLTRB(15, 4, 5, 4)
                            : const EdgeInsets.fromLTRB(8, 0, 0, 0),
                        child: DropdownButton<String>(
                          value: currentPreset?.name,
                          iconSize: isPortrait ? 32 : 20,
                          elevation: 8,
                          isExpanded: true,
                          isDense: false,
                          underline: Container(
                            height: 1.5,
                            color: color,
                          ),
                          items: isPortrait
                              ? presets.map(buildPresetItem).toList()
                              : presets
                                  .map(buildPresetItemLandscape)
                                  .toList(),
                          onChanged: (name) => selectPreset(name),
                        ),
                      ),
                    ),
                    // Save preset
                    SizedBox(
                      width: isPortrait ? mobileWidth * 0.12 : 28,
                      child: IconButton(
                        padding: isPortrait
                            ? const EdgeInsets.all(8)
                            : const EdgeInsets.fromLTRB(7, 10, 0, 0),
                        icon: DecoratedIcon(
                          Icons.save,
                          color: AppColors.white,
                          size: isPortrait ? 30 : 20,
                          shadows: const [
                            BoxShadow(
                              blurRadius: 3,
                              color: Colors.blueAccent,
                              offset: Offset(0, -1),
                            ),
                            BoxShadow(
                              blurRadius: 3,
                              color: Colors.blueAccent,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        onPressed: () => createPreset(),
                      ),
                    ),
                    // Delete preset
                    SizedBox(
                      width: isPortrait ? mobileWidth * 0.12 : 28,
                      child: IconButton(
                        padding: isPortrait
                            ? const EdgeInsets.fromLTRB(0, 0, 10, 0)
                            : const EdgeInsets.fromLTRB(0, 10, 0, 0),
                        icon: DecoratedIcon(
                          Icons.delete,
                          color: currentPreset == null
                              ? AppColors.secondaryColor
                              : AppColors.white,
                          size: isPortrait ? 30 : 22,
                          shadows: const [
                            BoxShadow(
                              blurRadius: 4,
                              color: Colors.redAccent,
                              offset: Offset(0, -2),
                            ),
                            BoxShadow(
                              blurRadius: 4,
                              color: Colors.redAccent,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        onPressed: () => deletePreset(),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(
                height: 2,
                thickness: 2,
              ),
              // ON/OFF button
              Padding(
                padding: isActive == true
                    ? (isPortrait
                        ? const EdgeInsets.fromLTRB(0, 25, 0, 0)
                        : const EdgeInsets.fromLTRB(0, 12, 0, 0))
                    : (isPortrait
                        ? const EdgeInsets.fromLTRB(0, 15, 0, 0)
                        : const EdgeInsets.fromLTRB(0, 7, 0, 0)),
                child: SizedBox(
                  width: isPortrait ? mobileWidth - 56 : mobileWidth * 0.26,
                  height: mobileHeight * 0.26,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8.0),
                        ),
                        boxShadow: [
                          BoxShadow(
                              color: isActive == true
                                  ? color
                                  : Colors.transparent,
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

  Widget createSliderWidget(Parameter parameter, bool isPortrait, Color color) {
    return Padding(
      padding: isPortrait
          ? const EdgeInsets.fromLTRB(0, 8, 0, 0)
          : const EdgeInsets.fromLTRB(0, 4, 0, 0),
      child: SliderWidget(
        name: parameter.name,
        key: ValueKey('${widget.name}_${parameter.name}'),
        sliderHeight:
            isPortrait ? 45 : MediaQuery.of(context).size.width * 0.034,
        min: 0,
        max: 100,
        currentValue: parameter.value.toDouble(),
        color: color,
        onChangeEnd: (value) {
          setState(() {
            currentPreset = null;
          });
          ref
              .read(pedalboardProvider.notifier)
              .setParameter(widget.name, parameter.name, value);
        },
      ),
    );
  }

  DropdownMenuItem<String> buildPresetItem(Preset item) =>
      DropdownMenuItem(
        value: item.name,
        child: ListTile(
          title: Text(
            item.name,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      );

  DropdownMenuItem<String> buildPresetItemLandscape(Preset item) =>
      DropdownMenuItem(
        value: item.name,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(9, 9, 0, 0),
          child: Text(
            item.name,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      );

  void createPreset() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: SizedBox(
            height: MediaQuery.of(context).orientation == Orientation.portrait
                ? MediaQuery.of(context).size.height * 0.125
                : MediaQuery.of(context).size.height * 0.24,
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
