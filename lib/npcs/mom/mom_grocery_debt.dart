// ignore_for_file: public_member_api_docs

import '../../data/locations_room_data.dart';
import '../../models/npc_model.dart';
import '../../services/game_world_state.dart';
import '../../services/npc_service.dart';
import 'mom_event002_pool.dart';

/// Доставка кошика їжі з магазину ТРЦ: мама «винна послугу» ([GameWorldState.momOwesGgCount]).
abstract final class MomGroceryDebt {
  MomGroceryDebt._();

  static const String groceryItemId = 'eda';

  /// Вечірній слот на кухні (як у piper_quest_001 кроки 3–4).
  static bool isKitchenEveningHour(int hour) => hour >= 18 && hour <= 21;

  static bool canDeliverGroceriesToMom({
    required NPCService npcService,
    required NPCModel? mom,
    required int hour,
    required int weekdayIndex,
    required String currentZone,
    required bool isInsideRoom,
    required String currentRoom,
    required int groceryItemCount,
  }) {
    if (groceryItemCount <= 0) return false;
    if (currentZone != 'HOME' || !isInsideRoom) return false;
    if (LocationsData.migrateLegacyRoomId(currentRoom) !=
        LocationsData.kitchen) {
      return false;
    }
    if (!isKitchenEveningHour(hour)) return false;
    if (mom == null || mom.id != 'mom') return false;
    return npcService.getCurrentLocationId(mom, hour, weekdayIndex) ==
        LocationsData.kitchen;
  }

  static void applyDelivery({required GameWorldState world}) {
    MomEvent002Pool.applyDebt(world);
  }
}
