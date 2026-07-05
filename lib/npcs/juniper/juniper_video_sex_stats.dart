import '../../data/npc_sex_stats.dart';
import '../../services/npc_service.dart';
import '../../services/save_service.dart';
import '../../services/service_locator.dart';
import 'juniper_npc.dart';

/// Лічильники «Інтимні походження» Juniper при **запуску** відповідних відео.
abstract final class JuniperVideoSexStats {
  JuniperVideoSexStats._();

  static const Set<String> _minetVideoNames = {
    'junip_sem_room_sex_01.mp4',
    'junip_manuel_01.mp4',
  };

  static const Set<String> _sexVideoNames = {
    'junip_sem_room_sex_02.mp4',
    'junip_sem_room_sex_03.mp4',
    'junip_manuel_02.mp4',
    'junip_manuel_03.mp4',
  };

  static String? _basename(String videoPath) {
    final trimmed = videoPath.trim();
    if (trimmed.isEmpty) return null;
    final parts = trimmed.split('/');
    return parts.isEmpty ? null : parts.last.toLowerCase();
  }

  /// Minet → [NpcSexStats.varSosala]; sex → [NpcSexStats.varSex].
  static void onVideoStarted(String videoPath) {
    final name = _basename(videoPath);
    if (name == null) return;
    final npc = sl<NPCService>().npcById(kJuniperNpcId);
    if (npc == null) return;

    if (_minetVideoNames.contains(name)) {
      NpcSexStats.incrementSosala(npc);
    } else if (_sexVideoNames.contains(name)) {
      NpcSexStats.incrementSex(npc);
    } else {
      return;
    }
    sl<SaveService>().autosave();
  }
}
