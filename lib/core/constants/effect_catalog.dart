import '../../domain/entities/effect.dart';
import '../../domain/entities/parameter.dart';
import '../theme/app_colors.dart';

/// The 6 built-in effects, with exact names, parameters and colors as they were
/// previously constructed in `MainPage.initState`.
///
/// Returns fresh instances (with parameter values reset to 0 and `isActive`
/// false) on every call, so callers can safely mutate copies.
List<Effect> buildEffectCatalog() {
  return [
    Effect(
      name: 'Echo',
      color: AppColors.echo,
      parameters: const [
        Parameter(name: 'LEVEL', value: 0),
        Parameter(name: 'TIME', value: 0),
      ],
    ),
    Effect(
      name: 'Delay',
      color: AppColors.delay,
      parameters: const [
        Parameter(name: 'LEVEL', value: 0),
        Parameter(name: 'TIME', value: 0),
      ],
    ),
    Effect(
      name: 'Distortion',
      color: AppColors.distortion,
      parameters: const [
        Parameter(name: 'LEVEL', value: 0),
      ],
    ),
    Effect(
      name: 'Fuzz',
      color: AppColors.fuzz,
      parameters: const [
        Parameter(name: 'LEVEL', value: 0),
        Parameter(name: 'FUZZ', value: 0),
      ],
    ),
    Effect(
      name: 'Overdrive',
      color: AppColors.overdrive,
      parameters: const [
        Parameter(name: 'LEVEL', value: 0),
      ],
    ),
    Effect(
      name: 'Reverb',
      color: AppColors.reverb,
      parameters: const [
        Parameter(name: 'TIME', value: 0),
        Parameter(name: 'WET', value: 0),
      ],
    ),
  ];
}
