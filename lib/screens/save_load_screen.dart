import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../services/service_locator.dart';
import '../services/save_service.dart';
import '../theme/game_theme.dart';

class SaveLoadScreen extends StatefulWidget {
  final bool isLoadingMode; // true - завантажити, false - зберегти

  const SaveLoadScreen({super.key, required this.isLoadingMode});

  @override
  State<SaveLoadScreen> createState() => _SaveLoadScreenState();
}

class _SaveLoadScreenState extends State<SaveLoadScreen> {
  String? _appPath;

  @override
  void initState() {
    super.initState();
    _initPath();
  }

  Future<void> _initPath() async {
    final dir = await getApplicationDocumentsDirectory();
    setState(() => _appPath = dir.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameTheme.bgDark,
      appBar: AppBar(
        title: Text(widget.isLoadingMode ? "ЗАВАНТАЖЕННЯ" : "ЗБЕРЕЖЕННЯ"),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
            childAspectRatio: 1.2,
          ),
          itemCount: 9,
          itemBuilder: (context, index) {
            int slot = index + 1;
            String previewPath = "$_appPath/preview_$slot.png";
            bool fileExists = _appPath != null && File(previewPath).existsSync();

            return GestureDetector(
              onTap: () async {
                if (widget.isLoadingMode) {
                  // 1. Завантажуємо дані
                  await sl<SaveService>().loadGame(slot);

                  // 2. Закриваємо ВСІ меню (і SaveLoad, і Settings), повертаючись до MainGameScreen
                  if (context.mounted) {
                    // popUntil видаляє екрани з верхівки стека, поки не знайде перший (гру)
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                } else {
                  // Код для збереження...
                  await sl<SaveService>().saveGame(slot);
                  setState(() {});
                }
              },
              child: Container(
                decoration: GameTheme.cardDecoration(radius: 12),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Скріншот або заглушка
                    fileExists
                        ? Image.file(File(previewPath), fit: BoxFit.cover, key: ValueKey(DateTime.now()))
                        : Container(color: Colors.black45, child: const Icon(Icons.add, color: Colors.white24)),

                    // Номер слота
                    Positioned(
                      top: 5, left: 5,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        color: Colors.black54,
                        child: Text("SLOT $slot", style: const TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}