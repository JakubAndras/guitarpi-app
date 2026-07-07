import 'dart:convert';
import 'dart:typed_data';

import 'package:bc_ui_flutter/model/BluetoothServer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import '../model/AppColors.dart';
import '../utils/BluetoothSupport.dart';
import '../model/Effect.dart';
import '../model/EffectPresetModel.dart';
import '../widget/CustomPageBackground.dart';
import '../widget/EffectWidget.dart';
import '../widget/add_effect/AddEffectButtonAppBar.dart';

// Pedalboard page

// ignore: must_be_immutable
class MainPage extends StatefulWidget {
  // The widget intentionally keeps a reference to its State so the parent can
  // trigger initConnection() after the page is built.
  // ignore: library_private_types_in_public_api
  late _MainPage mainPage;

  MainPage({super.key});

  @override
  // ignore: no_logic_in_create_state
  State<MainPage> createState() {
    mainPage = _MainPage();
    return mainPage;
  }

  void initConnection() {
    mainPage.initConnection();
  }
}

class _MainPage extends State<MainPage> {
  BluetoothConnection? connection;

  bool isConnecting = true;
  bool get isConnected => (connection?.isConnected ?? false);
  bool isDisconnecting = false;

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

  void initConnection() {
    if (!isBluetoothSupported) return;
    BluetoothConnection.toAddress(BluetoothServer.server?.address)
        .then((connection) {
      connection = connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });
    }).catchError((error) {
      debugPrint('$error');
    });
  }

  @override
  void initState() {
    super.initState();

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
  }

  @override
  void dispose() {
    if (isConnected) {
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
    }
    super.dispose();
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
                    width: 66,
                    height: 46,
                    child: Container(
                      decoration: BoxDecoration(
                          color: isPedalBoardActive == true
                              ? Colors.green
                              : Colors.red,
                          border: Border.all(
                            color: Colors.white54,
                            width: 1.2,
                          ),
                      ),
                      child: Stack(
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                  width: 63.6,
                                  height: 44,
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
            child: SizedBox(
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
                                border: Border.all(
                                  color: Colors.white54,
                                  width: 1.2,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                          width: mobileWidth * 0.08 - 2.4,
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
    if (isPedalBoardActive) {
      _sendMessage();
    }
  }

  void removeItem(String name) {
    setState(() {
      items.remove(name);
    });
    if (isPedalBoardActive) {
      _sendMessage();
    }
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
    if (isPedalBoardActive) {
      _sendMessage();
    }
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
    if (isPedalBoardActive) {
      _sendMessage();
    }
  }

  EffectWidget? findEffectWidget(String name) {
    for (EffectWidget effect in effects) {
      if (effect.name == name) {
        return effect;
      }
    }
    return null;
  }

  sendDataBySliderChange() {
    if (isPedalBoardActive) {
      _sendMessage();
    }
  }

  void _sendMessage() {
    _EffectSettings effectSettings = _EffectSettings(isPedalBoardActive);
    for (int i = 0; i < items.length; i++) {
      EffectWidget? tmp = findEffectWidget(items[i]);
      effectSettings
          .addEffect(_SimpleEffect(items[i], tmp!.isActive, i, tmp.parameters));
    }

    String jsonEffectSettings = jsonEncode(effectSettings);

    try {
      connection!.output
          .add(Uint8List.fromList(utf8.encode(jsonEffectSettings)));
      connection!.output.allSent;
    } catch (e) {
      // Ignore error, but notify state
      setState(() {});
    }
  }
}

class _SimpleEffect {
  String name;
  int order;
  bool isActive;
  List<ParameterModel> parameters;
  _SimpleEffect(this.name, this.isActive, this.order, this.parameters);
  Map toJson() => {
        'name': name,
        'isActive': isActive,
        'order': order,
        'parameters': parameters,
      };
}

class _EffectSettings {
  bool isPedalBoardActive;
  List<_SimpleEffect> effects = [];
  _EffectSettings(this.isPedalBoardActive);

  void addEffect(_SimpleEffect effect) {
    effects.add(effect);
  }

  Map toJson() =>
      {'isPedalBoardActive': isPedalBoardActive, 'effects': effects};
}
