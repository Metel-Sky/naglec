import '../data/locations_room_data.dart';
import '../models/npc_model.dart';
import 'game_world_state.dart';

/// Під час cherie_quest_005 (кроки 2–13): Чері у спальні Cherie; графік ігнорується.
String? cherieQuest005OverrideCherieRoomId(NPCModel npc, GameWorldState world) {
  if (npc.id != 'cherie') return null;
  final s = world.cherieQuest005Step;
  if (s >= 2 && s <= 13) {
    return LocationsData.poorVillageGiftShopOwnerRoom1;
  }
  return null;
}
