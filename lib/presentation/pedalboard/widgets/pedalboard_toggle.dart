import 'package:flutter/material.dart';

/// Shared pedalboard play/pause control (the green/red box in the AppBar in
/// portrait and in the side column in landscape).
///
/// Replaces the two byte-for-byte duplicated copies that lived inline in
/// `MainPage`. The rendered output is identical: a [size]-sized box, green when
/// [active] / red otherwise, with a `Colors.white54` border of width `1.2` and
/// a centered pause/play icon of [iconSize]. Tapping calls [onTap].
class PedalboardToggle extends StatelessWidget {
  const PedalboardToggle({
    required this.active,
    required this.size,
    required this.iconSize,
    required this.onTap,
    super.key,
  });

  final bool active;
  final Size size;
  final double iconSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: size,
      child: Container(
        decoration: BoxDecoration(
          color: active ? Colors.green : Colors.red,
          border: Border.all(
            color: Colors.white54,
            width: 1.2,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                active ? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: iconSize,
              ),
            ),
            SizedBox.expand(
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: onTap,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
