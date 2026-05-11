import 'npc_model.dart';

/// Три категорії NPC у UI:
/// 1. **Жінки** (за замовчуванням `NpcGender.female`) — повні стати, без окремої мітки.
/// 2. **Чоловіки** (не другорядні) — лише відносини та вплив; мітка «чоловічий персонаж».
/// 3. **Другорядні** (`kSecondaryNpcIds`) — стати не ведуться; не в галереї; мітка «другорядний».
///    Якщо другорядний чоловік — застосовується саме категорія **другорядний**, не чоловічий профіль статів.

/// **Другорядні NPC**:
/// - у UI **немає статів**;
/// - **не показуються** у галереї «Персонажі».
const Set<String> kSecondaryNpcIds = {
  'loshok',
  'dekan',
  'rockefeller',
};

bool isSecondaryNpcId(String id) => kSecondaryNpcIds.contains(id);

bool isSecondaryNpc(NPCModel npc) => isSecondaryNpcId(npc.id);

/// Основні **чоловіки** (не другорядні): у профілі / телефоні лише **відносини** та **вплив ГГ**.
bool isRelationshipInfluenceOnlyNpc(NPCModel npc) =>
    npc.gender == NpcGender.male && !isSecondaryNpc(npc);

/// Контакти для сітки галереї персонажів.
List<NPCModel> npcsExcludingSecondary(Iterable<NPCModel> all) =>
    all.where((n) => !isSecondaryNpc(n)).toList();
