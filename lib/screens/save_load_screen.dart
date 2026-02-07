import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../services/service_locator.dart';
import '../services/save_service.dart';
import '../theme/game_theme.dart';

class SaveLoadScreen extends StatefulWidget {
  final bool isLoadingMode;

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

  Future<void> _deleteSave(int slot) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: GameTheme.bgDark,
        title: const Text("ВИДАЛИТИ?", style: TextStyle(color: Colors.white)),
        content: Text("Ви впевнені, що хочете видалити слот $slot?", style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("СКАСУВАТИ")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("ВИДАЛИТИ", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final dir = await getApplicationDocumentsDirectory();
      final jsonFile = File('${dir.path}/save_$slot.json');
      final imgFile = File('${dir.path}/preview_$slot.png');

      if (await jsonFile.exists()) await jsonFile.delete();
      if (await imgFile.exists()) await imgFile.delete();

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameTheme.bgDark,
      appBar: AppBar(
        title: Text(widget.isLoadingMode ? "ЗАВАНТАЖЕННЯ" : "ЗБЕРЕЖЕННЯ"),
        backgroundColor: Colors.transparent,
        elevation: 0,
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

            return Stack(
              children: [
                // ОСНОВНА КНОПКА СЛОТА
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () async {
                      if (widget.isLoadingMode) {
                        if (!fileExists) return;
                        await sl<SaveService>().loadGame(slot);
                        if (context.mounted) Navigator.pop(context, true);
                      } else {
                        // Збереження
                        await sl<SaveService>().saveGame(slot);
                        // Маленька затримка, щоб файл встиг записатися перед оновленням UI
                        await Future.delayed(const Duration(milliseconds: 100));
                        setState(() {});
                      }
                    },
                    child: Container(
                      decoration: GameTheme.cardDecoration(radius: 12),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          fileExists
                              ? Image.file(
                            File(previewPath),
                            fit: BoxFit.cover,
                            // Ключ змушує Flutter перемалювати картинку, якщо вона змінилася
                            key: ValueKey('slot_${slot}_${DateTime.now().millisecondsSinceEpoch}'),
                          )
                              : Container(
                            color: Colors.black45,
                            child: const Icon(Icons.add, color: Colors.white24, size: 40),
                          ),

                          // Номер слота
                          Positioned(
                            top: 8, left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text("SLOT $slot", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // КНОПКА ВИДАЛЕННЯ (поверх всього)
                if (fileExists)
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: GestureDetector(
                      onTap: () => _deleteSave(slot),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                        ),
                        child: const Icon(
                          Icons.delete_forever,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}