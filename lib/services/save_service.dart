import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'service_locator.dart';
import '../services/game_time_controller.dart';
import '../services/player_stats_controller.dart';
import '../services/game_world_state.dart';
import '../services/game_navigation_controller.dart';
import '../services/npc_service.dart';
import '../services/inventory_controller.dart';
import '../npcs/den/den_events.dart';
import '../data/npc_economy_config.dart';
import '../models/npc_model.dart';
import '../models/npc_secondary.dart';
import '../models/item_model.dart';

/// Ручні слоти сітки 3×3 (верхній лівий … передостанній рядок).
const int kManualSaveSlotMin = 0;
const int kManualSaveSlotMax = 7;

/// Нижній правий кут — лише автосейв, гравець не записує сюди.
const int kAutosaveSlot = 8;

/// Flutter кешує [FileImage] за шляхом — після зміни файлу на диску треба скинути кеш, інакше в UI лишається старий скрін.
void evictSavePreviewImageCache(String absolutePath) {
  PaintingBinding.instance.imageCache.evict(FileImage(File(absolutePath)));
}

class SaveService {
  final ScreenshotController screenshotController = ScreenshotController();

  /// Знімок для прев’ю слота, зроблений **до** відкриття екрана збережень, поки гра ще видима.
  /// Інакше [ScreenshotController.capture] під меню часто повертає null.
  Uint8List? _manualSaveMenuPreview;

  /// Викликати з гри перед `Navigator.push(SaveLoadScreen)` (після згортання панелей).
  Future<void> capturePreviewForSaveMenu() async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      _manualSaveMenuPreview = await screenshotController.capture();
      if (_manualSaveMenuPreview == null) {
        debugPrint('СИСТЕМА: прев’ю для меню збережень недоступне (capture null)');
      }
    } catch (e, st) {
      _manualSaveMenuPreview = null;
      debugPrint('СИСТЕМА: capturePreviewForSaveMenu: $e');
      debugPrint('$st');
    }
  }

  /// Якщо є лише старий `save_0.json`, копіює в `save_8.json` (одноразова міграція).
  static Future<void> ensureLegacyAutosaveMigrated() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final newJson = File('${directory.path}/save_$kAutosaveSlot.json');
      if (await newJson.exists()) return;
      final oldJson = File('${directory.path}/save_0.json');
      if (!await oldJson.exists()) return;
      await oldJson.copy(newJson.path);
      final oldP = File('${directory.path}/preview_0.png');
      final newP = File('${directory.path}/preview_$kAutosaveSlot.png');
      if (await oldP.exists()) {
        await oldP.copy(newP.path);
      }
      debugPrint('СИСТЕМА: міграція автосейву save_0 → save_$kAutosaveSlot');
    } catch (e) {
      debugPrint('ensureLegacyAutosaveMigrated: $e');
    }
  }

  /// Перевіряє наявність автосейву (`save_8.json`, після міграції з слоту 0).
  static Future<bool> hasAutosave() async {
    try {
      await ensureLegacyAutosaveMigrated();
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/save_$kAutosaveSlot.json');
      return await file.exists();
    } catch (_) {
      return false;
    }
  }

  /// Завантаження останнього автосейву (слот 8).
  Future<void> loadAutosave() async {
    await ensureLegacyAutosaveMigrated();
    await loadGame(kAutosaveSlot);
  }

  /// Ручне збереження лише в слоти 0–7.
  Future<void> saveGame(int slot) async {
    if (slot < kManualSaveSlotMin || slot > kManualSaveSlotMax) {
      debugPrint('СИСТЕМА: saveGame($slot) ігноровано — використовуйте autosave() для слоту $kAutosaveSlot');
      return;
    }
    await _writeSaveSlot(slot);
  }

  /// Меню «Зберегти»: повністю прибрати старі `save_*.json` і `preview_*.png` слота, потім новий скрін і новий сейв.
  Future<void> saveGameReplacingManualSlot(int slot) async {
    if (slot < kManualSaveSlotMin || slot > kManualSaveSlotMax) {
      debugPrint('СИСТЕМА: saveGameReplacingManualSlot($slot) ігноровано');
      return;
    }
    final directory = await getApplicationDocumentsDirectory();
    final jsonFile = File('${directory.path}/save_$slot.json');
    final previewFile = File('${directory.path}/preview_$slot.png');
    if (await jsonFile.exists()) {
      await jsonFile.delete();
      debugPrint('СИСТЕМА: видалено старий сейв: ${jsonFile.path}');
    }
    if (await previewFile.exists()) {
      evictSavePreviewImageCache(previewFile.path);
      await previewFile.delete();
      debugPrint('СИСТЕМА: видалено старий прев’ю: ${previewFile.path}');
    } else {
      evictSavePreviewImageCache(previewFile.path);
    }
    await _writeSaveSlot(slot);
  }

  /// Програмний автосейв (нижній правий слот).
  Future<void> autosave() async {
    await _writeSaveSlot(kAutosaveSlot);
  }

  Future<void> _writeSaveSlot(int slot) async {
    final directory = await getApplicationDocumentsDirectory();
    debugPrint('СИСТЕМА: Початок збереження в слот $slot');

    // Прев’ю: для ручних слотів спочатку буфер із [capturePreviewForSaveMenu] (гра видима),
    // бо під відкритим меню збережень [capture] зазвичай дає null.
    try {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      final isManualSlot = slot >= kManualSaveSlotMin && slot <= kManualSaveSlotMax;
      Uint8List? image;
      if (isManualSlot && _manualSaveMenuPreview != null) {
        image = _manualSaveMenuPreview;
        _manualSaveMenuPreview = null;
        debugPrint('СИСТЕМА: прев’ю слота $slot з буфера (знято до меню збережень)');
      } else {
        image = await screenshotController.capture();
      }
      if (image != null) {
        final imagePath = '${directory.path}/preview_$slot.png';
        final imgFile = File(imagePath);
        if (await imgFile.exists()) {
          evictSavePreviewImageCache(imagePath);
          await imgFile.delete();
        }
        await File(imagePath).writeAsBytes(image);
        evictSavePreviewImageCache(imagePath);
        debugPrint('СИСТЕМА: Скріншот збережено: $imagePath');
      } else {
        debugPrint(
          'СИСТЕМА: скріншот недоступний (null) — зберігаємо слот без прев’ю, гра не втрачається',
        );
      }
    } catch (e, st) {
      debugPrint('СИСТЕМА: скріншот пропущено ($e) — продовжуємо збереження стану гри');
      debugPrint('$st');
    }

    try {
      final timeCtrl = sl<GameTimeController>();
      final statsCtrl = sl<PlayerStatsController>();
      final worldState = sl<GameWorldState>();
      final nav = sl<GameNavigationController>();
      final npcService = sl<NPCService>();
      final inventory = sl<InventoryController>();

      // Під час гри фактична локація ГГ живе в навігаційному контролері.
      // Перед збереженням синхронізуємо worldState, щоб в JSON потрапила
      // саме поточна позиція героя, а не застаріле значення.
      worldState.currentZone = nav.currentZone;
      worldState.currentRoom = nav.currentRoom;
      worldState.isInsideRoom = nav.isInsideRoom;
      worldState.currentStreetHouse = nav.currentStreetHouse;

      final saveData = {
        'slot': slot,
        'save_date': DateTime.now().toIso8601String(),

        'time': timeCtrl.dateTime.toIso8601String(),
        'weekdayIndex': timeCtrl.weekdayIndex,

        'world': worldState.toJson(),

        'stats': {
          'money': statsCtrl.player.money,
          'energy': statsCtrl.player.energy,
          'arousal': statsCtrl.player.arousal,
          'lust': statsCtrl.player.lust,
          'charisma': statsCtrl.player.charisma,
          'physical_fitness': statsCtrl.player.physical_fitness,
          'fighting': statsCtrl.player.fighting,
          'massage_experience': statsCtrl.player.massage_experience,
          'lockpicking': statsCtrl.player.lockpicking,
          'programming': statsCtrl.player.programming,
          'hacking': statsCtrl.player.hacking,
          'stealth_mode': statsCtrl.player.stealth_mode,
          'college_success': statsCtrl.player.college_success,
          'programming_lessons_completed': statsCtrl.programmingLessonsCompleted,
          'programming_last_watched_date': statsCtrl.programmingLastWatchedDate?.toIso8601String(),
          'lockpick_lessons_completed': statsCtrl.lockpickLessonsCompleted,
          'lockpick_last_watched_date': statsCtrl.lockpickLastWatchedDate?.toIso8601String(),
          'stealth_lessons_completed': statsCtrl.stealthLessonsCompleted,
          'stealth_last_watched_date': statsCtrl.stealthLastWatchedDate?.toIso8601String(),
          'password_lessons_completed': statsCtrl.passwordLessonsCompleted,
          'password_last_watched_date': statsCtrl.passwordLastWatchedDate?.toIso8601String(),
          'phone_lessons_completed': statsCtrl.phoneLessonsCompleted,
          'phone_last_watched_date': statsCtrl.phoneLastWatchedDate?.toIso8601String(),
          'massage_lessons_completed': statsCtrl.massageLessonsCompleted,
          'massage_last_watched_date': statsCtrl.massageLastWatchedDate?.toIso8601String(),
          'ero_massage_last_watched_date': statsCtrl.eroMassageLastWatchedDate?.toIso8601String(),
        },

        'npcs': npcService.allNPCs
            .map((npc) => {
                  'id': npc.id,
                  'fullName': npc.fullName,
                  'age': npc.age,
                  'trust': npc.trust,
                  'love': npc.love,
                  'corruption': npc.corruption,
                  'lust': npc.lust,
                  'behavior': npc.behavior,
                  'arousal': npc.arousal,
                  'money': npc.money,
                  'influence': npc.influence,
                  'items': npc.items
                      .map((it) => {
                            'id': it.id,
                            'name': it.name,
                            'imagePath': it.imagePath,
                            'expiresAtIso': it.expiresAtIso,
                          })
                      .toList(),
                  'variables': npc.variables,
                })
            .toList(),

        'inventory': inventory.items
            .map((it) => {
                  'id': it.id,
                  'name': it.name,
                  'description': it.description,
                  'imagePath': it.imagePath,
                })
            .toList(),
      };

      final jsonPath = '${directory.path}/save_$slot.json';
      await File(jsonPath).writeAsString(jsonEncode(saveData));
      debugPrint('СИСТЕМА: Сейв у слот $slot успішний');
      debugPrint('СИСТЕМА: Шлях до файлу: $jsonPath');
      final stats = saveData['stats'] as Map<String, dynamic>?;
      final world = saveData['world'] as Map<String, dynamic>?;
      debugPrint(
        'СИСТЕМА: Збережено гроші: ${stats?['money']}, час: ${saveData['time']}, локація: ${world?['currentRoom']}',
      );
    } catch (e, st) {
      debugPrint('Помилка збереження JSON: $e');
      debugPrint('$st');
    }
  }

  Future<void> loadGame(int slot) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/save_$slot.json');
      debugPrint("СИСТЕМА: Початок завантаження зі слота $slot");
      debugPrint("СИСТЕМА: Шлях до файлу: ${file.path}");

      if (await file.exists()) {
        final data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
        final stats = data['stats'] as Map<String, dynamic>?;
        final world = data['world'] as Map<String, dynamic>?;
        debugPrint("СИСТЕМА: Файл знайдено, slot у файлі: ${data['slot']}, гроші: ${stats?['money']}, час: ${data['time']}, локація: ${world?['currentRoom']}");

        final timeCtrl = sl<GameTimeController>();
        timeCtrl.dateTime = DateTime.parse(data['time']);
        if (data.containsKey('weekdayIndex')) {
          timeCtrl.loadManualWeekday(data['weekdayIndex']);
        }
        timeCtrl.updateUI();

        if (data['world'] != null) {
          final world = sl<GameWorldState>();
          world.loadFromJson(Map<String, dynamic>.from(data['world']));
          sl<GameNavigationController>().syncFromWorldState();
        }

        if (data['stats'] != null) {
          final s = data['stats'];
          final p = sl<PlayerStatsController>();

          p.player.money = s['money'] ?? 0;
          p.player.energy = (s['energy'] ?? 100).toDouble();
          p.player.arousal = (s['arousal'] ?? 0).toDouble();
          p.player.lust = s['lust'] ?? 0;
          p.player.charisma = s['charisma'] ?? 0;
          p.player.physical_fitness =
              ((s['physical_fitness'] as num?)?.toInt() ?? 0).clamp(0, p.maxPhysical_fitness);
          p.player.fighting = s['fighting'] ?? 0;
          p.player.massage_experience = s['massage_experience'] ?? 0;
          p.player.lockpicking =
              ((s['lockpicking'] as num?)?.toInt() ?? 0).clamp(0, 100);
          p.player.programming = s['programming'] ?? 0;
          p.player.hacking = s['hacking'] ?? 0;
          p.player.stealth_mode = s['stealth_mode'] ?? 0;
          p.player.college_success = s['college_success'] ?? 0;

          p.player.syncMaxEnergyWithStrength();

          p.programmingLessonsCompleted = s['programming_lessons_completed'] ?? 0;
          final lastWatched = s['programming_last_watched_date'];
          p.programmingLastWatchedDate =
              lastWatched != null ? DateTime.tryParse(lastWatched as String) : null;
          p.lockpickLessonsCompleted = s['lockpick_lessons_completed'] ?? 0;
          final lockpickWatched = s['lockpick_last_watched_date'];
          p.lockpickLastWatchedDate =
              lockpickWatched != null ? DateTime.tryParse(lockpickWatched as String) : null;
          p.stealthLessonsCompleted = s['stealth_lessons_completed'] ?? 0;
          final stealthWatched = s['stealth_last_watched_date'];
          p.stealthLastWatchedDate =
              stealthWatched != null ? DateTime.tryParse(stealthWatched as String) : null;
          p.passwordLessonsCompleted = s['password_lessons_completed'] ?? 0;
          final passwordWatched = s['password_last_watched_date'];
          p.passwordLastWatchedDate =
              passwordWatched != null ? DateTime.tryParse(passwordWatched as String) : null;
          p.phoneLessonsCompleted = s['phone_lessons_completed'] ?? 0;
          final phoneWatched = s['phone_last_watched_date'];
          p.phoneLastWatchedDate =
              phoneWatched != null ? DateTime.tryParse(phoneWatched as String) : null;
          p.massageLessonsCompleted = s['massage_lessons_completed'] ?? 0;
          final massageWatched = s['massage_last_watched_date'];
          p.massageLastWatchedDate =
              massageWatched != null ? DateTime.tryParse(massageWatched as String) : null;
          final eroWatched = s['ero_massage_last_watched_date'];
          p.eroMassageLastWatchedDate =
              eroWatched != null ? DateTime.tryParse(eroWatched as String) : null;

          p.updateUI();
        }

        if (data['npcs'] != null) {
          final npcService = sl<NPCService>();
          final List<dynamic> npcList = data['npcs'];

          for (final raw in npcList) {
            final Map<String, dynamic> npcData =
                Map<String, dynamic>.from(raw as Map);
            final id = npcData['id'];
            final npc = npcService.allNPCs.firstWhere(
              (n) => n.id == id,
              orElse: () => npcService.allNPCs.first,
            );

            npc.fullName = npcData['fullName'] ?? npc.fullName;
            npc.age = npcData['age'] ?? npc.age;
            final t = npcData['trust'];
            final l = npcData['love'];
            npc.trust = (t != null ? (t is int ? t.toDouble() : (t as num).toDouble()) : npc.trust);
            npc.love = (l != null ? (l is int ? l.toDouble() : (l as num).toDouble()) : npc.love);
            npc.corruption = npcData['corruption'] ?? npc.corruption;
            final lustVal = npcData['lust'];
            npc.lust = (lustVal != null ? (lustVal is int ? lustVal.toDouble() : (lustVal as num).toDouble()) : npc.lust);
            final b = npcData['behavior'];
            npc.behavior = (b != null ? (b is int ? b.toDouble() : (b as num).toDouble()) : npc.behavior);
            npc.arousal = npcData['arousal'] ?? npc.arousal;
            final moneyVal = npcData['money'];
            final loadedMoney = moneyVal != null
                ? (moneyVal is int ? moneyVal : (moneyVal as num).toInt())
                : npc.money;
            if (isSecondaryNpcId(npc.id)) {
              npc.money = 0;
            } else {
              npc.money = loadedMoney.clamp(
                NpcEconomyConfig.moneyMin,
                NpcEconomyConfig.moneyMax,
              );
            }
            final inf = npcData['influence'];
            npc.influence = (inf != null ? (inf is int ? inf.toDouble() : (inf as num).toDouble()) : npc.influence);
            if (npcData['items'] != null) {
              final rawItems = List<dynamic>.from(npcData['items'] as List);
              npc.items = rawItems
                  .map((rawItem) {
                    final item = Map<String, dynamic>.from(rawItem as Map);
                    final id = item['id'] as String?;
                    final name = item['name'] as String?;
                    if (id == null || id.isEmpty || name == null || name.isEmpty) {
                      return null;
                    }
                    return NpcOwnedItem(
                      id: id,
                      name: name,
                      imagePath: item['imagePath'] as String?,
                      expiresAtIso: item['expiresAtIso'] as String?,
                    );
                  })
                  .whereType<NpcOwnedItem>()
                  .toList();
            }
            if (npcData['variables'] != null) {
              npc.variables = Map<String, dynamic>.from(npcData['variables'] as Map);
            }
            if (id == 'den') {
              syncDenHooliganQuestFlagFromProgress(npc);
            }
          }
        }

        final inv = sl<InventoryController>();
        if (data['inventory'] is List) {
          inv.items.clear();
          final rawList = List<dynamic>.from(data['inventory'] as List);
          for (final raw in rawList) {
            final m = Map<String, dynamic>.from(raw as Map);
            final itemId = m['id'] as String?;
            final itemName = m['name'] as String?;
            final desc = m['description'] as String? ?? '';
            if (itemId == null || itemId.isEmpty || itemName == null) continue;
            inv.addItem(GameItem(
              id: itemId,
              name: itemName,
              description: desc,
              imagePath: m['imagePath'] as String?,
            ));
          }
        } else {
          inv.reset();
        }

        debugPrint("СИСТЕМА: Слот $slot завантажено");
        final loadedStats = data['stats'] as Map<String, dynamic>?;
        final loadedWorld = data['world'] as Map<String, dynamic>?;
        debugPrint("СИСТЕМА: Завантажено гроші: ${loadedStats?['money']}, час: ${data['time']}, локація: ${loadedWorld?['currentRoom']}");
      }
    } catch (e) {
      debugPrint("Помилка завантаження: $e");
    }
  }
}
