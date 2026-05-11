import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../l10n/strings_uk.dart';
import '../l10n/strings_en.dart';
import '../l10n/strings_ru.dart';

/// Код мови: 'uk' | 'en' | 'ru'
const String localeUk = 'uk';
const String localeEn = 'en';
const String localeRu = 'ru';

/// У діалозі налаштувань показуємо лише ці дві мови (RU лишається в сейві для старих профілів).
const List<MapEntry<String, String>> supportedLocales = [
  MapEntry(localeUk, 'Українська'),
  MapEntry(localeEn, 'English'),
];

/// Контролер мови: зберігає вибір, повертає рядок за ключем для поточної мови.
class LocaleController with ChangeNotifier {
  String _locale = localeUk;
  String get locale => _locale;

  /// Flutter Locale для MaterialApp (uk, en, ru).
  Locale get flutterLocale {
    if (_locale == localeEn) return const Locale('en');
    if (_locale == localeRu) return const Locale('ru');
    return const Locale('uk');
  }

  Map<String, String> get _strings {
    switch (_locale) {
      case localeEn:
        return stringsEn;
      case localeRu:
        return stringsRu;
      default:
        return stringsUk;
    }
  }

  /// Повертає рядок для поточної мови за ключем. Якщо ключа немає — повертає сам ключ.
  String t(String key) => _strings[key] ?? key;

  void setLocale(String code) {
    if (code != _locale && (code == localeUk || code == localeEn || code == localeRu)) {
      _locale = code;
      _saveLocale();
      notifyListeners();
    }
  }

  static const String _fileName = 'locale.json';

  Future<void> loadLocale() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_fileName');
      if (await file.exists()) {
        final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
        final code = json['locale'] as String?;
        if (code != null && (code == localeUk || code == localeEn || code == localeRu)) {
          _locale = code;
          notifyListeners();
        }
      }
    } catch (_) {}
  }

  Future<void> _saveLocale() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_fileName');
      await file.writeAsString(jsonEncode({'locale': _locale}));
    } catch (_) {}
  }
}
