import 'package:flutter/material.dart';
import '../theme/game_theme.dart';
import 'save_load_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameTheme.bgDark.withOpacity(0.95),
      body: Center(
        child: Container(
          width: 400, // Фіксована ширина для гарного вигляду на планшетах/ПК
          padding: const EdgeInsets.all(24),
          decoration: GameTheme.panelDecoration,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "НАЛАШТУВАННЯ",
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              _menuBtn(context, "ЗБЕРЕГТИ ГРУ", () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const SaveLoadScreen(isLoadingMode: false),
                ));
              }),

              _menuBtn(context, "ЗАВАНТАЖИТИ ГРУ", () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const SaveLoadScreen(isLoadingMode: true),
                ));
              }),

              _menuBtn(context, "ГОЛОВНЕ МЕНЮ", () {
                // Тут логіка виходу в старт-скрін
                Navigator.popUntil(context, (route) => route.isFirst);
              }),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("ПОВЕРНУТИСЯ ДО ГРИ", style: TextStyle(color: Colors.white54)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuBtn(BuildContext context, String text, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: GameTheme.actionButtonStyle(color: Colors.black87),
          onPressed: onTap,
          child: Text(text),
        ),
      ),
    );
  }
}