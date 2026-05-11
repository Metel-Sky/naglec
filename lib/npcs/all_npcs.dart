import '../models/npc_model.dart';
import 'mom/mom_npc.dart';
import 'elsa/elsa_npc.dart';
import 'piper/piper_npc.dart';
import 'luda/luda_npc.dart';
import 'den/den_npc.dart';
import 'loshok/loshok_npc.dart';
import 'nicole/nicole_npc.dart';
import 'amia/amia_npc.dart';
import 'lisa/lisa_npc.dart';
import 'dekan/dekan_npc.dart';
import 'rockefeller/rockefeller_npc.dart';
import 'danielle/danielle_npc.dart';
import 'korish_father/korish_father_npc.dart';
import 'sasha/sasha_npc.dart';
import 'sem/sem_npc.dart';
import 'cherie/cherie_npc.dart';
import 'anya/anya_npc.dart';
import 'faye/faye_npc.dart';
import 'emily/emily_npc.dart';
import 'ariana/ariana_npc.dart';
import 'india/india_npc.dart';
import 'jessa/jessa_npc.dart';

/// Збирає список усіх NPC з їхніх файлів.
List<NPCModel> createAllNpcs() {
  return [
    createMomNpc(),
    createElsaNpc(),
    createPiperNpc(),
    createLudaNpc(),
    createDenNpc(),
    createFayeNpc(),
    createEmilyNpc(),
    createArianaNpc(),
    createIndiaNpc(),
    createJessaNpc(),
    createLoshokNpc(),
    createNicoleNpc(),
    createAmiaNpc(),
    createLisaNpc(),
    createDekanNpc(),
    createRockefellerNpc(),
    createDanielleNpc(),
    createKorishFatherNpc(),
    createSashaNpc(),
    createSemNpc(),
    createCherieNpc(),
    createAnyaNpc(),
  ];
}
