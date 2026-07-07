import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/effect.dart';
import '../presentation/providers.dart';
import '../widget/CustomPageBackground.dart';
import '../widget/EffectWidget.dart';
import '../widget/add_effect/AddEffectButtonAppBar.dart';

// Pedalboard page. All state now lives in `pedalboardProvider`; this page only
// reads it and calls notifier methods.
class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  final listKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final mobileWidth = MediaQuery.of(context).size.width;
    final mobileHeight = MediaQuery.of(context).size.height;

    final state = ref.watch(pedalboardProvider);
    final notifier = ref.read(pedalboardProvider.notifier);
    final isPedalBoardActive = state.isActive;
    final chain = state.chain;

    var content = Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: isPortrait
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              toolbarHeight: 46,
              leading: AddEffectButtonAppBar(
                  insertItem: notifier.addEffect,
                  size: 52,
                  isPortrait: isPortrait),
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
                                  notifier.togglePedalboard();
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
                  final Effect effect = chain[index];
                  return EffectWidget(
                    name: effect.name,
                    canMoveLeft: index != 0,
                    canMoveRight: index != chain.length - 1,
                    key: ValueKey(effect.name),
                  );
                },
                childCount: chain.length,
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
                                          notifier.togglePedalboard();
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
                            insertItem: notifier.addEffect,
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
}
