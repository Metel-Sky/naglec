import '../models/npc_model.dart';
import '../npcs/juniper/juniper_npc.dart';
import '../npcs/sem/sem_quests.dart';
import '../services/game_world_state.dart';
import '../services/npc_finance_service.dart';

/// Спільні правила відображення картки NPC (профіль, телефон).
abstract final class NpcProfileDisplay {
  NpcProfileDisplay._();

  static String roleLabel(NPCModel npc, {GameWorldState? world}) =>
      profileStatus(npc, world: world);

  /// Статус/роль на картці; для Juniper залежить від прогресу арки Sem.
  static String profileStatus(NPCModel npc, {GameWorldState? world}) {
    if (npc.id == kJuniperNpcId) {
      return SemQuest001.juniperProfileStatus(world: world);
    }
    return npc.status ?? npc.name;
  }

  /// Великий заголовок картки: «Cory Mother age: 37».
  static String cardTitleLine(NPCModel npc, {GameWorldState? world}) {
    final name = npc.name.trim();
    final status = profileStatus(npc, world: world).trim();
    if (status.isNotEmpty) {
      return '$name $status age: ${npc.age}';
    }
    return '$name age: ${npc.age}';
  }

  static String ageValue(NPCModel npc) => '${npc.age}';

  /// Абзац «Зовнішність» — без префікса «Body» / «Зовнішність:».
  static String? appearanceParagraph(NPCModel npc) {
    final fromBio = npc.biographyAppearance?.trim();
    if (fromBio != null && fromBio.isNotEmpty) return fromBio;
    final body = npc.bodyDescription?.trim();
    if (body == null || body.isEmpty) return null;
    return body
        .replaceFirst(RegExp(r'^Зовнішність:\s*', caseSensitive: false), '')
        .replaceFirst(RegExp(r'^≡\s*Body:\s*', caseSensitive: false), '')
        .trim();
  }

  static int owesAlexMoney(GameWorldState? world, String npcId) {
    if (world == null) return 0;
    return NpcFinanceService.npcOwesGg(world, npcId);
  }

  static int owesAlexService(GameWorldState? world, NPCModel npc) {
    if (world == null) return 0;
    if (npc.id == 'mom') return world.momOwesGgCount;
    final v = npc.variables['npc_owes_gg_service'];
    if (v is int) return v < 0 ? 0 : v;
    if (v is num) return v.toInt().clamp(0, 999999);
    return 0;
  }
}
