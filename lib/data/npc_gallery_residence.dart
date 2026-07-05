import '../models/npc_model.dart';
import 'locations_room_data.dart';
import 'poor_district/poor_district_house_1.dart';
import 'poor_district/poor_district_house_2.dart';

/// Групи проживання NPC для сортування галереї «Персонажі».
abstract final class NpcGalleryResidence {
  /// Перші картки — родина ГG, далі закріплені (Juniper — 4-та).
  static const galleryHeadIds = ['mom', 'elsa', 'piper', 'juniper'];

  /// Порядок виводу груп після родини.
  static const List<String> _groupOrder = [
    LocationsData.friendHouse,
    LocationsData.auntHouse,
    LocationsData.classmateHouse,
    LocationsData.neighborHouse,
    PoorDistrictHouse1.id,
    PoorDistrictHouse2.id,
    LocationsData.cityEliteResidential,
    LocationsData.poorVillageHouseHeadTeacher,
    LocationsData.poorVillageHouseKaty,
    LocationsData.poorVillageHouseEnglishwoman,
    LocationsData.poorVillageHouseLogisticsBoss,
    LocationsData.poorVillageHouseGiftShopOwner,
    LocationsData.poorVillageHouseCallCenterBoss,
  ];

  static const Map<String, String> _npcToGroup = {
    // Будинок кориша
    'danielle': LocationsData.friendHouse,
    'korish_father': LocationsData.friendHouse,
    'sasha': LocationsData.friendHouse,
    'sem': LocationsData.friendHouse,
    'juniper': LocationsData.friendHouse,
    // Будинок тітки Alexis
    'alexis': LocationsData.auntHouse,
    // Будинок одногрупниць (Lexi)
    'lexi': LocationsData.classmateHouse,
    'alyssa': LocationsData.classmateHouse,
    'candee': LocationsData.classmateHouse,
    // Сусідський будинок
    'jessa': LocationsData.neighborHouse,
    'ariana_marie': LocationsData.neighborHouse,
    // Бідний район, Бандери 1
    'luda': PoorDistrictHouse1.id,
    'flaxy': PoorDistrictHouse1.id,
    // 'katrin': PoorDistrictHouse1.id, // тимчасово не в грі
    'peta': PoorDistrictHouse1.id,
    // Бідний район, Бандери 2
    'kyler': PoorDistrictHouse2.id,
    'foxy': PoorDistrictHouse2.id,
    'nikki': PoorDistrictHouse2.id,
    // Елітний ЖК
    'jennifer': LocationsData.cityEliteResidential,
    'shalina': LocationsData.cityEliteResidential,
    'riley': LocationsData.cityEliteResidential,
    'lana': LocationsData.cityEliteResidential,
    'zazie': LocationsData.cityEliteResidential,
    'geisha': LocationsData.cityEliteResidential,
    // Мажорщина
    'lisa': LocationsData.poorVillageHouseHeadTeacher,
    'nicole': LocationsData.poorVillageHouseHeadTeacher,
    'naomi': LocationsData.poorVillageHouseHeadTeacher,
    'blanche': LocationsData.poorVillageHouseKaty,
    'caprice': LocationsData.poorVillageHouseKaty,
    'amia': LocationsData.poorVillageHouseEnglishwoman,
    'cecilia': LocationsData.poorVillageHouseEnglishwoman,
    'tiffany': LocationsData.poorVillageHouseEnglishwoman,
    'oleksandr': LocationsData.poorVillageHouseLogisticsBoss,
    'hanna': LocationsData.poorVillageHouseLogisticsBoss,
    'den': LocationsData.poorVillageHouseLogisticsBoss,
    'faye_reagan': LocationsData.poorVillageHouseLogisticsBoss,
    'cherie': LocationsData.poorVillageHouseGiftShopOwner,
    'anya': LocationsData.poorVillageHouseGiftShopOwner,
    'adriana': LocationsData.poorVillageHouseGiftShopOwner,
    'artur': LocationsData.poorVillageHouseCallCenterBoss,
    'india_summer': LocationsData.poorVillageHouseCallCenterBoss,
    'samantha': LocationsData.poorVillageHouseCallCenterBoss,
    'emily_willis': LocationsData.poorVillageHouseCallCenterBoss,
  };

  static String groupFor(String npcId) => _npcToGroup[npcId] ?? '';

  static int _groupIndex(String groupId) {
    if (groupId.isEmpty) return _groupOrder.length;
    final idx = _groupOrder.indexOf(groupId);
    return idx >= 0 ? idx : _groupOrder.length;
  }

  /// Родина та закріплені спочатку; решта — за будинком проживання, всередині групи — за віком (від старшого).
  static List<NPCModel> sortForGallery(List<NPCModel> npcs) {
    final byId = <String, NPCModel>{for (final n in npcs) n.id: n};
    final head = <NPCModel>[];
    for (final id in galleryHeadIds) {
      final n = byId[id];
      if (n != null) head.add(n);
    }
    final tail = npcs.where((n) => !galleryHeadIds.contains(n.id)).toList()
      ..sort((a, b) {
        final groupCmp =
            _groupIndex(groupFor(a.id)).compareTo(_groupIndex(groupFor(b.id)));
        if (groupCmp != 0) return groupCmp;
        return b.age.compareTo(a.age);
      });
    return [...head, ...tail];
  }
}
