/// Точка входу та головне меню гри "Наглец".
/// Містить ініціалізацію Flutter, MediaKit, Service Locator та налаштування вікна на десктопі.

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Потрібно для kIsWeb
import 'package:media_kit/media_kit.dart';
import 'package:naglec/theme/game_theme.dart';
import 'package:naglec/widgets/news_panel.dart';
import 'dart:io'; // Потрібно для Platform
import 'package:window_manager/window_manager.dart';
import 'screens/main_game_screen.dart';
import 'services/service_locator.dart';

/// Точка входу в додаток. Ініціалізує біндінги, медіа, сервіси та опційно вікно на десктопі.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized(); // обов'язково для відтворення відео/аудіо

  setupServiceLocator();

  // На десктопі (macOS/Windows/Linux) налаштовуємо розмір і відображення вікна
  if (!kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
    await windowManager.ensureInitialized();

    const WindowOptions windowOptions = WindowOptions(
      size: Size(1280, 820),
      minimumSize: Size(1024, 800),
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

/// Кореневий віджет додатку — MaterialApp з темною темою та головним екраном меню.
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

/// Головний екран меню: ліва панель з кнопками, центральна картка з артом, панель новин знизу.
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
            minHeight: 900,
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
                      minWidth: 250,
                      maxWidth: 300,
                    ),
                    child: const LeftMenuPanel(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        Expanded(flex: 3, child: MainArtCard()),
                        const SizedBox(height: 12),
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

/// Ліва панель меню: кнопки дій та ряд іконок соцмереж/підтримки.
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

  /// Повертає кнопку меню з єдиним стилем. "Почати гру" відкриває [MainGameScreen].
  Widget _buildMenuButton(BuildContext context, String text) {
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
                MaterialPageRoute(builder: (context) => const MainGameScreen()),
              );
            }
          },
          child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        ),
      ),
    );
  }
}

/// Центральна картка на головному екрані — показує фонове зображення з assets.
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


