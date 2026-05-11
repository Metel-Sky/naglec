import '../models/npc_model.dart';
import 'game_world_state.dart';

/// Змінні NPC — узгоджено з [CherieQuest002] у `cherie_quests.dart`.
const String _kCherieQuest002CompleteVar = 'cherie_quest_002_complete';
const String _kCherieQuest002MassageLegsDoneVar =
    'cherie_quest_002_massage_legs_done';

/// Кроки 5–9 квесту 2: Cherie має бути в залі дому для [NPCService.getNPCsInRoom]
/// та правої панелі кнопок, навіть коли базовий розклад ставить її в офіс ТРЦ.
bool cherieQuest002PinsNpcToGiftShopOwnerHall(
  NPCModel npc,
  GameWorldState world,
) {
  if (npc.id != 'cherie') return false;
  final s = world.cherieQuest002Step;
  if (s < 5 || s > 9) return false;
  final qComplete = npc.getVar(_kCherieQuest002CompleteVar) == true;
  final legsDone = npc.getVar(_kCherieQuest002MassageLegsDoneVar) == true;
  if (qComplete && legsDone) return false;
  return true;
}
