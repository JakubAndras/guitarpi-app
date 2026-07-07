import 'package:decorated_icon/decorated_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers.dart';
import 'pedalboard_metrics.dart';

/// Left/right arrows that move the effect within the chain. Extracted verbatim
/// from `EffectWidget`; reordering calls the notifier exactly as before.
class EffectReorderBar extends ConsumerWidget {
  const EffectReorderBar({
    required this.name,
    required this.canMoveLeft,
    required this.canMoveRight,
    required this.metrics,
    super.key,
  });

  final String name;
  final bool canMoveLeft;
  final bool canMoveRight;
  final PedalboardMetrics metrics;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(pedalboardProvider.notifier);
    return SizedBox(
      height: metrics.reorderBarHeight,
      child: Row(
        children: [
          IconButton(
            padding: metrics.moveLeftPadding,
            icon: DecoratedIcon(
              Icons.arrow_back_outlined,
              color: canMoveLeft == true
                  ? AppColors.white
                  : AppColors.secondaryColor,
              size: metrics.arrowIconSize,
              shadows: const [],
            ),
            onPressed: () => notifier.moveLeft(name),
          ),
          SizedBox(
            width: metrics.reorderSpacerWidth,
          ),
          IconButton(
            padding: metrics.moveRightPadding,
            icon: DecoratedIcon(
              Icons.arrow_forward_outlined,
              color: canMoveRight == true
                  ? AppColors.white
                  : AppColors.secondaryColor,
              size: metrics.arrowIconSize,
              shadows: const [],
            ),
            onPressed: () => notifier.moveRight(name),
          ),
        ],
      ),
    );
  }
}
