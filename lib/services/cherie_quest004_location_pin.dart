import '../data/locations_room_data.dart';
import '../models/npc_model.dart';
import 'game_world_state.dart';

/// Під час cherie_quest_004: Чері в спальні (кроки 3–10) або в залі (крок 11, діалог контракту).
String? cherieQuest004OverrideCherieRoomId(NPCModel npc, GameWorldState world) {
  if (npc.id != 'cherie') return null;
  final s = world.cherieQuest004Step;
  if (s >= 3 && s <= 10) {
    return LocationsData.poorVillageGiftShopOwnerRoom1;
  }
  if (s == 11) {
    return LocationsData.poorVillageGiftShopOwnerHall;
  }
  return null;
}
