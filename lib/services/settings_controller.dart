import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Гучність музики 0.0..1.0, чити ввімкнено/вимкнено. Зберігається в файл.
class SettingsController with ChangeNotifier {
  double _musicVolume = 0.7;
  bool _cheatsEnabled = false;
  bool _useQuestRuntimeV2 = false;
  bool _questRuntimeMirrorMode = true;

  double get musicVolume => _musicVolume;
  bool get cheatsEnabled => _cheatsEnabled;
  bool get useQuestRuntimeV2 => _useQuestRuntimeV2;
  bool get questRuntimeMirrorMode => _questRuntimeMirrorMode;

  set musicVolume(double v) {
    if (v.clamp(0.0, 1.0) != _musicVolume) {
      _musicVolume = v.clamp(0.0, 1.0);
      _save();
      notifyListeners();
    }
  }

  set cheatsEnabled(bool v) {
    if (v != _cheatsEnabled) {
      _cheatsEnabled = v;
      _save();
      notifyListeners();
    }
  }

  set useQuestRuntimeV2(bool v) {
    if (v != _useQuestRuntimeV2) {
      _useQuestRuntimeV2 = v;
      _save();
      notifyListeners();
    }
  }

  set questRuntimeMirrorMode(bool v) {
    if (v != _questRuntimeMirrorMode) {
      _questRuntimeMirrorMode = v;
      _save();
      notifyListeners();
    }
  }

  static const String _fileName = 'settings.json';

  Future<void> load() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_fileName');
      if (await file.exists()) {
        final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
        if (json['musicVolume'] is num) {
          _musicVolume = (json['musicVolume'] as num).toDouble().clamp(0.0, 1.0);
        }
        if (json['cheatsEnabled'] is bool) {
          _cheatsEnabled = json['cheatsEnabled'] as bool;
        }
        if (json['useQuestRuntimeV2'] is bool) {
          _useQuestRuntimeV2 = json['useQuestRuntimeV2'] as bool;
        }
        if (json['questRuntimeMirrorMode'] is bool) {
          _questRuntimeMirrorMode = json['questRuntimeMirrorMode'] as bool;
        }
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_fileName');
      await file.writeAsString(jsonEncode({
        'musicVolume': _musicVolume,
        'cheatsEnabled': _cheatsEnabled,
        'useQuestRuntimeV2': _useQuestRuntimeV2,
        'questRuntimeMirrorMode': _questRuntimeMirrorMode,
      }));
    } catch (_) {}
  }
}
