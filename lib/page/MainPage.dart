import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/effect.dart';
import '../presentation/pedalboard/widgets/effect_card.dart';
import '../presentation/pedalboard/widgets/pedalboard_metrics.dart';
import '../presentation/pedalboard/widgets/pedalboard_toggle.dart';
import '../presentation/providers.dart';
import '../widget/CustomPageBackground.dart';
import '../widget/add_effect/AddEffectButtonAppBar.dart';

// Pedalboard page. All state now lives in `pedalboardProvider`; this page only
// reads it and calls notifier methods. Portrait and landscape are built from
// the SAME leaf widgets (the effect list, the shared [PedalboardToggle], the
// add-effect button); only their arrangement differs, so the two layouts are
// two thin scaffolds instead of duplicated widget trees. Every layout number
// comes from [PedalboardMetrics].
class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  final listKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final metrics = PedalboardMetrics(context);

    final state = ref.watch(pedalboardProvider);
    final notifier = ref.read(pedalboardProvider.notifier);

    final effectList = _EffectList(
      listKey: listKey,
      chain: state.chain,
      metrics: metrics,
    );

    if (metrics.portrait) {
      return _PortraitScaffold(
        metrics: metrics,
        isActive: state.isActive,
        onToggle: notifier.togglePedalboard,
        onAddEffect: notifier.addEffect,
        effectList: effectList,
      );
    }
    return _LandscapeScaffold(
      metrics: metrics,
      isActive: state.isActive,
      onToggle: notifier.togglePedalboard,
      onAddEffect: notifier.addEffect,
      effectList: effectList,
    );
  }
}

/// The horizontal list of effect cards. Shared by both orientations; only its
/// padding differs (via [PedalboardMetrics]).
class _EffectList extends StatelessWidget {
  const _EffectList({
    required this.listKey,
    required this.chain,
    required this.metrics,
  });

  final Key listKey;
  final List<Effect> chain;
  final PedalboardMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: metrics.bodyPadding,
      child: ListView.custom(
        key: listKey,
        scrollDirection: Axis.horizontal,
        padding: metrics.listPadding,
        childrenDelegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final Effect effect = chain[index];
            return EffectCard(
              name: effect.name,
              canMoveLeft: index != 0,
              canMoveRight: index != chain.length - 1,
              key: ValueKey(effect.name),
            );
          },
          childCount: chain.length,
        ),
      ),
    );
  }
}

/// Portrait: pedalboard control lives in the AppBar.
class _PortraitScaffold extends StatelessWidget {
  const _PortraitScaffold({
    required this.metrics,
    required this.isActive,
    required this.onToggle,
    required this.onAddEffect,
    required this.effectList,
  });

  final PedalboardMetrics metrics;
  final bool isActive;
  final VoidCallback onToggle;
  final void Function(String) onAddEffect;
  final Widget effectList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: metrics.appBarToolbarHeight,
        leading: AddEffectButtonAppBar(
            insertItem: onAddEffect,
            size: metrics.addButtonSize,
            isPortrait: true),
        actions: [
          PedalboardToggle(
            active: isActive,
            size: metrics.toggleSize,
            iconSize: metrics.toggleIconSize,
            onTap: onToggle,
          ),
        ],
      ),
      body: Stack(
        children: [
          const CustomPageBackground(),
          effectList,
        ],
      ),
    );
  }
}

/// Landscape: pedalboard control lives in a side column on the right.
class _LandscapeScaffold extends StatelessWidget {
  const _LandscapeScaffold({
    required this.metrics,
    required this.isActive,
    required this.onToggle,
    required this.onAddEffect,
    required this.effectList,
  });

  final PedalboardMetrics metrics;
  final bool isActive;
  final VoidCallback onToggle;
  final void Function(String) onAddEffect;
  final Widget effectList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const CustomPageBackground(),
          effectList,
          Padding(
            padding: metrics.sideColumnPadding,
            child: SizedBox(
              width: metrics.sideColumnSize.width,
              height: metrics.sideColumnSize.height,
              child: Column(
                children: [
                  Padding(
                    padding: metrics.sideTogglePadding,
                    child: PedalboardToggle(
                      active: isActive,
                      size: metrics.toggleSize,
                      iconSize: metrics.toggleIconSize,
                      onTap: onToggle,
                    ),
                  ),
                  SizedBox(
                    height: metrics.sideSpacerSize.height,
                    width: metrics.sideSpacerSize.width,
                  ),
                  AddEffectButtonAppBar(
                      insertItem: onAddEffect,
                      size: metrics.addButtonSize,
                      isPortrait: false),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
