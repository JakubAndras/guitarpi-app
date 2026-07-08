import 'package:decorated_icon/decorated_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../pedalboard_notifier.dart';
import 'pedalboard_metrics.dart';

/// Header row of an effect card: delete button + effect name + active
/// indicator. Extracted verbatim from `EffectWidget`; deleting calls the
/// notifier exactly as before.
class EffectCardHeader extends ConsumerWidget {
  const EffectCardHeader({
    required this.name,
    required this.color,
    required this.isActive,
    required this.metrics,
    super.key,
  });

  final String name;
  final Color color;
  final bool isActive;
  final PedalboardMetrics metrics;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(pedalboardProvider.notifier);
    return Container(
      height: metrics.headerHeight,
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      alignment: Alignment.center,
      child: Row(
        children: [
          // Delete effect button
          Padding(
            padding: metrics.deleteButtonPadding,
            child: SizedBox(
              width: metrics.deleteButtonWidth,
              child: IconButton(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                icon: DecoratedIcon(
                  Icons.delete,
                  color: AppColors.white,
                  size: metrics.deleteIconSize,
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
                onPressed: () => notifier.removeEffect(name),
              ),
            ),
          ),
          // Effect's name text
          Container(
            width: metrics.nameWidth,
            alignment: Alignment.center,
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: metrics.nameFontSize,
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
            padding: metrics.activeIndicatorPadding,
            child: SizedBox(
              width: metrics.activeIndicatorSize,
              height: metrics.activeIndicatorSize,
              child: Container(
                decoration: BoxDecoration(
                    color: isActive == true ? Colors.green : Colors.grey,
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
    );
  }
}
