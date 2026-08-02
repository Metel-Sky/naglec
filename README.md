# naglec (Have It All)

Клієнтська гра на **Flutter** з елементами симулятора часу, локацій, діалогів і квестів. Збірка орієнтована на **десктоп** (macOS / Windows / Linux) і **мобільні** платформи; на десктопі використовується `window_manager` для розміру вікна та збереження геометрії.

## Вимоги

- [Flutter](https://docs.flutter.dev/get-started/install) з SDK **^3.10.7** (див. `pubspec.yaml`).
- Для відтворення відео: залежності **media_kit** / **video_player** (див. `pubspec.yaml`).

## Запуск

```bash
cd naglec
flutter pub get
flutter run
```

### Windows: публічний реліз **без чітів**

У `release` чіти **вимкнені на етапі збірки** (немає пункту в налаштуваннях і перемикачів у профілі NPC):

```bash
flutter build windows --release
```

Внутрішній реліз **з чітами**:

```bash
flutter build windows --release --dart-define=ENABLE_CHEATS=true
```

Debug / `flutter run` — чіти доступні за замовчуванням (увімкнути в налаштуваннях). Вимкнути навіть у debug:

```bash
flutter run --dart-define=ENABLE_CHEATS=false
```

Прапорець: `lib/config/app_build_flags.dart` (`AppBuildFlags.cheatsAvailable`).

Якщо після додавання нових файлів у `lib/assets/` вони не потрапляють у бандл, зазвичай допомагає **`flutter clean`** і повторний `flutter run` (у `pubspec.yaml` частина шляхів перелічена явно).

## Структура репозиторію

| Шлях | Призначення |
|------|-------------|
| `lib/main.dart` | Точка входу: `LoadingScreen`, ініціалізація, маршрути, локалізація, десктоп-вікно. |
| `lib/screens/` | Екрани: головна гра (`main_game_screen.dart` + **part**-файли), ноутбук, налаштування, збереження. |
| `lib/locations/` | Віджети зон і кімнат: дім, вулиця, місто, коледж, ТРЦ, бідний район тощо. |
| `lib/services/` | Бізнес-логіка: час (`GameTimeController`), NPC (`NPCService`), збереження, інвентар, світ, навігація, замки дверей тощо. |
| `lib/npcs/` | Окремі персонажі, квести, івенти; збірка списку NPC — `lib/npcs/all_npcs.dart`. |
| `lib/data/` | Дані локацій, розклад коледжу, реєстри взаємодій тощо. |
| `lib/models/` | Моделі (NPC, предмети, розклад `SchedulePoint`). |
| `lib/widgets/` | Спільні UI: діалоги, галерея NPC, рюкзак, відео-оверлеї. |
| `lib/l10n/` | Рядки локалізації (`strings_uk.dart`, `strings_en.dart`, `strings_ru.dart`). |
| `lib/theme/` | Стилі (`GameTheme`). |
| `assets/data/` | JSON даних (наприклад `location.json`). |
| `lib/assets/` | Зображення, відео, спрайти локацій і NPC (шляхи зареєстровані в `pubspec.yaml`). |

## Архітектура коду

### Service locator (GetIt)

У `lib/services/service_locator.dart` реєструються синглтони: `NPCService`, `GameTimeController`, `SaveService`, `PlayerStatsController`, `InventoryController`, `GameWorldState`, `LocaleController`, `GameUiStateController`, `GameNavigationController` тощо. Доступ з будь-якого шару: `sl<ТипСервісу>()`.

### Головний екран гри

`lib/screens/main_game_screen.dart` підключає великий стан через **`part`**: `main_game_screen_state_base.dart`, `main_game_quest_and_zone.dart`, `cherie_game_flow.dart` тощо. Там зосереджені:

- права панель дій (`_buildActionPanel`);
- квестові гілки та івенти;
- перехід між зонами та кімнатами.

### Час і розклад NPC

- **`GameTimeController`** — поточні дата/година гри.
- **`NPCService`** — `getCurrentLocationId`, `getNPCsInRoom`, `representativeSchedulePoint` (узгодження «розклад vs фактична кімната», зокрема коледж і роумінг).
- **`lib/data/college_schedule.dart`** — константи буднів коледжу, години пар/перерв тощо.

### Локації

Ідентифікатори кімнат і метадані — **`lib/data/locations_room_data.dart`**. Окремі `*_view.dart` у `lib/locations/` відповідають за сітку кімнат, фон і оверлеї персонажів у межах зони.

### Збереження

**`SaveService`** серіалізує прогрес (стан світу, інвентар, змінні NPC тощо). Екран завантаження / меню — у `lib/screens/save_load_screen.dart`.

### Локалізація

**`LocaleController`** + ключі в `lib/l10n/strings_*.dart`. Частина UI досі з хардкодженими українськими рядками в івентах — при розширенні варто поступово виносити в l10n.

## Медіа

- Відео: **media_kit** та/або **video_player** (залежить від віджета/сцени).
- Нові ассети додавати в `lib/assets/...` і при потребі — явно в секцію `flutter: assets:` у `pubspec.yaml`.

## Тести та аналіз

```bash
flutter analyze
flutter test
dart run tool/validate_quest_quality_gates.dart
```

## Додаткова документація

- `docs/mom_quests_events.md` — що залишилось із «роботи мами» після прибирання івентів/квестів і що було видалено.
- `docs/quest_runtime_legacy_inventory.md` — інвентар legacy-квестів і карта міграції в runtime.
- `docs/quest_template_and_quality_gates.md` — обов'язковий шаблон квесту та quality gates.

## Ліцензія та публікація

У `pubspec.yaml` вказано `publish_to: 'none'` — проєкт не публікується як пакет на pub.dev.

---

*Документ описує стан репозиторію на момент написання; при зміні архітектури варто оновити розділи «Структура» та «Архітектура».*
