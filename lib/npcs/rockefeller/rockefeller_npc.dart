import '../../models/npc_model.dart';
import '../../data/locations_room_data.dart';

const List<int> _weekdays = [0, 1, 2, 3, 4];

/// Аватар у лівій смузі вибору NPC та в профілі / телефоні.
const String kRockefellerAvatarPath =
    'lib/assets/npcs/rockefeller/rockefeller_ava.png';

/// Растр у сцені локації (коли NPC у приміщенні за розкладом).
const String kRockefellerRoomSpritePath =
    'lib/assets/location/biznes_centr/rokfeller_first.jpg';

/// Рокфеллер — другорядний NPC (як Лошок): без галереї, окремі квести підключатимуться в [rockefeller_events].
NPCModel createRockefellerNpc() {
  return NPCModel(
    id: 'rockefeller',
    name: 'Рокфеллер',
    fullName: 'Рокфеллер',
    status: 'Бізнесмен',
    age: 52,
    gender: NpcGender.male,
    galleryPortraitPath: kRockefellerAvatarPath,
    avatarPath: kRockefellerAvatarPath,
    schedule: [
      SchedulePoint(
        hourStart: 9,
        hourEnd: 18,
        location: LocationsData.cityBcRockefellerCabinet,
        actionLabel: 'У офісі Рокфеллера',
        spritePath: kRockefellerRoomSpritePath,
        days: _weekdays,
      ),
    ],
  );
}
