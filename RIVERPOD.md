# RIVERPOD.md — osobní konvence pro Riverpod

> Jednotný způsob, jak používám Riverpod **napříč všemi projekty**. Cíl: jeden mentální
> model, přenositelný mezi appkami. Odchylky jsou povolené, ale musí být vědomé a zdůvodněné.
>
> Tenhle soubor je zdroj pravdy — odkazuj na něj z `CLAUDE.md` / `AGENT.md`, ať se jím řídí
> i AI agenti. Referenční implementace: **guitarpi** (`lib/` clean-architecture + Riverpod).

## Základ (platí bez výjimky)

- **Riverpod 2.x, manuálně — bez codegenu.** Žádné `@riverpod` / `riverpod_generator`.
  (Codegen `json_serializable` pro DTO/DB je OK — netýká se Riverpodu.)
- **Jen moderní API:** `Notifier` / `AsyncNotifier`. **Nikdy** `StateNotifier`,
  `ChangeNotifier`, `StateProvider` (viz pravidlo 1).
- **Immutabilní stav** + ruční `copyWith` + `Equatable`.

---

## 10 pravidel

### 1. Stav jen přes `Notifier` / `AsyncNotifier`
`StateProvider` / `StateNotifierProvider` / `ChangeNotifierProvider` **zakázány**. Jediná
výjimka: čistě lokální, efemérní UI toggle bez byznys významu (a i to raději `Notifier`).

```dart
// ❌ ne
final connectedProvider = StateProvider<bool>((ref) => false);
final selectedIdProvider = StateProvider<String?>((ref) => null);

// ✅ ano — stav a přechody vlastní jeden Notifier
class ConnectionNotifier extends AsyncNotifier<bool> { ... }
final connectionProvider = AsyncNotifierProvider<ConnectionNotifier, bool>(ConnectionNotifier.new);
```

### 2. Async vždy přes `AsyncNotifier` + `AsyncValue`
Žádné ruční `bool isLoading` / `String? error`. Mutace přes `AsyncValue.guard` (nikdy nehází).

```dart
class ConnectionNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async => false;

  Future<void> connect(String address) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(effectTransportProvider).connect(address),
    );
  }
}
```
UI pak čte `state.when(data:…, loading:…, error:…)` nebo `valueOrNull` / `hasError`.

### 3. Hranice přes abstraktní rozhraní (DIP)
Repozitáře / služby / transporty definuj jako **abstraktní rozhraní v `domain/`**, implementaci
v `data/`. Provider vrací **rozhraní**, ne implementaci. Notifier závisí na rozhraní.

```dart
// domain/repositories/effect_transport.dart
abstract class EffectTransport { Future<bool> connect(String address); ... }

// core/di/providers.dart
final effectTransportProvider = Provider<EffectTransport>((ref) =>
    defaultTargetPlatform == TargetPlatform.android
        ? BluetoothClassicTransport()
        : UnsupportedTransport());
```
Výhoda: záměnnost (Android/iOS/BLE), triviální mockování v testech.

### 4. Modely immutable + `Equatable` + ruční `copyWith`
Žádný `freezed` (drží linii „bez codegenu"). `Equatable` dává rovnost/hashCode zdarma → čistší
rebuild logika i asserty v testech.

```dart
class Parameter extends Equatable {
  final String name; final int value;
  const Parameter({required this.name, required this.value});
  Parameter copyWith({String? name, int? value}) =>
      Parameter(name: name ?? this.name, value: value ?? this.value);
  @override
  List<Object?> get props => [name, value];
}
```

### 5. Umístění providerů: co-location + `core/di`
- **Notifier providery** žijí **vedle svého notifieru** (v `presentation/…`).
- **Infra providery** (repo/transport/db/http/prefs impl) žijí v **`core/di/providers.dart`**,
  aby `domain/` a `data/` zůstaly Riverpod-free.
- Malá appka může mít jeden `core/di/providers.dart` — struktura ať je ale stejná jako u velké.

```
core/di/providers.dart         → effectTransportProvider, presetRepositoryProvider (infra)
presentation/pedalboard/pedalboard_notifier.dart   → pedalboardProvider (co-located)
presentation/connection/connection_notifier.dart   → connectionProvider (co-located)
```

### 6. `ref` disciplína (napevno)
- `ref.watch` v `build()` (UI i Notifier) a na závislosti; `ref.read` **jen** v akcích/callbacích.
- `select` na velký stav kvůli minimalizaci rebuildů.
- **Notifier nikdy nenaviguje ani neukazuje dialog/snackbar.** Notifier mění stav; UI reaguje
  přes `ref.listen`.

```dart
// UI
ref.listen(connectionProvider, (prev, next) {
  if (next.hasError) showSnackBar('Připojení selhalo');
});
final theme = ref.watch(sessionProvider.select((s) => s.themeMode));
```

### 7. `ProviderScope`: default prostý, eskaluj vědomě
Default `ProviderScope(child: MyApp())`. `UncontrolledProviderScope` + vystavený
`ProviderContainer` **jen** když potřebuješ context-less vstupy (notifikace, home-widget,
deep link, background isolate). Nezaváděj to preventivně.

### 8. Testy: unit přes `ProviderContainer` + `overrideWith` + `mocktail`
Každý netriviální notifier má unit test: mockni jeho rozhraní (pravidlo 3), `verify` chování
(vč. „kdy se posílá / volá"). DB/plugin až integračně.

```dart
final c = ProviderContainer(overrides: [
  effectTransportProvider.overrideWithValue(mockTransport),
]);
addTearDown(c.dispose);
await c.read(connectionProvider.notifier).connect('AA:BB');
verify(() => mockTransport.connect('AA:BB')).called(1);
expect(c.read(connectionProvider).valueOrNull, isTrue);
```

### 9. `family` / `autoDispose`: nepovinné, cílené
Nejsou default. Sáhni po nich, když dávají smysl: `family` pro per-id stav, `autoDispose` pro
screen-scoped / drahé providery, které mají zaniknout. Jinak global + kept-alive.

### 10. Governance
Tenhle `RIVERPOD.md` v každém repu + odkaz z `CLAUDE.md`. U větších appek přidej i **mapu
providerů** (co existuje, co na čem závisí), ať se strom nerozjede.

---

## Rychlý checklist při psaní/review

- [ ] Žádný `StateProvider` / legacy Notifier (1)
- [ ] Async přes `AsyncNotifier` + `AsyncValue.guard` (2)
- [ ] Závislosti přes abstraktní rozhraní z `domain/` (3)
- [ ] Model immutable + `Equatable` + `copyWith` (4)
- [ ] Notifier provider co-located, infra v `core/di` (5)
- [ ] `watch`/`read`/`listen` správně; notifier nenaviguje (6)
- [ ] Netriviální notifier má unit test s `overrideWith` (8)

## Standardní balíčky

```yaml
dependencies:
  flutter_riverpod: ^2.5.0
  equatable: ^2.0.5
dev_dependencies:
  mocktail: ^1.0.0
  flutter_lints: ^6.0.0
```
