import '../data/locations_room_data.dart';
import '../models/npc_model.dart';
import 'game_world_state.dart';

/// Під час cherie_event_004 (кроки 2–8): Чері у спальні Home Cherie; графік ігнорується.
String? cherieMassageFunEventOverrideCherieRoomId(
  NPCModel npc,
  GameWorldState world,
) {
  if (npc.id != 'cherie') return null;
  final s = world.cherieMassageFunEventStep;
  if (s >= 2 && s <= 8) {
    return LocationsData.poorVillageGiftShopOwnerRoom1;
  }
  return null;
}
