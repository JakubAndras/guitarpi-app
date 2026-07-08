import 'package:bc_ui_flutter/core/theme/app_colors.dart';
import 'package:bc_ui_flutter/model/Effect.dart';
import 'package:flutter/material.dart';
import 'package:bc_ui_flutter/widget/add_effect/CustomRectTween.dart';
import 'package:bc_ui_flutter/widget/add_effect/HeroDialogRoute.dart';

import 'AddSimpleEffectWidget.dart';

class AddEffectButtonAppBar extends StatelessWidget {
  final Function insertItem;
  final double size;
  final bool isPortrait;

  const AddEffectButtonAppBar(
      {super.key,
      required this.insertItem,
      required this.size,
      required this.isPortrait});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(HeroDialogRoute(builder: (context) {
            return _AddEffectPopupCard(
                insertItem: insertItem, isPortrait: isPortrait);
          }));
        },
        child: Hero(
          tag: 'add_hero',
          createRectTween: (begin, end) {
            return CustomRectTween(begin: begin, end: end);
          },
          child: Material(
            color: Colors.transparent,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
            child: Icon(
              Icons.add_rounded,
              size: size,
            ),
          ),
        ),
      ),
    );
  }
}

class _AddEffectPopupCard extends StatelessWidget {
  final Function insertItem;
  final bool isPortrait;

  _AddEffectPopupCard(
      {required this.insertItem, required this.isPortrait});

  final List<String> items = List.from([
    Effect.ECHO,
    Effect.DELAY,
    Effect.DISTORTION,
    Effect.FUZZ,
    Effect.OVERDRIVE,
    Effect.REVERB,
  ]);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: isPortrait
            ? const EdgeInsets.all(50.0)
            : const EdgeInsets.fromLTRB(150, 50, 150, 50),
        child: Hero(
          tag: 'add_hero',
          createRectTween: (begin, end) {
            return CustomRectTween(begin: begin, end: end);
          },
          child: Stack(
            children: [
              Material(
                color: Colors.grey[800],
                elevation: 20,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32)),
                child: SingleChildScrollView(
                    child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AddSimpleEffectWidget(
                          name: Effect.ECHO,
                          insertItem: insertItem,
                          color: AppColors.echo),
                      Divider(),
                      AddSimpleEffectWidget(
                          name: Effect.DELAY,
                          insertItem: insertItem,
                          color: AppColors.delay),
                      Divider(),
                      AddSimpleEffectWidget(
                          name: Effect.DISTORTION,
                          insertItem: insertItem,
                          color: AppColors.distortion),
                      Divider(),
                      AddSimpleEffectWidget(
                          name: Effect.FUZZ,
                          insertItem: insertItem,
                          color: AppColors.fuzz),
                      Divider(),
                      AddSimpleEffectWidget(
                          name: Effect.OVERDRIVE,
                          insertItem: insertItem,
                          color: AppColors.overdrive),
                      Divider(),
                      AddSimpleEffectWidget(
                          name: Effect.REVERB,
                          insertItem: insertItem,
                          color: AppColors.reverb),
                    ],
                  ),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
