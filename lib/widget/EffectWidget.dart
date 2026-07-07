import 'dart:convert';

import 'package:bc_ui_flutter/model/AppColors.dart';
import 'package:bc_ui_flutter/model/EffectPresetModel.dart';
import 'package:bc_ui_flutter/utils/PresetSharedPreferences.dart';
import 'package:decorated_icon/decorated_icon.dart';
import 'package:flutter/material.dart';

import '../model/SliderController.dart';
import './SliderWidget.dart';

class EffectWidget extends StatefulWidget {
  final String name;
  late bool isActive;
  final Color color;
  final VoidCallback? onClickedRemove;
  final VoidCallback? onClickedMoveToLeft;
  final VoidCallback? onClickedMoveToRight;
  final Function sendData;
  late List<PresetModel> presets;
  PresetModel? currentPreset;
  late bool canMoveLeft, canMoveRight;

  List<ParameterModel> parameters;

  EffectWidget(
      {required this.name,
      required this.parameters,
      required this.color,
      required this.onClickedRemove,
      required this.onClickedMoveToLeft,
      required this.onClickedMoveToRight,
      required this.sendData,
      required Key key})
      : super(key: key) {
    isActive = false;
  }

  @override
  State<EffectWidget> createState() => _EffectWidgetState();
}

class _EffectWidgetState extends State<EffectWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    String? jsonEffectPresetModel =
        PresetSharedPreferences.getAllEffectPresets(widget.name);
    if (jsonEffectPresetModel != null) {
      EffectPresetModel effectPresetModel =
          EffectPresetModel.fromJson(jsonDecode(jsonEffectPresetModel));
      widget.presets = effectPresetModel.presets;
    } else {
      widget.presets = [];
    }

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(EffectWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return buildWidget();
  }

  _sendData() {
    if (widget.isActive) {
      widget.sendData();
    }
  }

  Widget buildWidget() {
    super.build(context);

    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final mobileWidth = MediaQuery.of(context).size.width;
    final mobileHeight = MediaQuery.of(context).size.height;

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
              color: widget.isActive == true ? widget.color : Colors.white12,
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
                          onPressed: widget.onClickedRemove,
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
                              color: widget.color,
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
                              color: widget.isActive == true
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
                                    color: widget.isActive == true
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
              Container(
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
                      onPressed: widget.onClickedMoveToLeft,
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
                      onPressed: widget.onClickedMoveToRight,
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
                      for (ParameterModel parameter in widget.parameters)
                        createSliderWidget(parameter, isPortrait)
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
                          value: widget.currentPreset?.name,
                          iconSize: isPortrait ? 32 : 20,
                          elevation: 8,
                          isExpanded: true,
                          isDense: false,
                          underline: Container(
                            height: 1.5,
                            color: widget.color,
                          ),
                          items: isPortrait
                              ? widget.presets.map(buildPresetItem).toList()
                              : widget.presets
                                  .map(buildPresetItemLandscape)
                                  .toList(),
                          onChanged: (name) => selectPreset(name),
                        ),
                      ),
                    ),
                    // Save preset
                    Container(
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
                    Container(
                      width: isPortrait ? mobileWidth * 0.12 : 28,
                      child: IconButton(
                        padding: isPortrait
                            ? const EdgeInsets.fromLTRB(0, 0, 10, 0)
                            : const EdgeInsets.fromLTRB(0, 10, 0, 0),
                        icon: DecoratedIcon(
                          Icons.delete,
                          color: widget.currentPreset == null
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
                padding: widget.isActive == true
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
                              color: widget.isActive == true
                                  ? widget.color
                                  : Colors.transparent,
                              offset: const Offset(0.0, 4.0),
                              blurRadius: 7.0,
                              spreadRadius: 0.0)
                        ],
                    ),
                    child: Stack(
                      children: <Widget>[
                        /*Row(
                          children: <Widget>[
                            SizedBox(
                              width: isPortrait ? mobileWidth - 56 : mobileWidth * 0.26,
                              height: mobileHeight * 0.26,
                              child: Align(
                                    alignment: Alignment.center,
                                    child: Icon(
                                        Icons.play_circle_outline,
                                      size: 55,
                                      color: widget.isActive ? Colors.white : Colors.grey,
                                    ))

                            ),
                          ],
                        ),*/
                        SizedBox.expand(
                          child: Material(
                            type: MaterialType.transparency,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  widget.isActive = !widget.isActive;
                                  widget.sendData();
                                });
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

  Widget createSliderWidget(ParameterModel parameter, bool isPortrait) {
    return Padding(
      padding: isPortrait
          ? const EdgeInsets.fromLTRB(0, 8, 0, 0)
          : const EdgeInsets.fromLTRB(0, 4, 0, 0),
      child: SliderWidget(
        name: parameter.name,
        key: ValueKey(widget.name + '_' + parameter.name),
        sliderHeight:
            isPortrait ? 45 : MediaQuery.of(context).size.width * 0.034,
        min: 0,
        max: 100,
        updateLevelValue: updateParameterValue,
        setCurrentPresetToNull: setCurrentPresetToNull,
        sendData: _sendData,
        currentValue: SliderController()
            .getSliderValueByParameterName(widget.name + '_' + parameter.name),
        parentName: widget.name + '_' + parameter.name,
        color: widget.color,
      ),
    );
  }

  updateParameterValue(String parameterName, int value) {
    widget.parameters
        .firstWhere((element) => element.name == parameterName)
        .value = value;
  }

  setCurrentPresetToNull() {
    setState(() {
      widget.currentPreset = null;
    });
  }

  DropdownMenuItem<String> buildPresetItem(PresetModel item) =>
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

  DropdownMenuItem<String> buildPresetItemLandscape(PresetModel item) =>
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
          content: Container(
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
                  onFieldSubmitted: (name) {
                    if (name == "") {
                      return;
                    }
                    for (PresetModel preset in widget.presets) {
                      if (preset.name == name) {
                        return;
                      }
                    }
                    Navigator.of(context).pop();
                    setState(() {
                      late List<ParameterModel> parameters = [];
                      for (ParameterModel parameter in widget.parameters) {
                        parameters.add(
                            ParameterModel(parameter.name, parameter.value));
                      }
                      PresetModel newPreset =
                          PresetModel(name, widget.parameters);
                      widget.presets.add(newPreset);
                      EffectPresetModel updatedPresets =
                          EffectPresetModel(widget.name, widget.presets);

                      String jsonPresets = jsonEncode(updatedPresets);
                      PresetSharedPreferences.setAllEffectPresets(jsonPresets);

                      widget.currentPreset = newPreset;

                      // from init -> reload needed
                      String? jsonEffectPresetModel =
                          PresetSharedPreferences.getAllEffectPresets(
                              widget.name);
                      if (jsonEffectPresetModel != null) {
                        EffectPresetModel effectPresetModel =
                            EffectPresetModel.fromJson(
                                jsonDecode(jsonEffectPresetModel));
                        widget.presets = effectPresetModel.presets;
                      } else {
                        widget.presets = [];
                      }
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

  void deletePreset() {
    setState(() {
      widget.presets.remove(widget.currentPreset);
      widget.currentPreset = null;

      EffectPresetModel updatedPresets =
          EffectPresetModel(widget.name, widget.presets);

      String jsonPresets = jsonEncode(updatedPresets);
      PresetSharedPreferences.setAllEffectPresets(jsonPresets);
    });
  }

  // unic preset needed
  void selectPreset(String? name) {
    if (name == null) {
      return;
    }
    setState(() {
      widget.currentPreset =
          widget.presets.firstWhere((element) => element.name == name);
      for (int i = 0; i < widget.currentPreset!.parameters.length; i++) {
        widget.parameters.elementAt(i).value =
            widget.currentPreset!.parameters.elementAt(i).value;
        SliderController().setSliderValueByParameterName(
            widget.name + '_' + widget.parameters.elementAt(i).name,
            widget.currentPreset!.parameters.elementAt(i).value.toDouble());
      }
    });
    _sendData();
  }
}
