import '../data/locations_room_data.dart';
import '../models/npc_model.dart';
import '../npcs/mom/mom_quest001.dart';
import 'game_world_state.dart';

/// Після згоди на квест: суб/нд 12–14 мама в залі дому ГГ (замість попередніх слотів на вихідних).
String? momQuest001OverrideMomHall(
  NPCModel npc,
  GameWorldState world,
  int weekdayIndex,
  int hour,
) {
  if (npc.id != 'mom') return null;
  if (!MomQuest001.shouldPinMomToHallWeekends(world)) return null;
  if (!MomQuest001.isWeekend(weekdayIndex)) return null;
  if (!MomQuest001.isHallWeekendWindow(hour)) return null;
  return LocationsData.hall;
}
