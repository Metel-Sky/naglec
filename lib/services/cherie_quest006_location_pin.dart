import '../data/locations_room_data.dart';
import '../models/npc_model.dart';
import 'game_world_state.dart';

/// Під час cherie_quest_006 (кроки 1–4): Чері в офісі ТРЦ; графік ігнорується.
String? cherieQuest006OverrideCherieRoomId(NPCModel npc, GameWorldState world) {
  if (npc.id != 'cherie') return null;
  final s = world.cherieQuest006Step;
  if (s >= 1 && s <= 4) {
    return LocationsData.cityMallGiftShopOffice;
  }
  return null;
}
