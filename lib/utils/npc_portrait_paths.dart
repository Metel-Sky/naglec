import '../models/npc_model.dart';
import '../services/npc_service.dart';

void _addUnique(List<String> out, String? s) {
  final t = s?.trim();
  if (t == null || t.isEmpty) return;
  if (out.contains(t)) return;
  out.add(t);
}

void _addScheduleImages(List<String> out, NPCModel npc) {
  for (final p in npc.schedule) {
    final s = p.spritePath.trim();
    if (s.isEmpty) continue;
    final lower = s.toLowerCase();
    if (lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.ava')) {
      _addUnique(out, s);
    }
  }
}

bool _isRasterSpritePath(String path) {
  final lower = path.toLowerCase();
  return lower.endsWith('.png') ||
      lower.endsWith('.jpg') ||
      lower.endsWith('.jpeg') ||
      lower.endsWith('.webp') ||
      lower.endsWith('.gif') ||
      lower.endsWith('.ava');
}

/// Растр із поточної точки розкладу (де NPC зараз за часом/днем), напр. офіціантка в кафе.
/// Якщо зараз відео/порожньо — null.
String? npcSituationalPortraitAssetPath(
  NPCModel npc,
  NPCService npcService,
  int hour,
  int weekday,
) {
  final loc = npcService.getCurrentLocationId(npc, hour, weekday);
  if (loc == null) return null;
  final pt = npcService.representativeSchedulePoint(npc, loc, hour, weekday);
  if (pt == null) return null;
  final sp = pt.spritePath.trim();
  if (sp.isEmpty || !_isRasterSpritePath(sp)) return null;
  return sp;
}

/// Маленький аватар у телефоні / діалозі стата: спочатку ситуаційний растр розкладу, потім [NPCModel.avatarPath].
String? npcPhoneContactPortraitPath(
  NPCModel npc,
  NPCService npcService,
  int hour,
  int weekday,
) {
  final situ = npcSituationalPortraitAssetPath(npc, npcService, hour, weekday);
  if (situ != null) return situ;
  if (npc.avatarPath != null && npc.avatarPath!.isNotEmpty) {
    return npc.avatarPath;
  }
  for (final p in npc.schedule) {
    final s = p.spritePath.trim();
    if (s.endsWith('.jpg') || s.endsWith('.png')) return s;
  }
  return null;
}

/// Кандидати для великого фото в профілі: якщо задано час — спочатку ситуаційний растр, далі [npcGameplayPortraitCandidates].
List<String> npcProfilePortraitCandidatesWithContext(
  NPCModel npc,
  NPCService npcService,
  int hour,
  int weekday,
) {
  final situ = npcSituationalPortraitAssetPath(npc, npcService, hour, weekday);
  final base = npcGameplayPortraitCandidates(npc);
  if (situ == null || situ.isEmpty) return base;
  final out = <String>[situ];
  for (final p in base) {
    if (p != situ) out.add(p);
  }
  return out;
}

/// Сітка галереї «Персонажі»: **спочатку** [NPCModel.galleryPortraitPath], потім аватар і розклад (fallback).
/// Приклад Luda: `luda_ava.jpg` у сітці, якщо файл є; інакше `luda.png`.
List<String> npcGalleryPortraitCandidates(NPCModel npc) {
  final out = <String>[];
  _addUnique(out, npc.galleryPortraitPath);
  _addUnique(out, npc.avatarPath);
  _addScheduleImages(out, npc);
  return out;
}

/// Профіль, телефон, оверлеї в грі: **спочатку** [NPCModel.avatarPath], потім галерея та розклад (fallback).
/// Приклад Luda: скрізь окрім сітки галереї — `luda.png`.
List<String> npcGameplayPortraitCandidates(NPCModel npc) {
  final out = <String>[];
  _addUnique(out, npc.avatarPath);
  _addUnique(out, npc.galleryPortraitPath);
  _addScheduleImages(out, npc);
  return out;
}
