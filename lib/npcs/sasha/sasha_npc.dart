import '../../models/npc_model.dart';
import '../../data/locations_room_data.dart';

const List<int> _weekdays = [0, 1, 2, 3, 4];
const List<int> _tueThu = [1, 3];
/// Понеділок, середа, п’ятниця — окремі слоти 18 (ванна) / 19 (зал).
const List<int> _monWedFri = [0, 2, 4];
const List<int> _weekend = [5, 6];

const String kSashaGalleryPortraitPath = 'lib/assets/npcs/sasha/sasha_ava.jpg';
const String kSashaAvatarPath = 'lib/assets/npcs/sasha/sasha.png';
/// У кафе в парку (розклад).
const String kSashaCafeWaiterPath = 'lib/assets/npcs/sasha/sasha_waiter.png';

/// Sasha — старша сестра Semа, кафе в парку.
NPCModel createSashaNpc() {
  return NPCModel(
    id: 'sasha',
    gender: NpcGender.female,
    name: 'Sasha',
    fullName: 'Sasha',
    status: 'Сестра Semа',
    bodyDescription:
        'Виглядає дорого й упевнено, звично підкреслює фігуру. У публіці вміє бути відверто «на показ», але водночас грає недоступну.',
    biographyType:
        'Дівчина з сусіднього дому, сестра найкращого друга — і заразлива стерва. Змалку, коли бігала за нами в сукні в горошок і з двома косичками, при першій нагоді здавала нас дорослим. Згодом її інтереси змістилися на музику, гроші й забезпечених хлопців, а ми остаточно перетворилися для неї на нікчемну безстатеву дрібницю. Навіть брата вона не переварювала: батьки, бачте, забагато на нього витрачають сил і грошей. Попри все виляння хвостом, дівчина знає свою ціну, морочить голову так, що мозок кипить, а коли доходить до ліжка — вдає з себе непорочну й відсуває. Хтось у неї уже був, звісно, але з такими апетитами тримається ніби черниця. Перший об\'єкт моїх бажань: саме на неї вперше «вставало» — ну я так Сашці й кажу :)',
    biographyAppearance:
        'Дитинство: сукня в горошок, дві косички, завжди поруч і завжди готова підставити. Зовнішній імідж — спокуса й «недоторканість» водночас: до ліжка ніби не допускає, хоча всі здогадуються, що наївності там немає.',
    age: 21,
    trust: 0,
    love: 0,
    galleryPortraitPath: kSashaGalleryPortraitPath,
    avatarPath: kSashaAvatarPath,
    schedule: [
      // --- Будні (пн–пт) ---
      SchedulePoint(
        hourStart: 7,
        hourEnd: 7,
        location: LocationsData.friendBathroom,
        actionLabel: 'У ванній',
        spritePath: kSashaAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 8,
        hourEnd: 8,
        location: LocationsData.friendKitchen,
        actionLabel: 'На кухні',
        spritePath: kSashaAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 9,
        hourEnd: 9,
        location: LocationsData.friendSisterRoom,
        actionLabel: 'У кімнаті',
        spritePath: kSashaAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 10,
        hourEnd: 17,
        location: LocationsData.cityParkCafe,
        actionLabel: 'На роботі',
        spritePath: kSashaCafeWaiterPath,
        days: _weekdays,
      ),
      // Пн / Ср / Пт: 18 — ванна, 19 — зал. Вт / Чт: 18–19 VIP (з абонементом) або зал.
      SchedulePoint(
        hourStart: 18,
        hourEnd: 18,
        location: LocationsData.friendBathroom,
        actionLabel: 'У ванній',
        spritePath: kSashaAvatarPath,
        days: _monWedFri,
      ),
      SchedulePoint(
        hourStart: 19,
        hourEnd: 19,
        location: LocationsData.friendHall,
        actionLabel: 'У залі',
        spritePath: kSashaAvatarPath,
        days: _monWedFri,
      ),
      SchedulePoint(
        hourStart: 18,
        hourEnd: 19,
        location: LocationsData.cityVipGym,
        actionLabel: 'VIP тренажерка',
        spritePath: kSashaAvatarPath,
        days: _tueThu,
      ),
      SchedulePoint(
        hourStart: 18,
        hourEnd: 19,
        location: LocationsData.friendHall,
        actionLabel: 'У залі',
        spritePath: kSashaAvatarPath,
        days: _tueThu,
      ),
      SchedulePoint(
        hourStart: 20,
        hourEnd: 20,
        location: LocationsData.friendKitchen,
        actionLabel: 'На кухні',
        spritePath: kSashaAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 21,
        hourEnd: 22,
        location: LocationsData.friendSisterRoom,
        actionLabel: 'У кімнаті',
        spritePath: kSashaAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 23,
        hourEnd: 6,
        location: LocationsData.friendSisterRoom,
        actionLabel: 'Спить',
        spritePath: kSashaAvatarPath,
        days: _weekdays,
      ),
      // --- Вихідні ---
      SchedulePoint(
        hourStart: 0,
        hourEnd: 8,
        location: LocationsData.friendSisterRoom,
        actionLabel: 'Спить',
        spritePath: kSashaAvatarPath,
        days: [5],
      ),
      SchedulePoint(
        hourStart: 0,
        hourEnd: 3,
        location: LocationsData.friendSisterRoom,
        actionLabel: 'Спить',
        spritePath: kSashaAvatarPath,
        days: [6],
      ),
      SchedulePoint(
        hourStart: 9,
        hourEnd: 9,
        location: LocationsData.friendBathroom,
        actionLabel: 'У ванній',
        spritePath: kSashaAvatarPath,
        days: _weekend,
      ),
      SchedulePoint(
        hourStart: 10,
        hourEnd: 11,
        location: LocationsData.friendKitchen,
        actionLabel: 'На кухні',
        spritePath: kSashaAvatarPath,
        days: _weekend,
      ),
      SchedulePoint(
        hourStart: 12,
        hourEnd: 14,
        location: LocationsData.cityOverview,
        actionLabel: 'Гуляє містом',
        spritePath: kSashaAvatarPath,
        days: _weekend,
      ),
      SchedulePoint(
        hourStart: 15,
        hourEnd: 17,
        location: LocationsData.friendSisterRoom,
        actionLabel: 'У кімнаті',
        spritePath: kSashaAvatarPath,
        days: _weekend,
      ),
      SchedulePoint(
        hourStart: 18,
        hourEnd: 18,
        location: LocationsData.friendBathroom,
        actionLabel: 'У ванній',
        spritePath: kSashaAvatarPath,
        days: _weekend,
      ),
      SchedulePoint(
        hourStart: 19,
        hourEnd: 20,
        location: LocationsData.cityOverview,
        actionLabel: 'Гуляє містом',
        spritePath: kSashaAvatarPath,
        days: _weekend,
      ),
      SchedulePoint(
        hourStart: 21,
        hourEnd: 22,
        location: LocationsData.friendHall,
        actionLabel: 'У залі (ТБ)',
        spritePath: kSashaAvatarPath,
        days: _weekend,
      ),
      // Нд вечір — клуб «на морі» (фактична кімната в [NPCService]); пн 0–3 — продовження ночі.
      SchedulePoint(
        hourStart: 22,
        hourEnd: 23,
        location: LocationsData.outOfTownClub,
        actionLabel: 'У клубі',
        spritePath: kSashaAvatarPath,
        days: [6],
      ),
      SchedulePoint(
        hourStart: 0,
        hourEnd: 3,
        location: LocationsData.outOfTownClub,
        actionLabel: 'У клубі',
        spritePath: kSashaAvatarPath,
        days: [0],
      ),
      SchedulePoint(
        hourStart: 4,
        hourEnd: 8,
        location: LocationsData.friendSisterRoom,
        actionLabel: 'Спить',
        spritePath: kSashaAvatarPath,
        days: [6],
      ),
      SchedulePoint(
        hourStart: 23,
        hourEnd: 23,
        location: LocationsData.friendSisterRoom,
        actionLabel: 'Спить',
        spritePath: kSashaAvatarPath,
        days: [5],
      ),
    ],
  );
}
