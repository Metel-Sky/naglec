// ignore_for_file: avoid_print
/// Одноразова міграція: переносить методи між dart-файлами (колишній fix_methods.py).
/// Запуск лише з кореня проєкту, якщо потрібно повторити історичний рефакторинг.
import 'dart:convert';
import 'dart:io';

void main() {
  final root = Directory.current;
  final questPath = File('${root.path}/lib/screens/main_game/main_game_quest_and_zone.dart');
  final cherieFlowPath = File('${root.path}/lib/npcs/cherie/cherie_game_flow.dart');
  final basePath = File('${root.path}/lib/screens/main_game/main_game_screen_state_base.dart');

  var lines = questPath.readAsLinesSync(encoding: utf8);

  List<_Block> extractByNames(List<String> src, List<String> names) {
    final methods = <_Block>[];
    var inMethod = false;
    var currentMethod = <String>[];
    var braceCount = 0;
    var startLine = -1;

    for (var i = 0; i < src.length; i++) {
      final line = src[i];
      if (!inMethod) {
        var matched = false;
        for (final n in names) {
          if (line.contains(n) &&
              line.trim().endsWith('{') &&
              !line.trim().startsWith('if') &&
              !line.trim().startsWith('else') &&
              !line.trim().startsWith('return')) {
            matched = true;
            break;
          }
        }
        if (matched) {
          inMethod = true;
          currentMethod = [line];
          braceCount = '{'.allMatches(line).length - '}'.allMatches(line).length;
          startLine = i;
        }
      } else {
        currentMethod.add(line);
        braceCount += '{'.allMatches(line).length - '}'.allMatches(line).length;
        if (braceCount <= 0 && currentMethod.join().contains('{')) {
          inMethod = false;
          methods.add(_Block(start: startLine, end: i, content: currentMethod.join()));
        }
      }
    }
    return methods;
  }

  const missingCherie = [
    '_buildGiftShopAnimatorFinishButton',
    '_buildGiftShopAnimatorWorkButton',
    '_cherieMassageFunEventDebugHeader',
    '_cherieQuest002StartPlayerGates',
    '_cherieQuest004DebugDialogHeader',
    '_cherieQuest005DebugDialogHeader',
    '_cherieQuest006DebugDialogHeader',
    '_healCherieAnimatorIntroIfStuckAfterShifts',
    '_randomMassageFunTips50to150',
    '_teleportCherieQuest005ToBedroom',
    '_teleportCherieQuest005ToPoorVillageOverview',
  ];

  var allM = extractByNames(lines, missingCherie);
  _writeWithoutLines(questPath, lines, allM);

  _insertBeforeLastClose(cherieFlowPath, allM.map((m) => m.content).toList());

  lines = questPath.readAsLinesSync(encoding: utf8);

  List<_Block> extractNav(List<String> src) {
    final methods = <_Block>[];
    var inMethod = false;
    var currentMethod = <String>[];
    var braceCount = 0;
    var startLine = -1;

    for (var i = 0; i < src.length; i++) {
      final line = src[i];
      if (!inMethod) {
        if (line.contains(' Widget _navBtn(') &&
            line.contains('{') &&
            !line.trim().startsWith('if') &&
            !line.trim().startsWith('else') &&
            !line.trim().startsWith('return')) {
          inMethod = true;
          currentMethod = [line];
          braceCount = '{'.allMatches(line).length - '}'.allMatches(line).length;
          startLine = i;
        }
      } else {
        currentMethod.add(line);
        braceCount += '{'.allMatches(line).length - '}'.allMatches(line).length;
        if (braceCount <= 0 && currentMethod.join().contains('{')) {
          inMethod = false;
          methods.add(_Block(start: startLine, end: i, content: currentMethod.join()));
        }
      }
    }
    return methods;
  }

  final allNav = extractNav(lines);
  _writeWithoutLines(questPath, lines, allNav);

  _appendBeforeOuterClose(basePath, allNav.map((m) => m.content).toList(), '  String t(String key) => sl<LocaleController>().t(key);\n\n');

  print('Moved ${allM.length} methods to cherie_game_flow.dart');
  print('Moved ${allNav.length} nav methods to main_game_screen_state_base.dart');
}

class _Block {
  _Block({required this.start, required this.end, required this.content});
  final int start;
  final int end;
  final String content;
}

void _writeWithoutLines(File path, List<String> lines, List<_Block> blocks) {
  final skip = <int>{};
  for (final m in blocks) {
    for (var i = m.start; i <= m.end; i++) {
      skip.add(i);
    }
  }
  final buf = StringBuffer();
  for (var i = 0; i < lines.length; i++) {
    if (!skip.contains(i)) buf.writeln(lines[i]);
  }
  path.writeAsStringSync(buf.toString(), encoding: utf8);
}

void _insertBeforeLastClose(File path, List<String> methodContents) {
  final mixinLines = path.readAsLinesSync(encoding: utf8);
  final out = <String>[];
  var inserted = false;
  for (final line in mixinLines) {
    if (line.trim() == '}' && !inserted) {
      for (final c in methodContents) {
        out.add(c);
        out.add('');
      }
      inserted = true;
    }
    out.add(line);
  }
  path.writeAsStringSync(out.join('\n'), encoding: utf8);
}

void _appendBeforeOuterClose(File path, List<String> methodContents, String trailing) {
  var baseLines = path.readAsLinesSync(encoding: utf8);
  while (baseLines.isNotEmpty && baseLines.last.trim() != '}') {
    baseLines.removeLast();
  }
  if (baseLines.isEmpty) {
    stderr.writeln('Unexpected empty ${path.path}');
    exit(1);
  }
  baseLines.removeLast();
  final buf = StringBuffer();
  for (final line in baseLines) {
    buf.writeln(line);
  }
  for (final c in methodContents) {
    buf.writeln();
    buf.write(c);
    buf.writeln();
  }
  buf.write(trailing);
  buf.writeln('}');
  path.writeAsStringSync(buf.toString(), encoding: utf8);
}
