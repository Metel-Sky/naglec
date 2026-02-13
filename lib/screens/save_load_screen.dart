import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../services/service_locator.dart';
import '../services/save_service.dart';
import '../theme/game_theme.dart';

class SaveLoadScreen extends StatefulWidget {
  const SaveLoadScreen({super.key});

  @override
  State<SaveLoadScreen> createState() => _SaveLoadScreenState();
}

class _SaveLoadScreenState extends State<SaveLoadScreen> {
  int currentPage = 1;
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
      backgroundColor: GameTheme.screenBg,
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            _buildSidebar(),
            const SizedBox(width: 15),
            Expanded(child: _buildMainContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      decoration: BoxDecoration(color:  GameTheme.bgDark, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          const Spacer(),
          _sideBtn("Почати заново", () {}),
          _sideBtn("Зберегти", () {}),
          _sideBtn("Завантажити", () {}),
          _sideBtn("Налаштування", () {}),
          _sideBtn("Головне меню", () => Navigator.pop(context)),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _sideBtn(String text, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),



      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: GameTheme.mainGrey,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            minimumSize: const Size(double.infinity, 50)),
        onPressed: onTap, child: Text(text),
      ),
    );
  }



  Widget _buildMainContent() {
    return Column(
      children: [
        Expanded(
          flex: 8,
          child: Container(
            decoration: BoxDecoration(color: GameTheme.bgDark, borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 10),
                Expanded(child: _buildGrid()),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
        Expanded(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(color: GameTheme.bgDark, borderRadius: BorderRadius.circular(12)),
            child: const Center(child: Text("РЕКЛАМА", style: TextStyle(color: GameTheme.mainGrey))),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    bool hasAuto = _appPath != null && File('$_appPath/save_0.json').existsSync();
    return Row(
      children: [
        // КНОПКА НАЗАД
        Material(
          color: Colors.transparent, // Робимо фон прозорим
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(50), // Тепер це працює тут
            child: const SizedBox(
              width: 34,
              height: 34,
              child: Center(
                child: Icon(Icons.arrow_back, color: GameTheme.mainGrey, size: 22),
              ),
            ),
          ),
        ),

        const SizedBox(width: 40), // ВІДСТАНЬ 40 PX

        // КНОПКА AUTO
        GestureDetector(
          onTap: () async {
            if (hasAuto) {
              await sl<SaveService>().loadGame(0);
              if (mounted) Navigator.pop(context, true);
            }
          },
          child: Text(
            "AUTO",
            style: TextStyle(
              color: hasAuto ? Colors.white : GameTheme.mainGrey,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),

        const Spacer(),

        // ПАГІНАЦІЯ
        const Text("Page: ", style: TextStyle(color: GameTheme.mainGrey)),
        for (int i = 1; i <= 3; i++)
          GestureDetector(
            onTap: () => setState(() => currentPage = i),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                "$i",
                style: TextStyle(
                  color: currentPage == i ? GameTheme.mainGrey : Colors.white24,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),

        const Spacer(),

        const Text(
          "ЗБЕРЕЖЕННЯ",
          style: TextStyle(color: GameTheme.mainGrey, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double spacing = 10.0;
        double cellWidth = (constraints.maxWidth - (spacing * 2)) / 3;
        double cellHeight = (constraints.maxHeight - (spacing * 2)) / 3;

        return GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          childAspectRatio: cellWidth / cellHeight,
          children: List.generate(9, (index) {
            int id = (currentPage - 1) * 9 + index + 1;
            String imgPath = "$_appPath/preview_$id.png";
            bool exists = _appPath != null && File('$_appPath/save_$id.json').existsSync();

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                print("DEBUG: Натиснуто на слот $id, exists: $exists");
                if (exists) {
                  // Завантажуємо гру зі слоту
                  print("DEBUG: Завантаження гри зі слоту $id");
                  await sl<SaveService>().loadGame(id);
                  if (mounted) {
                    // Закриваємо екран і повертаємо true, щоб оновити гру
                    print("DEBUG: Закриття екрану після завантаження");
                    Navigator.pop(context, true);
                  }
                } else {
                  // Зберігаємо гру в порожній слот
                  print("DEBUG: Збереження гри в слот $id");
                  await sl<SaveService>().saveGame(id);
                  if (mounted) {
                    // Оновлюємо UI, щоб показати новий скріншот
                    print("DEBUG: Оновлення UI після збереження");
                    setState(() {});
                  }
                }
              },
              child: Container(
                decoration: BoxDecoration(color: const Color(0xFFC4C4C4), borderRadius: BorderRadius.circular(10)),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    if (exists && _appPath != null) Image.file(File(imgPath), fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                    if (!exists) const Center(child: Icon(Icons.add, color: Colors.black12, size: 40)),
                    if (exists)
                      Positioned(
                        bottom: 5, right: 5,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            // Видаляємо збереження
                            File('$_appPath/save_$id.json').deleteSync();
                            File(imgPath).deleteSync();
                            setState(() {});
                          },
                          child: const CircleAvatar(radius: 12, backgroundColor: Colors.black54, child: Icon(Icons.delete, size: 14, color: Colors.white)),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }
}