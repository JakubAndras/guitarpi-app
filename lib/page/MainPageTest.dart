import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bc_ui_flutter/model/AppColors.dart';
import 'package:bc_ui_flutter/model/Effect.dart';
import 'package:bc_ui_flutter/model/EffectPresetModel.dart';
import 'package:bc_ui_flutter/widget/EffectWidget.dart';
import 'package:bc_ui_flutter/widget/add_effect/AddEffectButtonAppBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import '../widget/CustomPageBackground.dart';
import '../widget/add_effect/AddEffectButtonBottom.dart';

// Android studio emulator doesn't support Bluetooth,
// so this class was used for development and part of the testing

class MainPageTest extends StatefulWidget {
  //BluetoothDevice? server;

  MainPageTest();

  @override
  _MainPageTest createState() => _MainPageTest();
}

class _MainPageTest extends State<MainPageTest> {
  late List<EffectWidget> effects = [];

  final listKey = GlobalKey();
  List<String> items = [];
  late bool isPedalBoardActive;

  EffectWidget initEffectWidget(
      String name, List<ParameterModel> parameters, Color color) {
    return EffectWidget(
      name: name,
      parameters: parameters,
      color: color,
      onClickedRemove: () => removeItem(name),
      onClickedMoveToLeft: () => moveItemToLeft(name),
      onClickedMoveToRight: () => moveItemToRight(name),
      sendData: sendDataBySliderChange,
      key: ValueKey(name),
    );
  }

  @override
  void initState() {
    effects.add(initEffectWidget(
        Effect.ECHO,
        [ParameterModel('LEVEL', 0), ParameterModel('TIME', 0)],
        AppColors.echo));
    effects.add(initEffectWidget(
        Effect.DELAY,
        [ParameterModel('LEVEL', 0), ParameterModel('TIME', 0)],
        AppColors.delay));
    effects.add(initEffectWidget(
        Effect.DISTORTION, [ParameterModel('LEVEL', 0)], AppColors.distortion));
    effects.add(initEffectWidget(
        Effect.FUZZ,
        [ParameterModel('LEVEL', 0), ParameterModel('FUZZ', 0)],
        AppColors.fuzz));
    effects.add(initEffectWidget(
        Effect.OVERDRIVE, [ParameterModel('LEVEL', 0)], AppColors.overdrive));
    effects.add(initEffectWidget(
        Effect.REVERB,
        [
          ParameterModel('TIME', 0),
          ParameterModel('WET', 0),
        ],
        AppColors.reverb));

    isPedalBoardActive = false;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  sendDataBySliderChange() {
    if (isPedalBoardActive) {
      print("send Data.");
      _sendMessage();
    }
  }

  void _sendMessage() async {
    // TODO order
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final mobileWidth = MediaQuery.of(context).size.width;
    final mobileHeight = MediaQuery.of(context).size.height;

    var content = Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: isPortrait
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              toolbarHeight: 46,
              leading: AddEffectButtonAppBar(
                  insertItem: insertItem, size: 52, isPortrait: isPortrait),
              actions: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: SizedBox(
                    width: 60,
                    height: 46,
                    child: Container(
                      decoration: BoxDecoration(
                          color: isPedalBoardActive == true
                              ? Colors.green
                              : Colors.red,
                          boxShadow: []),
                      child: Stack(
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                  width: 60,
                                  height: 46,
                                  child: Align(
                                      alignment: Alignment.center,
                                      child: Icon(
                                        isPedalBoardActive == true
                                            ? Icons.pause_rounded
                                            : Icons.play_arrow_rounded,
                                        size: 42,
                                      ))),
                            ],
                          ),
                          SizedBox.expand(
                            child: Material(
                              type: MaterialType.transparency,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    isPedalBoardActive = !isPedalBoardActive;
                                    _sendMessage();
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
            )
          : null,
      body: Stack(
        children: [
          const CustomPageBackground(),
          Padding(
            padding: isPortrait
                ? const EdgeInsets.fromLTRB(0, 0, 0, 0)
                : EdgeInsets.fromLTRB(
                    0, 0, MediaQuery.of(context).size.width * 0.08, 0),
            child: ListView.custom(
              key: listKey,
              scrollDirection: Axis.horizontal,
              padding: isPortrait
                  ? EdgeInsets.fromLTRB(3, mobileHeight * 0.09, 0, 0)
                  : EdgeInsets.fromLTRB(
                      3, MediaQuery.of(context).padding.top, 0, 0),
              childrenDelegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return effectWidgetSwitch(items[index], index);
                },
                childCount: items.length,
              ),
            ),
          ),
          Padding(
            padding: isPortrait
                ? const EdgeInsets.fromLTRB(0, 0, 0, 0)
                : EdgeInsets.fromLTRB(
                    MediaQuery.of(context).size.width * 0.92, 0, 0, 0),
            child: Container(
              width: isPortrait ? 0 : mobileWidth * 0.08,
              height: isPortrait ? 0 : mobileHeight,
              child: isPortrait
                  ? null
                  : Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                              0, MediaQuery.of(context).padding.top, 0, 0),
                          child: SizedBox(
                            width: mobileWidth * 0.08,
                            height: mobileHeight * 0.185,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: isPedalBoardActive == true
                                      ? Colors.green
                                      : Colors.red,
                                  boxShadow: []),
                              child: Stack(
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                          width: mobileWidth * 0.08,
                                          height: mobileHeight * 0.185,
                                          child: Align(
                                              alignment: Alignment.center,
                                              child: Icon(
                                                isPedalBoardActive == true
                                                    ? Icons.pause_rounded
                                                    : Icons.play_arrow_rounded,
                                                size: 52,
                                              ))),
                                    ],
                                  ),
                                  SizedBox.expand(
                                    child: Material(
                                      type: MaterialType.transparency,
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            isPedalBoardActive =
                                                !isPedalBoardActive;
                                            if (isPedalBoardActive) {
                                              _sendMessage();
                                            }
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
                        SizedBox(
                          height: mobileHeight * 0.59,
                          width: mobileWidth * 0.08,
                        ),
                        AddEffectButtonAppBar(
                            insertItem: insertItem,
                            size: 60,
                            isPortrait: isPortrait),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );

    return content;
  }

  StatefulWidget? effectWidgetSwitch(String name, int index) {
    for (EffectWidget effect in effects) {
      if (effect.name == name) {
        prepareReordering(effect, index);
        return effect;
      }
    }
    return null;
  }

  void prepareReordering(EffectWidget effect, int index) {
    if (index == 0) {
      effect.canMoveLeft = false;
    } else {
      effect.canMoveLeft = true;
    }
    if (index == items.length - 1) {
      effect.canMoveRight = false;
    } else {
      effect.canMoveRight = true;
    }
  }

  insertItem(String name) {
    setState(() {
      int index = 0;
      if (!items.contains(name)) {
        items.insert(index, name);
      }
    });
  }

  void removeItem(String name) {
    setState(() {
      items.remove(name);
    });
  }

  void moveItemToLeft(String name) {
    setState(() {
      for (int i = 1; i < items.length; i++) {
        if (items[i] == name) {
          String tmp = items[i - 1];
          items.removeAt(i - 1);
          items.insert(i, tmp);
          break;
        }
      }
    });
  }

  void moveItemToRight(String name) {
    setState(() {
      for (int i = 0; i < items.length - 1; i++) {
        if (items[i] == name) {
          String tmp = items[i];
          items.removeAt(i);
          items.insert(i + 1, tmp);
          break;
        }
      }
    });
  }
}
