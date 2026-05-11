import 'package:flutter/material.dart';

class GameTheme {
  // --- ТВОЇ КОНСТАНТИ (КОЛЬОРИ) ---
  static const Color mainGrey = Color(0xFFD6D6D6);    // Сірий для кнопок
  static const Color bgDark = Color(0xFF3B4856);      // Темно-синій фон панелей
  static const Color screenBg = Color(0xFF9AA7AD);    // Фон усього екрану
  static const Color textGreen = Color(0xFF2E7D32);   // Зелений текст
  static const Color textBlack = Colors.black87;      // Чорний текст

  /// Додаткова ширина кнопки відносно напису: ~30 px сума (15 з кожного боку).
  static const double actionButtonHorizontalInset = 15;

  // --- СТИЛЬ КНОПОК ---
  static ButtonStyle actionButtonStyle({Color color = Colors.black87}) {
    return ElevatedButton.styleFrom(
      backgroundColor: mainGrey,
      foregroundColor: color,
      elevation: 0,
      padding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: actionButtonHorizontalInset,
      ),
      textStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 12,
        letterSpacing: 0.4,
      ),
      alignment: Alignment.center,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  // --- ДЕКОРАЦІЯ ПАНЕЛЕЙ ---
  static BoxDecoration panelDecoration = BoxDecoration(
    color: bgDark.withValues(alpha: 0.9), // Використовуємо bgDark замість невідомого cardBg
    borderRadius: BorderRadius.circular(15),
    border: Border.all(color: Colors.white10),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.3),
        blurRadius: 10,
        offset: const Offset(0, 9),
      ),
    ],
  );

  // --- ОФОРМЛЕННЯ КАРТОК ---
  static BoxDecoration cardDecoration({double radius = 12}) {
    return BoxDecoration(
      color: mainGrey,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.black12),
    );
  }
}
