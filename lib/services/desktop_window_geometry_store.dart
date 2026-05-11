import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';

/// Збережена геометрія вікна (десктоп): позиція, розмір, максимізація.
@immutable
class DesktopWindowGeometry {
  const DesktopWindowGeometry({
    this.normalRect,
    required this.maximized,
  });

  /// Якщо [maximized] == true, може бути null (відновлюємо лише maximize).
  final Rect? normalRect;
  final bool maximized;
}

/// Читає/пише `window_geometry.json` у [getApplicationSupportDirectory].
class DesktopWindowGeometryStore {
  DesktopWindowGeometryStore._();

  static const String _fileName = 'window_geometry.json';

  static const Size minimumWindowSize = Size(1024, 600);
  static const Size maximumWindowSize = Size(2560, 1440);
  static const Size defaultWindowSize = Size(1280, 820);

  static Future<File> _file() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/$_fileName');
  }

  /// Завантажити збережену геометрію або повернути null.
  static Future<DesktopWindowGeometry?> load() async {
    if (kIsWeb) return null;
    if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) return null;
    try {
      final f = await _file();
      if (!await f.exists()) return null;
      final raw = jsonDecode(await f.readAsString());
      if (raw is! Map<String, dynamic>) return null;
      final maximized = raw['maximized'] == true;
      if (maximized) {
        return const DesktopWindowGeometry(maximized: true);
      }
      final left = (raw['left'] as num?)?.toDouble();
      final top = (raw['top'] as num?)?.toDouble();
      final width = (raw['width'] as num?)?.toDouble();
      final height = (raw['height'] as num?)?.toDouble();
      if (left == null || top == null || width == null || height == null) return null;
      final rect = Rect.fromLTWH(left, top, width, height);
      if (!_isReasonableRect(rect)) return null;
      return DesktopWindowGeometry(normalRect: rect, maximized: false);
    } catch (e) {
      debugPrint('DesktopWindowGeometryStore.load: $e');
      return null;
    }
  }

  /// Записати поточний стан вікна (викликати перед закриттям).
  static Future<void> saveNow() async {
    if (kIsWeb) return;
    if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) return;
    try {
      final maximized = await windowManager.isMaximized();
      final Map<String, dynamic> payload;
      if (maximized) {
        payload = {'maximized': true};
      } else {
        final r = await windowManager.getBounds();
        if (!_isReasonableRect(r)) return;
        payload = {
          'maximized': false,
          'left': r.left,
          'top': r.top,
          'width': r.width,
          'height': r.height,
        };
      }
      final f = await _file();
      await f.parent.create(recursive: true);
      await f.writeAsString(jsonEncode(payload));
    } catch (e) {
      debugPrint('DesktopWindowGeometryStore.saveNow: $e');
    }
  }

  static bool _isReasonableRect(Rect r) {
    if (r.width < minimumWindowSize.width || r.height < minimumWindowSize.height) {
      return false;
    }
    if (r.width > maximumWindowSize.width + 80 || r.height > maximumWindowSize.height + 80) {
      return false;
    }
    return true;
  }
}
