import 'package:flutter/material.dart';

/// Single home for every numeric layout value the pedalboard UI used to inline
/// as magic numbers (`mobileHeight * 0.185`, `width: 63.6`, `90`, `42.0`, …).
///
/// Values are keyed by [portrait] and are BYTE-IDENTICAL to what `MainPage` and
/// `EffectWidget` computed inline before Phase 3 — they were only relocated
/// here, not changed. Widgets read named getters instead of hard-coding
/// numbers, so portrait/landscape can share one parameterized tree.
class PedalboardMetrics {
  PedalboardMetrics(BuildContext context)
      : _size = MediaQuery.sizeOf(context),
        _topInset = MediaQuery.paddingOf(context).top,
        portrait = MediaQuery.orientationOf(context) == Orientation.portrait;

  final Size _size;
  final double _topInset;
  final bool portrait;

  double get _w => _size.width;
  double get _h => _size.height;

  /// The top safe-area inset (`MediaQuery.padding.top`), used where the old
  /// code read it directly.
  double get topInset => _topInset;

  // --- MainPage ------------------------------------------------------------

  /// Height of the portrait AppBar.
  double get appBarToolbarHeight => 46;

  /// Size of the "add effect" (+) button.
  double get addButtonSize => portrait ? 52 : 60;

  /// Outer size of the pedalboard play/pause toggle box.
  Size get toggleSize =>
      portrait ? const Size(66, 46) : Size(_w * 0.08, _h * 0.185);

  /// Size of the play/pause icon inside the toggle.
  double get toggleIconSize => portrait ? 42 : 52;

  /// Padding wrapping the effect [ListView] in the body.
  EdgeInsets get bodyPadding => portrait
      ? EdgeInsets.zero
      : EdgeInsets.fromLTRB(0, 0, _w * 0.08, 0);

  /// Internal padding of the effect [ListView].
  EdgeInsets get listPadding => portrait
      ? EdgeInsets.fromLTRB(3, _h * 0.09, 0, 0)
      : EdgeInsets.fromLTRB(3, _topInset, 0, 0);

  /// Outer padding of the landscape side control column.
  EdgeInsets get sideColumnPadding => EdgeInsets.fromLTRB(_w * 0.92, 0, 0, 0);

  /// Size of the landscape side control column.
  Size get sideColumnSize => Size(_w * 0.08, _h);

  /// Padding above the toggle inside the landscape side column.
  EdgeInsets get sideTogglePadding => EdgeInsets.fromLTRB(0, _topInset, 0, 0);

  /// Spacer between the toggle and the add button in the side column.
  Size get sideSpacerSize => Size(_w * 0.08, _h * 0.59);

  // --- EffectCard: container ----------------------------------------------

  EdgeInsets get cardPadding => portrait
      ? const EdgeInsets.fromLTRB(0, 10, 3, 6)
      : const EdgeInsets.fromLTRB(0, 0, 4, 2);

  double get cardWidth => portrait ? _w - 6 : _w * 0.3;

  double get cardHeight => portrait ? _h : _h * 0.8;

  // --- EffectCard: header --------------------------------------------------

  double get headerHeight => portrait ? 90 : _h * 0.12;

  EdgeInsets get deleteButtonPadding => portrait
      ? const EdgeInsets.fromLTRB(20, 3, 0, 0)
      : const EdgeInsets.fromLTRB(7, 4, 0, 0);

  double get deleteButtonWidth => portrait ? _w * 0.11 : _w * 0.044;

  double get deleteIconSize => portrait ? 40 : 24;

  double get nameWidth => portrait ? 255 : 140;

  double get nameFontSize => portrait ? 42.0 : 26;

  EdgeInsets get activeIndicatorPadding => portrait
      ? const EdgeInsets.fromLTRB(6, 3, 0, 0)
      : const EdgeInsets.fromLTRB(8, 3, 0, 0);

  double get activeIndicatorSize => portrait ? 26 : 16;

  // --- EffectCard: reorder bar --------------------------------------------

  double get reorderBarHeight => portrait ? 46 : 28;

  EdgeInsets get moveLeftPadding => portrait
      ? const EdgeInsets.fromLTRB(10, 10, 0, 0)
      : const EdgeInsets.fromLTRB(0, 4, 4, 0);

  EdgeInsets get moveRightPadding => portrait
      ? const EdgeInsets.fromLTRB(0, 10, 10, 0)
      : const EdgeInsets.fromLTRB(4, 4, 0, 0);

  double get arrowIconSize => portrait ? 32 : 22;

  double get reorderSpacerWidth => portrait ? _w - 110 : _w * 0.163;

  // --- EffectCard: parameters ---------------------------------------------

  double get parametersHeight => portrait ? _h * 0.245 : _h * 0.25;

  EdgeInsets get sliderPadding => portrait
      ? const EdgeInsets.fromLTRB(0, 8, 0, 0)
      : const EdgeInsets.fromLTRB(0, 4, 0, 0);

  double get sliderHeight => portrait ? 45 : _w * 0.034;

  // --- EffectCard: preset bar ---------------------------------------------

  EdgeInsets get presetBarPadding => portrait
      ? const EdgeInsets.fromLTRB(0, 5, 0, 3)
      : const EdgeInsets.fromLTRB(0, 0, 0, 1);

  double get presetDropdownWidth => portrait ? 280 : _w * 0.205;

  EdgeInsets get presetDropdownPadding => portrait
      ? const EdgeInsets.fromLTRB(15, 4, 5, 4)
      : const EdgeInsets.fromLTRB(8, 0, 0, 0);

  double get presetDropdownIconSize => portrait ? 32 : 20;

  double get presetItemFontSize => portrait ? 20 : 15;

  double get savePresetWidth => portrait ? _w * 0.12 : 28;

  EdgeInsets get savePresetPadding => portrait
      ? const EdgeInsets.all(8)
      : const EdgeInsets.fromLTRB(7, 10, 0, 0);

  double get saveIconSize => portrait ? 30 : 20;

  double get deletePresetWidth => portrait ? _w * 0.12 : 28;

  EdgeInsets get deletePresetPadding => portrait
      ? const EdgeInsets.fromLTRB(0, 0, 10, 0)
      : const EdgeInsets.fromLTRB(0, 10, 0, 0);

  double get deletePresetIconSize => portrait ? 30 : 22;

  /// Height of the "new preset name" dialog body.
  double get presetDialogHeight => portrait ? _h * 0.125 : _h * 0.24;

  // --- EffectCard: on/off button ------------------------------------------

  EdgeInsets onOffPadding(bool isActive) {
    if (isActive) {
      return portrait
          ? const EdgeInsets.fromLTRB(0, 25, 0, 0)
          : const EdgeInsets.fromLTRB(0, 12, 0, 0);
    }
    return portrait
        ? const EdgeInsets.fromLTRB(0, 15, 0, 0)
        : const EdgeInsets.fromLTRB(0, 7, 0, 0);
  }

  double get onOffWidth => portrait ? _w - 56 : _w * 0.26;

  double get onOffHeight => _h * 0.26;
}
