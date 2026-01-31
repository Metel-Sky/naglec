import 'package:flutter/material.dart';

class GameTheme {
  // ТВОЇ КОНСТАНТИ (ЗМІННІ)
  static const Color mainGrey = Color(0xFFD6D6D6);    // Твій основний сірий для кнопок і блоків
  static const Color bgDark = Color(0xFF3B4856);      // Темно-синій фон панелей
  static const Color screenBg = Color(0xFF9AA7AD);    // Фон усього екрану
  static const Color textGreen = Color(0xFF2E7D32);   // Зелений для цифр і стану
  static const Color textBlack = Colors.black;        // Чорний текст
  static const Color textWhite = Colors.white;        // Білий текст
  //static const Color 


  // Швидкий доступ до оформлення карток
  static BoxDecoration cardDecoration({double radius = 12}) {
    return BoxDecoration(
      color: mainGrey, // Використовуємо нашу змінну
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(40),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}