import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'service_locator.dart';
import '../services/game_time_controller.dart';
import '../services/player_stats_controller.dart';

class SaveService {
  final ScreenshotController screenshotController = ScreenshotController();

  Future<void> saveGame(int slot) async {
    try {
      final directory = await getApplicationDocumentsDirectory();

      // 1. Скріншот (preview_N.png)
      final image = await screenshotController.capture();
      if (image != null) {
        final imagePath = '${directory.path}/preview_$slot.png';
        await File(imagePath).writeAsBytes(image);
      }

      // 2. Збір даних (save_N.json)
      final timeCtrl = sl<GameTimeController>();
      final statsCtrl = sl<PlayerStatsController>();

      final saveData = {
        'slot': slot,
        'save_date': DateTime.now().toIso8601String(),
        'time': timeCtrl.dateTime.toIso8601String(),
        'weekdayIndex': timeCtrl.weekdayIndex,
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
      };

      final jsonPath = '${directory.path}/save_$slot.json';
      await File(jsonPath).writeAsString(jsonEncode(saveData));
      debugPrint("СИСТЕМА: Сейв у слот $slot успішний");
    } catch (e) {
      debugPrint("Помилка збереження: $e");
    }
  }

  Future<void> loadGame(int slot) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/save_$slot.json');

      if (await file.exists()) {
        final data = jsonDecode(await file.readAsString());

        // 1. Час
        final timeCtrl = sl<GameTimeController>();
        timeCtrl.dateTime = DateTime.parse(data['time']);
        if (data.containsKey('weekdayIndex')) {
          timeCtrl.loadManualWeekday(data['weekdayIndex']);
        }

        timeCtrl.updateUI();

        // 2. Стати
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
        debugPrint("СИСТЕМА: Слот $slot завантажено");
      }
    } catch (e) {
      debugPrint("Помилка завантаження: $e");
    }
  }
}