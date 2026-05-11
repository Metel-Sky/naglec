import 'package:naglec/services/game_world_state.dart';
import 'package:naglec/services/npc_service.dart';
import 'package:naglec/services/game_ui_state_controller.dart';
import 'package:naglec/services/game_navigation_controller.dart';

class RoomAccessManager {
  final NPCService npcService;
  final GameWorldState worldState;
  final GameNavigationController nav;
  final GameUiStateController ui;

  RoomAccessManager(this.npcService, this.worldState, this.nav, this.ui);

  // Implement room access blocks logic if needed here
}
