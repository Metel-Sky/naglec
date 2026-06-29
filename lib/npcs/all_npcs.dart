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
import 'samantha/samantha_npc.dart';
import 'shalina/shalina_npc.dart';
import 'sem/sem_npc.dart';
import 'juniper/juniper_npc.dart';
import 'cherie/cherie_npc.dart';
import 'anya/anya_npc.dart';
import 'faye/faye_npc.dart';
import 'hanna/hanna_npc.dart';
import 'oleksandr/oleksandr_npc.dart';
import 'emily/emily_npc.dart';
import 'ariana/ariana_npc.dart';
import 'india/india_npc.dart';
import 'artur/artur_npc.dart';
import 'jessa/jessa_npc.dart';
import 'adriana/adriana_npc.dart';
import 'alexis/alexis_npc.dart';
import 'lexi/lexi_npc.dart';
import 'flaxy/flaxy_npc.dart';
import 'alyssa/alyssa_npc.dart';
import 'candee/candee_npc.dart';
import 'blanche/blanche_npc.dart';
import 'zazie/zazie_npc.dart';
import 'geisha/geisha_npc.dart';
import 'foxy/foxy_npc.dart';
import 'katrin/katrin_npc.dart';
import 'caprice/caprice_npc.dart';
import 'peta/peta_npc.dart';
import 'jennifer/jennifer_npc.dart';
import 'kyler/kyler_npc.dart';
import 'riley/riley_npc.dart';
import 'lana/lana_npc.dart';
import 'naomi/naomi_npc.dart';
import 'cecilia/cecilia_npc.dart';
import 'tiffany/tiffany_npc.dart';
import 'nikki/nikki_npc.dart';

/// Збирає список усіх NPC з їхніх файлів.
List<NPCModel> createAllNpcs() {
  return [
    createMomNpc(),
    createElsaNpc(),
    createPiperNpc(),
    createLudaNpc(),
    createDenNpc(),
    createFayeNpc(),
    createHannaNpc(),
    createOleksandrNpc(),
    createEmilyNpc(),
    createArianaNpc(),
    createIndiaNpc(),
    createArturNpc(),
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
    createSamanthaNpc(),
    createShalinaNpc(),
    createSemNpc(),
    createJuniperNpc(),
    createCherieNpc(),
    createAnyaNpc(),
    createAdrianaNpc(),
    createAlexisNpc(),
    createLexiNpc(),
    createFlaxyNpc(),
    createAlyssaNpc(),
    createCandeeNpc(),
    createBlancheNpc(),
    createZazieNpc(),
    createGeishaNpc(),
    createFoxyNpc(),
    createKatrinNpc(),
    createCapriceNpc(),
    createPetaNpc(),
    createJenniferNpc(),
    createKylerNpc(),
    createRileyNpc(),
    createLanaNpc(),
    createNaomiNpc(),
    createCeciliaNpc(),
    createTiffanyNpc(),
    createNikkiNpc(),
  ];
}
