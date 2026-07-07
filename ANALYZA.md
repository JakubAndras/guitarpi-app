# Analýza projektu GuitarPi (bc_ui_flutter)

> Frontend bakalářské práce „Sada zvukových nástrojů" — Flutter aplikace, která přes Bluetooth
> ovládá kytarové efekty běžící na Raspberry Pi. Tento dokument popisuje **aktuální stav**,
> **kvalitu implementace**, míru dodržení **clean architecture** principů a **návrh refactoru**.

Datum analýzy: 2026-07-07 · Rozsah: ~3 250 řádků Dart kódu ve 26 souborech · Historie: 1 commit.

---

## 1. Shrnutí (TL;DR)

Aplikace **funguje** na cílové platformě (Android) a má slušný rozsah funkcí (pedalboard,
efekty, presety, orientace portrait/landscape). Z pohledu **softwarové architektury a
udržovatelnosti je ale ve špatném stavu** — jde o typický „vše ve widgetech" prototyp
bez vrstvení, bez správy stavu, s globálním mutovatelným stavem a s byznys logikou,
serializací i I/O namíchanými přímo v UI.

**Clean architecture principy nejsou dodrženy prakticky vůbec.** Nejde o kritiku autora
(je to bakalářská práce), ale o realistické zhodnocení: pro další rozvoj (zejména iOS,
testovatelnost, přidávání efektů) je vhodný **strukturální refactor**, ne jen kosmetika.

| Oblast | Hodnocení | Poznámka |
|---|:---:|---|
| Funkčnost (Android) | 🟢 dobrá | Splňuje účel |
| Tech stack / knihovny | 🟡 zastaralé | Migrováno na Dart 3, ale volby jsou legacy |
| Architektura / vrstvení | 🔴 slabé | Žádné vrstvy, porušená dependency rule |
| Správa stavu | 🔴 slabé | Globální statika + stav ve widgetech |
| Čistota kódu | 🟡 průměrná | Mrtvý kód, magic numbers, duplicita |
| Testovatelnost | 🔴 slabé | Prakticky nulová, žádné testy |
| Přenositelnost (iOS) | 🔴 slabé | BT Classic je Android-only |

---

## 2. Tech stack

| Vrstva | Technologie |
|---|---|
| Jazyk / framework | Dart, Flutter (SDK migrováno z 2.16 na 3.x) |
| UI | Material, vlastní widgety |
| Perzistence | `shared_preferences` (JSON v klíč-hodnota) |
| Komunikace | `flutter_bluetooth_serial` (Bluetooth Classic / SPP) |
| Pomocné | `wakelock_plus` (displej), `decorated_icon` (ikony se stínem) |

### Použité knihovny

| Balíček | Stav | Komentář |
|---|---|---|
| `flutter_bluetooth_serial ^0.4.0` | ⚠️ Android-only, prakticky neudržovaný | Klíčová závislost. Bluetooth Classic SPP — na iOS nefunguje (viz §7). |
| `shared_preferences` | ✅ ok | Vhodné pro presety, ale používáno přímo z widgetů. |
| `wakelock_plus` | ✅ ok | Náhrada za discontinued `wakelock`. |
| `decorated_icon` | 🟡 kosmetika | Malá závislost jen kvůli stínům ikon. |
| ~~`scoped_model`~~ | ❌ deklarováno, nepoužito | State-management lib, kterou nikdo nezavolal. |
| ~~`curved_navigation_bar`~~ | ❌ nepoužito | Odstraněno. |
| ~~`flutter_staggered_grid_view`~~ | ❌ nepoužito | Odstraněno. |
| ~~`very_good_analysis`~~ | ❌ blokovalo resolving | Odstraněno. |

> Poznámka: přítomnost `scoped_model` v `pubspec.yaml`, který se v kódu nikdy nepoužil, dobře
> ilustruje stav správy stavu — nástroj byl zamýšlen, ale nakonec se skončilo u `setState`
> a globální statiky.

### 2.1 Verze knihoven — co reálně navýšit

„Navýšit knihovny" znamená dvě odlišné věci s velmi rozdílnou hodnotou.

**a) Bump verzí současných balíčků — nízká hodnota.** Podle `flutter pub outdated` je většina
už na maximu v rámci constraintů. Reálně jde bumpnout jen:

| Balíček | Teď | Nejnovější | Akce |
|---|---|---|---|
| `flutter_lints` (dev) | 5.0.0 | 6.0.0 | bump constraintu na `^6.0.0` |
| `wakelock_plus` | 1.4.0 | 1.6.1 | `flutter pub upgrade`, minor |

`flutter_bluetooth_serial`, `shared_preferences`, `decorated_icon`, `cupertino_icons` jsou
už na nejvyšší dostupné verzi — tady není co navyšovat.

**b) Strategická výměna knihoven — vysoká hodnota (tohle je ten podstatný upgrade).**
Důležitější než čísla verzí je, čím knihovny při refactoru nahradit / co přidat:

| Účel | Přidat / vyměnit | Proč |
|---|---|---|
| Stav + DI | `flutter_riverpod` | Nahradí `setState` + globální statiku. |
| Value modely | `equatable` (+ ruční `copyWith`) | Immutabilní doména bez fragilního codegenu. |
| Bluetooth | ⚠️ `flutter_bluetooth_serial` je neudržovaný, Android-only. Zvážit `flutter_blue_plus` (BLE). | Aktivně vyvíjené, otevírá iOS (vyžaduje i BLE firmware na Pi). |
| Testy | `mocktail` | Mockování transport/repo v unit testech. |

> Klíč: `flutter_bluetooth_serial` bumpnout **nejde** (konec vývoje) — jediné skutečné
> „navýšení" téhle závislosti je ji **nahradit** BLE stackem za transport rozhraním.

---

## 3. Struktura projektu

```
lib/
├── main.dart                 # entrypoint, MaterialApp
├── Home.dart                 # BottomNavigationBar + IndexedStack (3 stránky)
├── page/
│   ├── ConnectionPage.dart   # BT nastavení
│   ├── DiscoveryPage.dart    # BT discovery
│   ├── SelectBondedDevicePage.dart
│   ├── MainPage.dart         # pedalboard (hlavní logika)
│   ├── MainPageTest.dart     # ⚠️ MRTVÝ KÓD (nikde nereferencováno)
│   ├── PresetPage.dart       # ⚠️ MRTVÝ KÓD (nikde nereferencováno)
│   └── HelpPage.dart
├── widget/
│   ├── EffectWidget.dart     # 610 ř. — „god widget"
│   ├── SliderWidget.dart
│   ├── ... (custom slider, background, add_effect/*)
├── model/
│   ├── Effect.dart           # string konstanty
│   ├── EffectPresetModel.dart# datové modely + (de)serializace
│   ├── SliderController.dart # ⚠️ globální mutovatelný stav (static)
│   ├── AppColors.dart        # UI konstanty (ne „model")
│   └── BluetoothServer.dart  # ⚠️ globální statika pro connection target
├── data/
│   └── EffectPreset.dart     # hardcoded, nepoužitý seznam
└── utils/
    ├── PresetSharedPreferences.dart  # wrapper nad shared_preferences (static)
    └── BluetoothSupport.dart         # platform guard (přidáno při opravách)
```

**Adresáře `model/`, `data/`, `utils/` navozují vrstvení, ale ve skutečnosti ho nezavádějí** —
je to členění „podle typu souboru", ne podle odpovědnosti nebo vrstvy. `model/` obsahuje
zároveň datové třídy, globální stav i UI konstanty.

---

## 4. Clean architecture — posouzení

Krátká odpověď: **principy dodrženy nejsou.** Rozbor podle jednotlivých pravidel:

### 4.1 Oddělení vrstev (Separation of Concerns) — ❌
Neexistuje hranice mezi **prezentací**, **doménou** a **daty**. Konkrétně `MainPage` a
`EffectWidget` současně:
- renderují UI,
- drží a mutují aplikační stav (pořadí efektů, aktivní stav),
- serializují doménu do JSON (`_EffectSettings`, `_SimpleEffect` + `jsonEncode`),
- posílají bajty do Bluetooth outputu (`connection!.output.add(...)`),
- čtou a zapisují do `SharedPreferences`.

To vše v jednom `build()`/`setState()` toku.

### 4.2 Dependency Rule (závislosti směřují dovnitř) — ❌
UI vrstva volá **přímo** infrastrukturu:
- `FlutterBluetoothSerial.instance...` přímo z `ConnectionPage`, `DiscoveryPage`, `MainPage`.
- `PresetSharedPreferences` (tedy `shared_preferences`) přímo z `EffectWidget`.
- `SliderController` statiku přímo z widgetů.

Chybí abstrakce (rozhraní/repozitáře), přes které by UI komunikovalo s okolím. Doména
neexistuje jako samostatná, na frameworku nezávislá vrstva.

### 4.3 Dependency Injection — ❌
Žádné DI. Vše se buď instancuje na místě (`SliderController()`, `_MainPage()`), nebo se
sahá na globální statiku. To znemožňuje záměnu implementace a testování s mocky.

### 4.4 Testovatelnost — ❌
Kvůli globálnímu stavu a přímým voláním pluginů je logika prakticky netestovatelná bez
reálného zařízení. `test/widget_test.dart` je nezměněná šablona (testuje neexistující čítač).

### 4.5 Jediná odpovědnost (SRP) — ❌
`EffectWidget` (610 ř.) je učebnicový „god object". `MainPage` míchá UI, orchestraci a
protokol.

> **Závěr:** projekt odpovídá stylu „rychlý funkční prototyp". To je pro bakalářskou práci
> legitimní, ale je to protipól clean architecture.

---

## 5. Kvalita implementace — konkrétní nálezy

### 5.1 Reálné bugy

| # | Soubor | Popis |
|---|---|---|
| B1 | `MainPage.dart:70` | **`connection = connection;`** — přiřazení parametru sám sobě (shadowing). Field `connection` se po úspěšném připojení nikdy nenastaví, takže `isConnected` je vždy `false` a `_sendMessage` posílá do `null`. Data se reálně odešlou jen shodou okolností / vůbec. **Kritické.** |
| B2 | `MainPage.dart:401` | `_sendMessage` spoléhá na `connection!` v `try/catch`, který chybu jen spolkne a zavolá `setState`. Ve spojení s B1 to maskuje, že se nic neposílá. |
| B3 | `EffectWidget.dart` | Stav (`isActive`, `presets`, `currentPreset`) je uložen v **objektu Widgetu**, ne ve `State`. Při rebuildu/rekreaci widgetu hrozí ztráta stavu; drženo naživu jen přes `AutomaticKeepAliveClientMixin`. |

### 5.2 Mrtvý kód
- `page/MainPageTest.dart` (324 ř.) a `page/PresetPage.dart` (153 ř.) — **nikde nereferencované** (~15 % codebase).
- `data/EffectPreset.dart` — hardcoded `allEffectWithPresets`, nepoužito.
- Zakomentované bloky (`EffectWidget.dart:401-416`).

### 5.3 Globální mutovatelný stav
- `SliderController` — 12 statických `double` polí + 90 řádků ručního `switch` mapování jmen na pole. Mělo by jít o `Map<String,double>` nebo (lépe) o stav ve state-management vrstvě. Statika = sdíleno globálně, netestovatelné, kolize.
- `BluetoothServer.server` — statický `BluetoothDevice?` sloužící jako skrytý globální parametr mezi stránkami.

### 5.4 Doména vs. UI vs. wire formát
- Neoddělené: `_SimpleEffect`/`_EffectSettings` (privátní třídy uvnitř `MainPage`) slouží zároveň jako doménový model i jako drátový (JSON) formát posílaný na Pi. Změna protokolu = zásah do UI souboru.
- `AppColors` je v `model/`, ač jde o UI konstanty.

### 5.5 Layout a duplicita
- Rozsáhlé **magic numbers** (`mobileHeight * 0.185`, `width: 63.6`, `Color.fromRGBO(43,41,41,70)` — pozn.: čtvrtý parametr opacity `70` je mimo rozsah 0–1, tiše se clampne).
- Portrait a landscape větve jsou z velké části **duplikované** stromy widgetů s jinými konstantami → těžká údržba.
- `EffectWidget` volá `super.build(context)` dvakrát (v `build` i `buildWidget`).

### 5.6 Pojmenování a konvence
- Soubory v `PascalCase` (nekonvenční pro Dart, ale konzistentní — lint vypnut záměrně).
- Konstanty efektů v `UPPER_CASE` (doménové, akceptovatelné).

### 5.7 Silné stránky (objektivně)
- Aplikace plní účel a je funkční na Androidu.
- Modely mají `toJson`/`fromJson` (základ pro serializaci).
- Kód je null-safe a po migraci prochází `flutter analyze` bez chyb.
- Responzivita portrait/landscape je vyřešená (byť neelegantně).

---

## 6. Návrh refactoru

Cíl: **udržovatelná, testovatelná a rozšiřitelná** aplikace s možností budoucí podpory iOS.
Doporučuji vrstvenou (clean-ish) architekturu, **feature-first** členění a zavedení
state managementu.

### 6.1 Cílová architektura (vrstvy)

```
lib/
├── core/            # konstanty, téma, utils, DI
├── domain/          # ČISTÁ doména — bez Flutteru
│   ├── entities/    # Effect, Parameter, Preset, PedalboardState (immutable)
│   ├── repositories/# abstraktní rozhraní: EffectTransport, PresetRepository
│   └── usecases/    # ConnectToDevice, SendPedalboard, SavePreset, ...
├── data/            # implementace repozitářů
│   ├── bluetooth/   # BluetoothClassicTransport (Android) + budoucí BleTransport (iOS)
│   ├── persistence/ # SharedPreferencesPresetRepository
│   └── dto/         # wire (JSON) modely + mapování na doménu
└── presentation/    # UI podle feature
    ├── connection/
    ├── pedalboard/
    └── help/
```

**Klíč:** UI závisí na `domain` (rozhraních), nikdy přímo na `flutter_bluetooth_serial`
ani `shared_preferences`. Konkrétní implementace se dodávají přes DI.

### 6.2 Doporučené knihovny

| Účel | Doporučení | Proč |
|---|---|---|
| Správa stavu + DI | **Riverpod** (`flutter_riverpod`) | Nahradí `setState` i globální statiku, dává testovatelné providery, DI zdarma. (Alternativa: `flutter_bloc`.) |
| Immutable modely | **freezed** + **json_serializable** | Vygenerované `copyWith`/`==`/`toJson`, oddělí DTO od domény, zruší ruční serializaci. |
| Bluetooth (abstrakce) | rozhraní `EffectTransport` s implementacemi | `flutter_bluetooth_serial` pro Android; `flutter_blue_plus` (BLE) jako cesta k iOS. |
| Testy | `mocktail` | Mockování repozitářů v unit testech. |

### 6.3 Konkrétní kroky (v pořadí priority)

**Fáze 0 — úklid (rychlé, nízké riziko)**
1. Smazat mrtvý kód: `MainPageTest.dart`, `PresetPage.dart`, `data/EffectPreset.dart`, zakomentované bloky.
2. Opravit bug B1 (`connection = connection;` → `this.connection = connection;`).
3. Přesunout `AppColors` z `model/` do `core/theme/`.

**Fáze 1 — doména a transport**
4. Zavést immutable doménové entity (`Effect`, `Parameter`, `Preset`, `PedalboardState`) přes freezed.
5. Vytáhnout wire protokol (JSON) z `MainPage` do `data/dto` + mapperu.
6. Definovat `EffectTransport` rozhraní (`connect`, `disconnect`, `send(PedalboardState)`, `stateStream`) a implementovat `BluetoothClassicTransport`.
7. Definovat `PresetRepository` a implementovat nad `shared_preferences`.

**Fáze 2 — stav a DI**
8. Zavést Riverpod; nahradit `SliderController` statiku a stav ve widgetech `Notifier`/`StateNotifier` providery.
9. Zrušit `BluetoothServer.server` statiku — cílové zařízení držet v providerech.
10. Odstranit anti-pattern, kdy `MainPage` widget drží referenci na svůj `State`.

**Fáze 3 — UI**
11. Rozbít `EffectWidget` na menší komponenty (hlavička, řazení, parametry, presety, on/off).
12. Sjednotit portrait/landscape (parametrizace, ne duplicitní stromy); nahradit magic numbers pojmenovanými konstantami / `LayoutBuilder`.

**Fáze 4 — kvalita**
13. Napsat unit testy domény a use-cases (transport/repo mockované), widget testy klíčových stránek.
14. Zvážit CI (analyze + test).

**Fáze 5 — iOS (volitelně, větší rozsah)**
15. Doplnit `BleTransport` (`flutter_blue_plus`) za stejným `EffectTransport` rozhraním.
16. Vyžaduje i úpravu firmwaru na Raspberry Pi (BLE GATT místo Bluetooth Classic SPP) + `Info.plist` entitlementy.

### 6.4 Sjednocení portrait/landscape

Problém teď: **stejný konceptuální prvek je napsaný dvakrát** — jednou v portrait, jednou
v landscape větvi, jen s jinými čísly (např. play/pause toggle v `MainPage` na ř. ~144 a ~234,
duplicitní stromy v `EffectWidget`). Sjednocení stojí na třech technikách:

**1) Opakovaný prvek = jeden widget parametrizovaný rozměrem** (píše se jednou, volá z obou větví):

```dart
class PedalboardToggle extends StatelessWidget {
  const PedalboardToggle({required this.active, required this.size, required this.onTap, super.key});
  final bool active; final Size size; final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox.fromSize(
    size: size,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: active ? Colors.green : Colors.red,
        border: Border.all(color: Colors.white54, width: 1.2),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          child: Icon(active ? Icons.pause_rounded : Icons.play_arrow_rounded, size: size.height * 0.9),
        ),
      ),
    ),
  );
}
```

**2) Rozměry z jednoho místa (orientation-derived config)** místo roztroušených magic numbers:

```dart
class PedalboardMetrics {
  PedalboardMetrics(BuildContext c)
      : _s = MediaQuery.sizeOf(c),
        portrait = MediaQuery.orientationOf(c) == Orientation.portrait;
  final Size _s; final bool portrait;

  Size get toggle => portrait ? const Size(66, 46) : Size(_s.width * 0.08, _s.height * 0.185);
  double get cardWidth => portrait ? _s.width - 6 : _s.width * 0.3;
  // ... všechna „0.185", „63.6" apod. mají jméno a jsou na jednom místě
}
```

**3) Kde se strom strukturálně liší** (portrait = ovládání v `AppBar`, landscape = boční sloupec),
neduplikovat inline, ale mít `_PortraitScaffold` / `_LandscapeScaffold`, které oba skládají
**tytéž leaf widgety** — jen jinak rozmístěné.

Navíc nahradit `mobileHeight * 0.185` konstrukcemi `Expanded`/`Flexible`/`AspectRatio`/
`LayoutBuilder`, ať layout nezávisí na konkrétní výšce displeje (to je přesně příčina overflow
na iPhonu). Pravidlo: *jeden parametrizovaný strom, sdílené komponenty, čísla pojmenovaná na jednom místě.*

### 6.5 Očekávaný přínos
- Testovatelná byznys logika bez zařízení.
- Přidání nového efektu = změna v doméně/datech, ne v UI.
- Otevřená cesta k iOS bez přepisu UI (jen nová implementace transportu).
- Menší, čitelnější widgety; méně duplicity.

---

## 7. Poznámka k iOS

Aktuálně appka na iOS **nastartuje a UI funguje**, ale Bluetooth ne:
`flutter_bluetooth_serial` je Android-only (na iOS se plugin ani nezaregistruje) a iOS
navíc neumožňuje Bluetooth Classic SPP k necertifikovanému hardwaru (jen BLE). Volání BT
jsou nyní ošetřena platform guardem (`utils/BluetoothSupport.dart`), takže místo pádu
`MissingPluginException` se zobrazí hláška. Plná podpora iOS je součástí Fáze 5 výše.

---

## 8. Závěr

Projekt je **funkční prototyp**, který svůj účel (Android ovládání efektů) splní. Pro
**další rozvoj, údržbu a přenositelnost** je ale současná architektura limitující:
chybí vrstvení, doména, správa stavu i testovatelnost a je porušena dependency rule.

Doporučení: **postupný refactor** dle §6 — začít úklidem a opravou bugu B1, poté zavést
doménu + transport abstrakci + Riverpod. Není nutné přepisovat vše najednou; klíčové je
zavést hranice mezi UI, doménou a infrastrukturou, od nichž se dá dál stavět (včetně iOS).
