import '../models/npc_model.dart';

/// Лічильники інтимних подій у картці NPC (розділ «Інтимні походження»).
abstract final class NpcSexStats {
  static const String varDrochila = 'npc_sex_drochila';
  static const String varSosala = 'npc_sex_sosala';
  static const String varSex = 'npc_sex_sex';
  static const String varAnal = 'npc_sex_anal';
  static const String varLesbo = 'npc_sex_lesbo';
  static const String varGrupovushka = 'npc_sex_grupovushka';

  static const List<String> orderedVarKeys = [
    varDrochila,
    varSosala,
    varSex,
    varAnal,
    varLesbo,
    varGrupovushka,
  ];

  static const Map<String, String> labelL10nKeys = {
    varDrochila: 'profile_npc_sex_drochila',
    varSosala: 'profile_npc_sex_sosala',
    varSex: 'profile_npc_sex_sex',
    varAnal: 'profile_npc_sex_anal',
    varLesbo: 'profile_npc_sex_lesbo',
    varGrupovushka: 'profile_npc_sex_grupovushka',
  };

  static int read(NPCModel npc, String varKey) {
    final v = npc.variables[varKey];
    if (v is int) return v < 0 ? 0 : v;
    if (v is num) return v.toInt().clamp(0, 999999);
    return 0;
  }

  static void setCount(NPCModel npc, String varKey, int value) {
    npc.setVar(varKey, value.clamp(0, 999999));
  }

  static void increment(NPCModel npc, String varKey, [int delta = 1]) {
    if (delta <= 0) return;
    setCount(npc, varKey, read(npc, varKey) + delta);
  }

  static void incrementSosala(NPCModel? npc, {int delta = 1}) {
    if (npc == null) return;
    increment(npc, varSosala, delta);
  }

  static void incrementSex(NPCModel? npc, {int delta = 1}) {
    if (npc == null) return;
    increment(npc, varSex, delta);
  }
}
