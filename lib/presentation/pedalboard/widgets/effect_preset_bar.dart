import 'package:decorated_icon/decorated_icon.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/preset.dart';
import 'pedalboard_metrics.dart';

/// Preset controls of an effect card: the preset dropdown + save + delete
/// buttons. Extracted verbatim from `EffectWidget`.
///
/// The preset list and the currently selected preset are local UI state owned
/// by the parent `EffectCard`; this widget is pure presentation and reports
/// user intent through [onSelect] / [onSave] / [onDelete] — the parent keeps
/// the create/delete/select logic wired to `presetRepositoryProvider` and
/// `pedalboardProvider` exactly as before.
class EffectPresetBar extends StatelessWidget {
  const EffectPresetBar({
    required this.color,
    required this.metrics,
    required this.presets,
    required this.currentPreset,
    required this.onSelect,
    required this.onSave,
    required this.onDelete,
    super.key,
  });

  final Color color;
  final PedalboardMetrics metrics;
  final List<Preset> presets;
  final Preset? currentPreset;
  final ValueChanged<String?> onSelect;
  final VoidCallback onSave;
  final VoidCallback onDelete;

  DropdownMenuItem<String> _buildPresetItem(Preset item) {
    final text = Text(
      item.name,
      style: TextStyle(
        color: Colors.grey,
        fontWeight: FontWeight.bold,
        fontSize: metrics.presetItemFontSize,
      ),
    );
    return DropdownMenuItem(
      value: item.name,
      child: metrics.portrait
          ? ListTile(title: text)
          : Padding(
              padding: const EdgeInsets.fromLTRB(9, 9, 0, 0),
              child: text,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: metrics.presetBarPadding,
      child: Row(
        children: [
          // Selected preset
          Container(
            width: metrics.presetDropdownWidth,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.transparent,
                width: 1,
              ),
            ),
            child: Padding(
              padding: metrics.presetDropdownPadding,
              child: DropdownButton<String>(
                value: currentPreset?.name,
                iconSize: metrics.presetDropdownIconSize,
                elevation: 8,
                isExpanded: true,
                isDense: false,
                underline: Container(
                  height: 1.5,
                  color: color,
                ),
                items: presets.map(_buildPresetItem).toList(),
                onChanged: onSelect,
              ),
            ),
          ),
          // Save preset
          SizedBox(
            width: metrics.savePresetWidth,
            child: IconButton(
              padding: metrics.savePresetPadding,
              icon: DecoratedIcon(
                Icons.save,
                color: AppColors.white,
                size: metrics.saveIconSize,
                shadows: const [
                  BoxShadow(
                    blurRadius: 3,
                    color: Colors.blueAccent,
                    offset: Offset(0, -1),
                  ),
                  BoxShadow(
                    blurRadius: 3,
                    color: Colors.blueAccent,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              onPressed: onSave,
            ),
          ),
          // Delete preset
          SizedBox(
            width: metrics.deletePresetWidth,
            child: IconButton(
              padding: metrics.deletePresetPadding,
              icon: DecoratedIcon(
                Icons.delete,
                color: currentPreset == null
                    ? AppColors.secondaryColor
                    : AppColors.white,
                size: metrics.deletePresetIconSize,
                shadows: const [
                  BoxShadow(
                    blurRadius: 4,
                    color: Colors.redAccent,
                    offset: Offset(0, -2),
                  ),
                  BoxShadow(
                    blurRadius: 4,
                    color: Colors.redAccent,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              onPressed: onDelete,
            ),
          ),
        ],
      ),
    );
  }
}
