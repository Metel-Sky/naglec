import '../../models/npc_model.dart';
import '../../data/locations_room_data.dart';

const String kHannaGalleryPortraitPath = 'lib/assets/npcs/hanna/hanna.png';
const String kHannaAvatarPath = 'lib/assets/npcs/hanna/hanna_ava.png';

/// Hanna — дружина начальника логістичної компанії, 39 років.
/// Живе в будинку чоловіка (Мажорщина), спальня. Не працює; займається розвитком особистості.
NPCModel createHannaNpc() {
  return NPCModel(
    id: 'hanna',
    gender: NpcGender.female,
    name: 'Hanna',
    fullName: 'Hanna',
    status: 'Дружина начальника логістичної компанії',
    biographyType:
        'Дружина начальника логістичної компанії. Ніде не працює, живе за рахунок чоловіка і цілими днями займається розвитком особистості. Має дуже багато знайомих і зв\'язків.',
    age: 39,
    galleryPortraitPath: kHannaGalleryPortraitPath,
    avatarPath: kHannaAvatarPath,
    schedule: [
      SchedulePoint(
        hourStart: 0,
        hourEnd: 23,
        location: LocationsData.poorVillageLogisticsBossRoom1,
        actionLabel: 'Вдома (спальня)',
        spritePath: kHannaAvatarPath,
      ),
    ],
  );
}
