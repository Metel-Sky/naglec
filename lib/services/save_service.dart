import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'service_locator.dart';
import '../services/game_time_controller.dart';
import '../services/player_stats_controller.dart';
import '../services/game_world_state.dart';
import '../services/npc_service.dart';

class SaveService {
  final ScreenshotController screenshotController = ScreenshotController();

  Future<void> saveGame(int slot) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      debugPrint("СИСТЕМА: Початок збереження в слот $slot");

      // 1. Скріншот (preview_N.png)
      final image = await screenshotController.capture();
      if (image != null) {
        final imagePath = '${directory.path}/preview_$slot.png';
        // Перед записом завжди видаляємо старий прев'ю-файл,
        // щоб точно не підхоплювався застарілий скрін.
        final imgFile = File(imagePath);
        if (await imgFile.exists()) {
          await imgFile.delete();
        }
        await File(imagePath).writeAsBytes(image);
        debugPrint("СИСТЕМА: Скріншот збережено: $imagePath");
      } else {
        debugPrint("СИСТЕМА: ПОМИЛКА: Скріншот не зроблено!");
      }

      // 2. Збір даних (save_N.json)
      final timeCtrl = sl<GameTimeController>();
      final statsCtrl = sl<PlayerStatsController>();
      final worldState = sl<GameWorldState>();
      final npcService = sl<NPCService>();

      final saveData = {
        'slot': slot,
        'save_date': DateTime.now().toIso8601String(),

        // ЧАС / ДЕНЬ / ДЕНЬ ТИЖНЯ
        'time': timeCtrl.dateTime.toIso8601String(),
        'weekdayIndex': timeCtrl.weekdayIndex,

        // ЛОКАЦІЯ ГГ
        'world': worldState.toJson(),

        // СТАТИ ГГ
        'stats': {
          'money': statsCtrl.player.money,
          'energy': statsCtrl.player.energy,
          'arousal': statsCtrl.player.arousal,
          'lust': statsCtrl.player.lust,
          'vitality': statsCtrl.player.vitality,
          'physical_fitness': statsCtrl.player.physical_fitness,
          'fighting': statsCtrl.player.fighting,
          'massage_experience': statsCtrl.player.massage_experience,
          'lockpicking': statsCtrl.player.lockpicking,
          'programming': statsCtrl.player.programming,
          'hacking': statsCtrl.player.hacking,
          'stealth_mode': statsCtrl.player.stealth_mode,
          'influence': statsCtrl.player.influence,
          'college_success': statsCtrl.player.college_success,
        },

        // СТАТИ УСІХ NPC
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
                  'variables': npc.variables,
                })
            .toList(),

        // TODO: тут можна буде додати "events", коли зʼявиться система івентів
      };

      final jsonPath = '${directory.path}/save_$slot.json';
      await File(jsonPath).writeAsString(jsonEncode(saveData));
      debugPrint("СИСТЕМА: Сейв у слот $slot успішний");
      debugPrint("СИСТЕМА: Шлях до файлу: $jsonPath");
      final stats = saveData['stats'] as Map<String, dynamic>?;
      final world = saveData['world'] as Map<String, dynamic>?;
      debugPrint("СИСТЕМА: Збережено гроші: ${stats?['money']}, час: ${saveData['time']}, локація: ${world?['currentRoom']}");
    } catch (e) {
      debugPrint("Помилка збереження: $e");
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

        // 1. Час
        final timeCtrl = sl<GameTimeController>();
        timeCtrl.dateTime = DateTime.parse(data['time']);
        if (data.containsKey('weekdayIndex')) {
          timeCtrl.loadManualWeekday(data['weekdayIndex']);
        }
        timeCtrl.updateUI();

        // 2. Локація ГГ
        if (data['world'] != null) {
          final world = sl<GameWorldState>();
          world.loadFromJson(Map<String, dynamic>.from(data['world']));
        }

        // 3. Стати ГГ
        if (data['stats'] != null) {
          final s = data['stats'];
          final p = sl<PlayerStatsController>();

          p.player.money = s['money'] ?? 0;
          p.player.energy = (s['energy'] ?? 100).toDouble();
          p.player.arousal = (s['arousal'] ?? 0).toDouble();
          p.player.lust = s['lust'] ?? 0;
          p.player.vitality = s['vitality'] ?? 100;
          p.player.physical_fitness = s['physical_fitness'] ?? 0;
          p.player.fighting = s['fighting'] ?? 0;
          p.player.massage_experience = s['massage_experience'] ?? 0;
          p.player.lockpicking = s['lockpicking'] ?? 0;
          p.player.programming = s['programming'] ?? 0;
          p.player.hacking = s['hacking'] ?? 0;
          p.player.stealth_mode = s['stealth_mode'] ?? 0;
          p.player.influence = s['influence'] ?? 0;
          p.player.college_success = s['college_success'] ?? 0;

          p.updateUI();
        }

        // 4. Стати NPC
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
            npc.trust = npcData['trust'] ?? npc.trust;
            npc.love = npcData['love'] ?? npc.love;
            npc.corruption = npcData['corruption'] ?? npc.corruption;
            npc.lust = npcData['lust'] ?? npc.lust;
            npc.behavior = npcData['behavior'] ?? npc.behavior;
            npc.arousal = npcData['arousal'] ?? npc.arousal;
            if (npcData['variables'] != null) {
              npc.variables = Map<String, dynamic>.from(npcData['variables'] as Map);
            }
          }
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