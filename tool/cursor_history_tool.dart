// ignore_for_file: avoid_print
/// Утиліта для перегляду та відновлення версій файлів з локальної історії Cursor (macOS).
///
/// Приклади:
///   dart run tool/cursor_history_tool.dart list lib/screens/main_game/main_game_quest_and_zone.dart
///   dart run tool/cursor_history_tool.dart restore --targets=lib/a.dart,lib/b.dart --before-ms=1776194000000
///   dart run tool/cursor_history_tool.dart restore-dart-range --after-ms=1775980000000 --before-ms=1776194000000
import 'dart:convert' show jsonDecode, utf8;
import 'dart:io';

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    _usage();
    exit(64);
  }
  final cmd = args.first;
  final rest = args.skip(1).toList();
  switch (cmd) {
    case 'list':
      await _cmdList(rest);
    case 'restore':
      await _cmdRestore(rest);
    case 'restore-dart-range':
      await _cmdRestoreDartRange(rest);
    case 'help':
    case '--help':
    case '-h':
      _usage();
      exit(0);
    default:
      stderr.writeln('Невідома команда: $cmd');
      _usage();
      exit(64);
  }
}

void _usage() {
  stdout.writeln('''
cursor_history_tool — історія Cursor на macOS.

Команди:
  list <suffix-шляху>
      Показує до 15 останніх записів з cursor history для файлу, resource закінчується на suffix.

  restore --targets=<через кому>
      Відновлює останню версію кожного з вказаних файлів з history (як було в restore.py).

  restore --targets=... --before-ms=N
      Лише записи з timestamp < N; береться найновіший з них (restore_time.py).

  restore --targets=... --after-ms=A --before-ms=B
      start < ts < end, береться найновіший у діапазоні (для окремих цілей).

  restore-dart-range --after-ms=A --before-ms=B
      Для всіх .dart у проєкті з history у діапазоні часу (restore_all_dart.py).

  Змінні: --project=<корінь> (за замовчуванням поточна тека), --history=<шлях до History>
''');
}

Directory _historyDir(List<String> args) {
  final parsed = _parseFlags(args);
  final custom = parsed['history'];
  if (custom != null) {
    return Directory(custom);
  }
  final home = Platform.environment['HOME'];
  if (home == null) {
    stderr.writeln('HOME не встановлено');
    exit(1);
  }
  return Directory('$home/Library/Application Support/Cursor/User/History');
}

String _projectRoot(List<String> args) {
  final parsed = _parseFlags(args);
  return parsed['project'] ?? Directory.current.path;
}

Map<String, String?> _parseFlags(List<String> args) {
  final out = <String, String?>{};
  for (final a in args) {
    if (a.startsWith('--project=')) {
      out['project'] = a.substring('--project='.length);
    } else if (a.startsWith('--history=')) {
      out['history'] = a.substring('--history='.length);
    } else if (a.startsWith('--targets=')) {
      out['targets'] = a.substring('--targets='.length);
    } else if (a.startsWith('--before-ms=')) {
      out['before-ms'] = a.substring('--before-ms='.length);
    } else if (a.startsWith('--after-ms=')) {
      out['after-ms'] = a.substring('--after-ms='.length);
    }
  }
  return out;
}

Future<void> _cmdList(List<String> args) async {
  final positional = args.where((a) => !a.startsWith('--')).toList();
  if (positional.isEmpty) {
    stderr.writeln('Потрібен шлях: list lib/...');
    exit(64);
  }
  final suffix = positional.first;
  final historyDir = _historyDir(args);
  if (!historyDir.existsSync()) {
    stderr.writeln('Не знайдено: ${historyDir.path}');
    exit(1);
  }
  final found = <({String id, int timestamp, String folderPath})>[];
  await for (final folder in _iterHistoryFolders(historyDir)) {
    final entriesFile = File('${folder.path}/entries.json');
    if (!entriesFile.existsSync()) continue;
    Map<String, dynamic> data;
    try {
      data = jsonDecode(entriesFile.readAsStringSync(encoding: utf8)) as Map<String, dynamic>;
    } catch (_) {
      continue;
    }
    final resource = data['resource'] as String? ?? '';
    if (!resource.endsWith(suffix)) continue;
    final entries = data['entries'] as List<dynamic>? ?? [];
    for (final e in entries) {
      if (e is! Map) continue;
      final m = e.cast<String, dynamic>();
      found.add((
        id: m['id'] as String? ?? '',
        timestamp: (m['timestamp'] as num?)?.toInt() ?? 0,
        folderPath: folder.path,
      ));
    }
  }
  found.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  for (var i = 0; i < found.length && i < 15; i++) {
    final e = found[i];
    final dt = DateTime.fromMillisecondsSinceEpoch(e.timestamp).toIso8601String();
    print('Timestamp: $dt (Unix ${e.timestamp}), ID: ${e.id}, Folder: ${e.folderPath}');
  }
}

Future<void> _cmdRestore(List<String> args) async {
  final flags = _parseFlags(args);
  final targetsRaw = flags['targets'];
  if (targetsRaw == null || targetsRaw.isEmpty) {
    stderr.writeln('Потрібно --targets=path1,path2,...');
    exit(64);
  }
  final targets = targetsRaw.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  final projectDir = _projectRoot(args);
  final beforeMs = int.tryParse(flags['before-ms'] ?? '');
  final afterMs = int.tryParse(flags['after-ms'] ?? '');
  final historyDir = _historyDir(args);

  var restored = 0;
  await for (final folderList in _iterHistoryFolders(historyDir)) {
    final entriesFile = File('${folderList.path}/entries.json');
    if (!entriesFile.existsSync()) continue;
    Map<String, dynamic> data;
    try {
      data = jsonDecode(entriesFile.readAsStringSync(encoding: utf8)) as Map<String, dynamic>;
    } catch (_) {
      continue;
    }
    var res = data['resource'] as String? ?? '';
    if (res.startsWith('file://')) {
      res = res.substring(7);
    }
    for (final t in targets) {
      if (!res.endsWith(t)) continue;
      final entries = data['entries'] as List<dynamic>? ?? [];
      final parsed = <Map<String, dynamic>>[];
      for (final e in entries) {
        if (e is Map) parsed.add(e.cast<String, dynamic>());
      }
      var candidates = parsed;
      if (beforeMs != null) {
        candidates = candidates.where((e) => ((e['timestamp'] as num?)?.toInt() ?? 0) < beforeMs).toList();
      }
      if (afterMs != null) {
        final a = afterMs;
        candidates = candidates
            .where((e) => ((e['timestamp'] as num?)?.toInt() ?? 0) > a)
            .toList();
      }
      if (candidates.isEmpty) continue;
      candidates.sort(
        (a, b) => ((a['timestamp'] as num?)?.toInt() ?? 0).compareTo(
              (b['timestamp'] as num?)?.toInt() ?? 0,
            ),
      );
      final latest = candidates.last;
      final id = latest['id'] as String?;
      if (id == null || id.isEmpty) continue;
      final src = File('${folderList.path}/$id');
      final dst = File('$projectDir/$t');
      if (src.existsSync()) {
        await dst.parent.create(recursive: true);
        await src.copy(dst.path);
        print('Restored $t from ${src.path}');
        restored++;
      }
    }
  }
  print('Total restored: $restored');
}

Future<void> _cmdRestoreDartRange(List<String> args) async {
  final flags = _parseFlags(args);
  final afterMs = int.tryParse(flags['after-ms'] ?? '');
  final beforeMs = int.tryParse(flags['before-ms'] ?? '');
  if (afterMs == null || beforeMs == null) {
    stderr.writeln('Потрібні --after-ms та --before-ms');
    exit(64);
  }
  final projectDir = _projectRoot(args);
  final historyDir = _historyDir(args);
  var restored = 0;
  await for (final folderList in _iterHistoryFolders(historyDir)) {
    final entriesFile = File('${folderList.path}/entries.json');
    if (!entriesFile.existsSync()) continue;
    Map<String, dynamic> data;
    try {
      data = jsonDecode(entriesFile.readAsStringSync(encoding: utf8)) as Map<String, dynamic>;
    } catch (_) {
      continue;
    }
    var res = data['resource'] as String? ?? '';
    if (!res.startsWith('file://') || !res.endsWith('.dart')) continue;
    if (!res.contains(projectDir)) continue;
    var resPath = res.replaceFirst('file://', '');
    if (resPath.startsWith(projectDir)) {
      resPath = resPath.substring(projectDir.length);
      if (resPath.startsWith('/')) {
        resPath = resPath.substring(1);
      }
    } else {
      continue;
    }
    final entries = data['entries'] as List<dynamic>? ?? [];
    final parsed = <Map<String, dynamic>>[];
    for (final e in entries) {
      if (e is Map) parsed.add(e.cast<String, dynamic>());
    }
    final valid = parsed.where((e) {
      final ts = (e['timestamp'] as num?)?.toInt() ?? 0;
      return ts > afterMs && ts < beforeMs;
    }).toList();
    if (valid.isEmpty) continue;
    valid.sort(
      (a, b) => ((a['timestamp'] as num?)?.toInt() ?? 0).compareTo(
            (b['timestamp'] as num?)?.toInt() ?? 0,
          ),
    );
    final latest = valid.last;
    final id = latest['id'] as String?;
    if (id == null || id.isEmpty) continue;
    final src = File('${folderList.path}/$id');
    final dst = File('$projectDir/$resPath');
    if (src.existsSync()) {
      await dst.parent.create(recursive: true);
      await src.copy(dst.path);
      print('Restored $resPath from ${src.path}');
      restored++;
    }
  }
  print('Total dart files restored to range: $restored');
}

Stream<Directory> _iterHistoryFolders(Directory historyDir) async* {
  if (!historyDir.existsSync()) return;
  await for (final entity in historyDir.list(followLinks: false)) {
    if (entity is Directory) yield entity;
  }
}
