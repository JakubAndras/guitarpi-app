import 'package:flutter/material.dart';

import '../../model/AppColors.dart';

class AddSimpleEffectWidget extends StatelessWidget {
  final String name;
  final Function insertItem;
  final Color color;

  const AddSimpleEffectWidget(
      {required this.name,
      required this.insertItem,
      required this.color,
      super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        insertItem(name);
      },
      child: Container(
        width: double.maxFinite,
        height: 46,
        margin: const EdgeInsets.only(top: 5, left: 10, right: 10, bottom: 5),
        decoration: BoxDecoration(
            color: Colors.grey[850], borderRadius: BorderRadius.circular(20)),
        child: Center(
          child: Text(
            name,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.5,
              color: AppColors.white,
              shadows: <Shadow>[
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 1.0,
                  color: color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
