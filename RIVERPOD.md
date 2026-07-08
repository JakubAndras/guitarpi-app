# RIVERPOD.md — osobní konvence pro Riverpod

> Jednotný způsob, jak používám Riverpod **napříč všemi projekty**. Cíl: jeden mentální
> model, přenositelný mezi appkami. Odchylky jsou povolené, ale musí být vědomé a zdůvodněné.
>
> Tenhle soubor je zdroj pravdy — odkazuj na něj z `CLAUDE.md` / `AGENT.md`, ať se jím řídí
> i AI agenti. Referenční implementace: **guitarpi** (`lib/` clean-architecture + Riverpod).

## Základ (platí bez výjimky)

- **Riverpod 3.x, manuálně — bez codegenu.** Žádné `@riverpod` / `riverpod_generator`.
  (Codegen `json_serializable` pro DTO/DB je OK — netýká se Riverpodu.)
  **Proč ne codegen:** vědomá odchylka od oficiálního doporučení. Chci jeden mentální model
  přenositelný mezi projekty, žádnou build-fázi (`build_runner`) a plnou čitelnost providerů
  v diffu. Cena: víc boilerplate a ruční typové argumenty (`AsyncNotifierProvider<N, T>`) —
  bereme na vědomí.
- **Jen moderní API:** `Notifier` / `AsyncNotifier`. **Nikdy** `StateNotifier`,
  `ChangeNotifier`, `StateProvider` (viz pravidlo 1).
- **Immutabilní stav** + ruční `copyWith` + `Equatable`.

---

## 10 pravidel

### 1. Stav jen přes `Notifier` / `AsyncNotifier`
`StateProvider` / `StateNotifierProvider` / `ChangeNotifierProvider` **zakázány** pro jakýkoli
sdílený nebo byznysový stav. Čistě lokální, efemérní UI toggle (bez byznys významu) neřeš
providerem vůbec — patří do lokálního stavu widgetu (`setState` / `ValueNotifier`). Platí tedy
jednoduše: **provider = sdílený stav → vždy `Notifier` / `AsyncNotifier`.**

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
    // Zachovej předchozí data během loadingu (UI nebliká).
    state = const AsyncLoading<bool>().copyWithPrevious(state);
    state = await AsyncValue.guard(
      () => ref.read(effectTransportProvider).connect(address),
    );
  }
}
```
UI pak čte `state.when(data:…, loading:…, error:…)` nebo `state.value` (nullable) / `hasError`.

> **Pozn. k modelování:** příklad výše (`AsyncNotifier<bool>`) je **záměrně** ten triviální
> dvoustavový případ (odpovídá reálnému `ConnectionNotifier` v guitarpi) — tady `AsyncValue`
> sedí. Jakmile má stav víc než dvě polohy (`disconnected`/`connecting`/`connected`/`error`),
> `AsyncValue` přestává stačit (míchá „načítá se" s byznys hodnotou) → modeluj to jako **sealed
> class / enum v `Notifier`** se stavovým strojem, ne přes `AsyncNotifier`.

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
`Equatable` dává rovnost/hashCode zdarma → čistší rebuild logika i asserty v testech.
**Proč ne `freezed`:** stejná odchylka jako u codegenu (viz Základ) — `freezed` je průmyslový
standard, ale táhne `build_runner`. Vědomě volíme víc boilerplate za nulovou build-fázi.
**Výjimka pro sealed stavové stroje:** u víc-stavových modelů z pravidla 2 (sealed unie
s pattern-matchingem) je ruční zápis výrazně dražší než `Equatable` datová třída. Tam je
`freezed` *lokálně* povolený jako vědomá výjimka — buď ho neber, nebo ruční sealed classes
přijmi i s jejich cenou; nemíchej to nahodile.

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

> **Past ručního `copyWith`:** idiom `x ?? this.x` **neumí** nastavit nullable pole zpět na
> `null`. Když má model nullable pole, které se reálně nuluje, použij sentinel:
> ```dart
> static const _unset = Object();
> Foo copyWith({Object? bar = _unset}) =>
>     Foo(bar: identical(bar, _unset) ? this.bar : bar as String?);
> ```

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
expect(c.read(connectionProvider).value, isTrue);
```

### 9. `family` / `autoDispose`: cílené, s vědomím 3.x defaultů
`family` pro per-id stav. `autoDispose` pro screen-scoped / drahé providery, které mají zaniknout;
`ref.keepAlive()` jen tam, kde stav musí přežít odchod z obrazovky. Riverpod 3 posouvá
`autoDispose` jako preferovaný směr (v codegenu je default) — u manuálního API proto **defaultně
preferuj `autoDispose`** a global kept-alive měj jako vědomou výjimku pro app-scoped stav
(session, connection, prefs).

### 10. Governance
Tenhle `RIVERPOD.md` v každém repu + odkaz z `CLAUDE.md`. U větších appek přidej i **mapu
providerů** (co existuje, co na čem závisí), ať se strom nerozjede.

**Vynucení, ne jen dohoda:** `flutter_lints` tahle pravidla nepokryje. Zapni `riverpod_lint`,
který hlídá typické chyby (public property na notifieru, špatné `read`/`watch` v `build`,
scoped providery bez `dependencies`, …). Bez toho jsou pravidla 1/2/6 jen věc code review, ne CI.

`riverpod_lint` **3.1+** používá první-stranný `analysis_server_plugin` (žádný `custom_lint`,
žádný samostatný runner) — zapíná se v `analysis_options.yaml` a běží přímo přes `dart analyze`:

```yaml
# analysis_options.yaml
plugins:
  riverpod_lint: ^3.1.4
```
Pozor: `riverpod_lint 3.1+` táhne `analyzer ^12`, takže vyžaduje **Dart ≥ 3.10** (Flutter ≥ 3.38;
guitarpi jede na Flutter 3.44.5 přes `fvm`). Na starším SDK zůstaň na `riverpod_lint 3.0.x`,
které ještě jelo přes `custom_lint`.

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
  flutter_riverpod: ^3.0.0
  equatable: ^2.0.5
dev_dependencies:
  mocktail: ^1.0.4
  flutter_lints: ^6.0.0
  # Vynucení konvencí (viz pravidlo 10). 3.1+ = analysis_server_plugin,
  # zapni v analysis_options.yaml a spouštěj přes `dart analyze` (Dart ≥ 3.10).
  riverpod_lint: ^3.1.4
```

> **Migrace 2.x → 3.x:** manuální API (`Notifier` / `AsyncNotifier` / `Provider` /
> `ProviderContainer` / `overrideWith(Value)`) je zdrojově z velké části kompatibilní. Hlavní
> body ke kontrole: přejmenované/deprecated členy, `Ref` typování a chování `autoDispose`.
> Referenční repo (guitarpi) na 3.x **už běží** — `flutter_riverpod` resolved na `3.3.2`
> (constraint `^3.0.0`). Tenhle dokument popisuje cílový stav 3.x, ne plán migrace.
