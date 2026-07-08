import 'package:bc_ui_flutter/core/theme/app_colors.dart';
import 'package:bc_ui_flutter/model/Effect.dart';
import 'package:flutter/material.dart';
import 'package:bc_ui_flutter/widget/add_effect/CustomRectTween.dart';
import 'package:bc_ui_flutter/widget/add_effect/HeroDialogRoute.dart';

import 'AddSimpleEffectWidget.dart';

class AddEffectButtonBottom extends StatelessWidget {
  final Function insertItem;

  const AddEffectButtonBottom({super.key, required this.insertItem});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(22.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(HeroDialogRoute(builder: (context) {
            return _AddEffectPopupCard(insertItem: insertItem);
          }));
        },
        child: Hero(
          tag: 'add_hero',
          createRectTween: (begin, end) {
            return CustomRectTween(begin: begin, end: end);
          },
          child: Material(
            color: AppColors.mainColor,
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            child: const Icon(
              Icons.add_rounded,
              size: 52,
            ),
          ),
        ),
      ),
    );
  }
}

class _AddEffectPopupCard extends StatelessWidget {
  final Function insertItem;

  _AddEffectPopupCard({required this.insertItem});

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
        padding: const EdgeInsets.all(50.0),
        child: Hero(
          tag: 'add_hero',
          createRectTween: (begin, end) {
            return CustomRectTween(begin: begin, end: end);
          },
          child: Stack(
            children: [
              Material(
                color: Colors.white30,
                elevation: 20,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32)),
                child: SingleChildScrollView(
                    child: Padding(
                  padding: const EdgeInsets.all(16.0),
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
