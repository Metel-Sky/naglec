# Папка `laptop/` — відео для ноутбука в грі

Усі шляхи в коді задані від кореня проєкту, наприклад `lib/assets/laptop/study/…`.

Де шукати константи шляхів:

| Розділ | Файл коду |
|--------|-----------|
| Навчання | `lib/screens/laptop/laptop_study_data.dart` |
| Порно (робочий стіл) | `lib/screens/laptop/porn/laptop_porn_data.dart` |
| Компромат (частина шляхів) | `lib/screens/laptop/compromat/laptop_compromat_data.dart` |

Інтернет-магазин і «серфінг» у ноутбуці **не** використовують цю папку для відео (лише UI).

---

## `study/` — навчальні курси (меню «Навчання»)

Поки що **усі уроки одного курсу** використовують **один і той самий** файл `.webm`.

| Файл | Курс у грі |
|------|------------|
| `programing_1.webm` | Програмування |
| `breack_lock.webm` | Відмичка (замки) |
| `stels.webm` | Стелс |
| `unlock_pc.webm` | Паролі |
| `unlock_phone_1.webm` | Телефони |

---

## `study/massage/` — масаж і еро-масаж

| Файл | Призначення |
|------|-------------|
| `massage_1.webm` … `massage_6.webm` | Уроки масажу 1–6 |
| Уроки 7–10 у коді | знову `massage_1` … `massage_4` (цикл) |
| `ero_massage.webm` | Еро-масаж |
| `ero_massage_1.webm` | за наявності — запасне; у `laptop_study_data.dart` поки не підключено |

---

## `porn/` — меню «Порно» на робочому столі

Окремий ярлик ноутбука, не плутати з «Серфінгом».

| Файл | Де використовується |
|------|---------------------|
| `porn_1.webm` … `porn_4.webm` | Пункти порно 1–4 |
| `porn_5.webm` | Окремий п’ятий ролик у списку шляхів; перегляд з пункту 5 обирає **випадково** один з трьох файлів нижче |
| `porn_6.webm`, `porn_7.webm`, `elsa_kompromat_1.webm` | Пункт **5** (випадковий вибір) |

### Компромат і ця папка

Частина відео компромату **лежить у `porn/`**, бо історично спільне сховище роликів:

| Файл | Зв’язок |
|------|---------|
| `piper_kompromat_1.webm` | збережений компромат для NPC `piper` (див. `laptop_compromat_data.dart`) |
| `elsa_kompromat_1.webm` | один із варіантів для пункту порно **5** + сюжетний контекст |

Інші ролики компромату в коді: наприклад відео мами в офісі — `lib/assets/npcs/mom/…`, тестове відео — `lib/assets/gg/…`.

---

## Дерево (очікувані файли)

```
lib/assets/laptop/
├── README.md
├── study/
│   ├── programing_1.webm
│   ├── breack_lock.webm
│   ├── stels.webm
│   ├── unlock_pc.webm
│   ├── unlock_phone_1.webm
│   └── massage/
│       ├── massage_1.webm … massage_6.webm
│       ├── ero_massage.webm
│       └── ero_massage_1.webm   (опційно)
└── porn/
    ├── porn_1.webm … porn_7.webm
    ├── elsa_kompromat_1.webm
    └── piper_kompromat_1.webm
```

Після додавання нових `.webm` переконайся, що вони вказані в **`pubspec.yaml`** (секція `assets`) або підключені через правило на всю папку.
