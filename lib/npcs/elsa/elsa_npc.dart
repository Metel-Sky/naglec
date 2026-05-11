import '../../models/npc_model.dart';
import '../../models/item_model.dart';
import '../../data/locations_room_data.dart';

const String kElsaGalleryPortraitPath = 'lib/assets/npcs/elsa/elsa_ava.jpg';
const String kElsaAvatarPath = 'lib/assets/npcs/elsa/elsa.png';
const List<int> _weekdays = [0, 1, 2, 3, 4];
const List<int> _weekend = [5, 6];
/// Будні без середи — слот 18:00 у кімнаті (у середу 18–19 місто).
const List<int> _weekdaysElsaRoomAt18 = [0, 1, 3, 4];

/// Особисті речі Elsa, які можуть дуже рідко випадати при обшуку її кімнати.
const List<LootOption> elsaPersonalLoot = [
  LootOption(item: GameItems.panties, weight: 0.1),
  LootOption(item: GameItems.bra, weight: 0.1),
  LootOption(item: GameItems.roomKey, weight: 0.05),
];

/// Модель NPC: Elsa (статистика, розклад, аватар).
NPCModel createElsaNpc() {
  return NPCModel(
    id: 'elsa',
    name: 'Elsa',
    fullName: 'Elsa',
    status: 'Старша сестра',
    age: 18,
    galleryPortraitPath: kElsaGalleryPortraitPath,
    avatarPath: kElsaAvatarPath,
    schedule: [
      SchedulePoint(
        hourStart: 23,
        hourEnd: 6,
        location: LocationsData.elsaRoom,
        actionLabel: 'Спить',
        spritePath: kElsaAvatarPath,
      ),
      SchedulePoint(
        hourStart: 7,
        hourEnd: 7,
        location: LocationsData.bathroom,
        actionLabel: 'Приймає душ',
        spritePath: kElsaAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 8,
        hourEnd: 8,
        location: LocationsData.kitchen,
        actionLabel: 'Снідає',
        spritePath: kElsaAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 9,
        hourEnd: 9,
        location: LocationsData.hall,
        actionLabel: 'Фітнес',
        spritePath: kElsaAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 10,
        hourEnd: 17,
        location: LocationsData.collegeHall,
        days: _weekdays,
        actionLabel: 'У коледжі',
        spritePath: kElsaAvatarPath,
      ),
      SchedulePoint(
        hourStart: 18,
        hourEnd: 18,
        location: LocationsData.elsaRoom,
        actionLabel: 'Займається своїми справами',
        spritePath: kElsaAvatarPath,
        days: _weekdaysElsaRoomAt18,
      ),
      SchedulePoint(
        hourStart: 18,
        hourEnd: 19,
        location: LocationsData.cityOverview,
        actionLabel: 'Гуляє по місту',
        spritePath: '',
        days: [2],
      ),
      SchedulePoint(
        hourStart: 19,
        hourEnd: 19,
        location: LocationsData.hall,
        actionLabel: 'Дивиться телевізор',
        spritePath: kElsaAvatarPath,
        days: _weekdaysElsaRoomAt18,
      ),
      SchedulePoint(
        hourStart: 20,
        hourEnd: 22,
        location: LocationsData.elsaRoom,
        actionLabel: 'Робить уроки',
        spritePath: kElsaAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 8,
        hourEnd: 8,
        location: LocationsData.bathroom,
        spritePath: kElsaAvatarPath,
        days: _weekend,
        actionLabel: 'Приймає душ',
      ),
      SchedulePoint(
        hourStart: 10,
        hourEnd: 12,
        location: LocationsData.kitchen,
        spritePath: kElsaAvatarPath,
        days: _weekend,
        actionLabel: 'Снідає',
      ),
      SchedulePoint(
        hourStart: 13,
        hourEnd: 15,
        location: LocationsData.hall,
        actionLabel: 'Відпочиває вдома',
        spritePath: kElsaAvatarPath,
        days: _weekend,
      ),
      SchedulePoint(
        hourStart: 16,
        hourEnd: 20,
        location: LocationsData.cityOverview,
        actionLabel: 'Гуляє по місту',
        spritePath: '',
        days: _weekend,
      ),
      SchedulePoint(
        hourStart: 21,
        hourEnd: 21,
        location: LocationsData.elsaRoom,
        actionLabel: 'У своїй кімнаті',
        spritePath: kElsaAvatarPath,
        days: [5],
      ),
      SchedulePoint(
        hourStart: 21,
        hourEnd: 22,
        location: LocationsData.elsaRoom,
        actionLabel: 'У своїй кімнаті',
        spritePath: kElsaAvatarPath,
        days: [6],
      ),
    ],
  );
}
