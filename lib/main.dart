import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Потрібно для kIsWeb
import 'package:naglec/theme/game_theme.dart';
import 'dart:io'; // Потрібно для Platform
import 'package:window_manager/window_manager.dart'; // Імпортуємо пакет
import 'locations/home_corridor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Перевіряємо: якщо це НЕ браузер і це десктопна ОС
  if (!kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(1280, 720),
      minimumSize: Size(1024, 600),
      maximumSize: Size(2560, 1440),
      center: true,
      title: "Наглец",
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(const NaglecGame());
}

class NaglecGame extends StatelessWidget {
  const NaglecGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const MainMenuScreen(),
    );
  }
}

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameTheme.screenBg,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 1024,
            minHeight: 600,
            maxWidth: 2560,
            maxHeight: 1440,
          ),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 250, // Не менше 250
                      maxWidth: 280, // ширина лівої панелі Не більше 350
                    ),
                    child: const LeftMenuPanel(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: const [
                        Expanded(flex: 3, child: MainArtCard()),
                        SizedBox(height: 12),
                        Expanded(flex: 1, child: NewsPanel()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LeftMenuPanel extends StatelessWidget {
  const LeftMenuPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GameTheme.bgDark,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      child: Column(
        children: [
          const Spacer(),
          _buildMenuButton(context, "Почати гру"),
          _buildMenuButton(context, "Продовжити"),
          _buildMenuButton(context, "Завантажити гру"),
          _buildMenuButton(context, "Налаштунки"),
          _buildMenuButton(context, "Галерея"),
          _buildMenuButton(context, "Допомогти проекту"),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              Icon(Icons.monetization_on, size: 40),
              Icon(Icons.telegram, size: 40),
              Icon(Icons.camera_alt, size: 40),
              Icon(Icons.facebook, size: 40),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context,String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        height: 45,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withAlpha(230),
            foregroundColor: Colors.black,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            if (text == "Почати гру") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeCorridor()),
              );
            }
          },
          child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        ),
      ),
    );
  }
}

class MainArtCard extends StatelessWidget {
  const MainArtCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GameTheme.bgDark,
        borderRadius: BorderRadius.circular(15),
        image: const DecorationImage(
          image: AssetImage('lib/assets/home_gg.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class NewsPanel extends StatelessWidget {
  final String customMessage;

  const NewsPanel({
    super.key,
    this.customMessage = "Ласкаво просимо до гри 'Наглец'...",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: GameTheme.bgDark,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        customMessage,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    ); // Останній крапка з комою методу build
  }
}