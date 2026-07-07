import 'package:flutter/material.dart';

import '../../../domain/entities/parameter.dart';
import '../../../widget/SliderWidget.dart';
import 'pedalboard_metrics.dart';

/// Presentation wrapper around [SliderWidget] for a single [Parameter].
///
/// Extracted verbatim from `EffectWidget.createSliderWidget`. The authoritative
/// value comes from [parameter] (pedalboard state); the final dragged value is
/// reported through [onChangeEnd]. All numeric layout comes from [metrics].
class ParameterSlider extends StatelessWidget {
  const ParameterSlider({
    required this.effectName,
    required this.parameter,
    required this.color,
    required this.metrics,
    required this.onChangeEnd,
    super.key,
  });

  final String effectName;
  final Parameter parameter;
  final Color color;
  final PedalboardMetrics metrics;
  final void Function(int value) onChangeEnd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: metrics.sliderPadding,
      child: SliderWidget(
        name: parameter.name,
        key: ValueKey('${effectName}_${parameter.name}'),
        sliderHeight: metrics.sliderHeight,
        min: 0,
        max: 100,
        currentValue: parameter.value.toDouble(),
        color: color,
        onChangeEnd: onChangeEnd,
      ),
    );
  }
}
