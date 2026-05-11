import '../../models/npc_model.dart';
import '../../data/locations_room_data.dart';

const List<int> _weekdays = [0, 1, 2, 3, 4];
const List<int> _weekend = [5, 6];

const String kSemGalleryPortraitPath = 'lib/assets/npcs/sem/sem_ava.jpg';
const String kSemAvatarPath = 'lib/assets/npcs/sem/sem.png';

/// Sem (кориш) — коледж 10–17 у будні (той самий роумінг, що й одногрупниці).
NPCModel createSemNpc() {
  return NPCModel(
    id: 'sem',
    gender: NpcGender.male,
    name: 'Sem',
    fullName: 'Sem',
    status: 'Кориш',
    age: 18,
    galleryPortraitPath: kSemGalleryPortraitPath,
    avatarPath: kSemAvatarPath,
    schedule: [
      // --- Будні ---
      SchedulePoint(
        hourStart: 7,
        hourEnd: 8,
        location: LocationsData.friendKitchen,
        actionLabel: 'На кухні',
        spritePath: kSemAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 9,
        hourEnd: 9,
        location: LocationsData.friendRoom,
        actionLabel: 'У кімнаті',
        spritePath: kSemAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 10,
        hourEnd: 17,
        location: LocationsData.collegeHall,
        actionLabel: 'У коледжі',
        spritePath: kSemAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 18,
        hourEnd: 20,
        location: LocationsData.friendHomeSemEveningRoam,
        actionLabel: 'Вдома',
        spritePath: kSemAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 21,
        hourEnd: 21,
        location: LocationsData.friendKitchen,
        actionLabel: 'На кухні',
        spritePath: kSemAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 22,
        hourEnd: 22,
        location: LocationsData.friendRoom,
        actionLabel: 'У своїй кімнаті',
        spritePath: kSemAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 23,
        hourEnd: 6,
        location: LocationsData.friendRoom,
        actionLabel: 'Спить',
        spritePath: kSemAvatarPath,
        days: _weekdays,
      ),
      // --- Вихідні ---
      SchedulePoint(
        hourStart: 9,
        hourEnd: 11,
        location: LocationsData.friendRoom,
        actionLabel: 'У кімнаті',
        spritePath: kSemAvatarPath,
        days: _weekend,
      ),
      SchedulePoint(
        hourStart: 12,
        hourEnd: 14,
        location: LocationsData.cityOverview,
        actionLabel: 'Гуляє містом',
        spritePath: kSemAvatarPath,
        days: _weekend,
      ),
      SchedulePoint(
        hourStart: 15,
        hourEnd: 17,
        location: LocationsData.poorDistrictGym,
        actionLabel: 'У залі (качалка)',
        spritePath: kSemAvatarPath,
        days: _weekend,
      ),
      SchedulePoint(
        hourStart: 18,
        hourEnd: 20,
        location: LocationsData.friendRoom,
        actionLabel: 'У кімнаті',
        spritePath: kSemAvatarPath,
        days: _weekend,
      ),
      SchedulePoint(
        hourStart: 21,
        hourEnd: 22,
        location: LocationsData.friendHall,
        actionLabel: 'У залі',
        spritePath: kSemAvatarPath,
        days: _weekend,
      ),
      SchedulePoint(
        hourStart: 23,
        hourEnd: 6,
        location: LocationsData.friendRoom,
        actionLabel: 'Спить',
        spritePath: kSemAvatarPath,
        days: _weekend,
      ),
    ],
  );
}
