import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'service_locator.dart';
import 'game_time_controller.dart';
import 'player_stats_controller.dart';
import 'npc_service.dart';

class SaveService {
  final ScreenshotController screenshotController = ScreenshotController();

  // 1. ГОЛОВНА ФУНКЦІЯ: ЗБЕРЕЖЕННЯ
  Future<void> saveGame(int slotNumber) async {
    final directory = await getApplicationDocumentsDirectory();

    // Збираємо дані з усіх усюд
    final saveData = {
      'time': sl<GameTimeController>().dateTime.toIso8601String(),
      'stats': {
        'relationship': sl<NPCService>().allNPCs.map((n) => {n.id: n.relationship}).toList(),
        // Додай сюди PlayerStats, коли покажеш їх
      },
      'location': {
        'currentRoom': "Отримай це з MainGameScreen",
      },
    };

    // Записуємо JSON
    final file = File('${directory.path}/save_$slotNumber.json');
    await file.writeAsString(jsonEncode(saveData));

    // Робимо скріншот для прев'ю
    await screenshotController.captureAndSave(
      directory.path,
      fileName: "preview_$slotNumber.png",
    );
  }

  // 2. ФУНКЦІЯ ЗАВАНТАЖЕННЯ
  Future<void> loadGame(int slotNumber) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/save_$slotNumber.json');

    if (await file.exists()) {
      final data = jsonDecode(await file.readAsString());

      // Розпихуємо дані назад по контролерах
      sl<GameTimeController>().dateTime = DateTime.parse(data['time']);
      // ... оновлюємо все інше
    }
  }
}