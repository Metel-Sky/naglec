import '../../models/npc_model.dart';
import '../../data/locations_room_data.dart';

const List<int> _weekdays = [0, 1, 2, 3, 4];
const List<int> _weekend = [5, 6];

/// Галерея — повний портрет; решта UI — аватар.
const String kDanielleGalleryPortraitPath = 'lib/assets/npcs/danielle/danielle_ava.jpg';
const String kDanielleAvatarPath = 'lib/assets/npcs/danielle/danielle.png';

/// Danielle — мати Semа (кориша), менеджерка автосалону.
NPCModel createDanielleNpc() {
  return NPCModel(
    id: 'danielle',
    gender: NpcGender.female,
    name: 'Danielle',
    fullName: 'Danielle',
    status: 'Мати Semа',
    age: 37,
    galleryPortraitPath: kDanielleGalleryPortraitPath,
    avatarPath: kDanielleAvatarPath,
    schedule: [
      // --- Будні ---
      SchedulePoint(
        hourStart: 7,
        hourEnd: 7,
        location: LocationsData.friendKitchen,
        actionLabel: 'На кухні',
        spritePath: kDanielleAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 8,
        hourEnd: 8,
        location: LocationsData.friendBathroom,
        actionLabel: 'У ванній',
        spritePath: kDanielleAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 9,
        hourEnd: 9,
        location: LocationsData.friendParentsRoom,
        actionLabel: 'У кімнаті',
        spritePath: kDanielleAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 10,
        hourEnd: 17,
        location: LocationsData.cityCarDealershipShowroom,
        actionLabel: 'На роботі',
        spritePath: kDanielleAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 18,
        hourEnd: 19,
        location: LocationsData.friendParentsRoom,
        actionLabel: 'У кімнаті',
        spritePath: kDanielleAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 20,
        hourEnd: 20,
        location: LocationsData.friendParentsRoom,
        actionLabel: 'У кімнаті',
        spritePath: kDanielleAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 21,
        hourEnd: 22,
        location: LocationsData.friendParentsRoom,
        actionLabel: 'У кімнаті',
        spritePath: kDanielleAvatarPath,
        days: _weekdays,
      ),
      SchedulePoint(
        hourStart: 23,
        hourEnd: 6,
        location: LocationsData.friendParentsRoom,
        actionLabel: 'Спить',
        spritePath: kDanielleAvatarPath,
        days: _weekdays,
      ),
      // --- Вихідні ---
      SchedulePoint(
        hourStart: 9,
        hourEnd: 9,
        location: LocationsData.friendBathroom,
        actionLabel: 'У ванній',
        spritePath: kDanielleAvatarPath,
        days: _weekend,
      ),
      SchedulePoint(
        hourStart: 10,
        hourEnd: 11,
        location: LocationsData.friendKitchen,
        actionLabel: 'На кухні',
        spritePath: kDanielleAvatarPath,
        days: _weekend,
      ),
      SchedulePoint(
        hourStart: 12,
        hourEnd: 14,
        location: LocationsData.danielleWeekendParkRoam,
        actionLabel: 'Гуляє в парку',
        spritePath: kDanielleAvatarPath,
        days: _weekend,
      ),
      SchedulePoint(
        hourStart: 15,
        hourEnd: 17,
        location: LocationsData.cityVipGym,
        actionLabel: 'VIP тренажерка',
        spritePath: kDanielleAvatarPath,
        days: _weekend,
      ),
      SchedulePoint(
        hourStart: 15,
        hourEnd: 17,
        location: LocationsData.friendHomeDanielleWeekendNoVipRoam,
        actionLabel: 'Вдома',
        spritePath: kDanielleAvatarPath,
        days: _weekend,
      ),
      SchedulePoint(
        hourStart: 18,
        hourEnd: 20,
        location: LocationsData.cityOverview,
        actionLabel: 'Гуляє містом',
        spritePath: kDanielleAvatarPath,
        days: _weekend,
      ),
      SchedulePoint(
        hourStart: 21,
        hourEnd: 22,
        location: LocationsData.friendHall,
        actionLabel: 'У залі (ТБ)',
        spritePath: kDanielleAvatarPath,
        days: _weekend,
      ),
      SchedulePoint(
        hourStart: 23,
        hourEnd: 6,
        location: LocationsData.friendParentsRoom,
        actionLabel: 'Спить',
        spritePath: kDanielleAvatarPath,
        days: _weekend,
      ),
    ],
  );
}
