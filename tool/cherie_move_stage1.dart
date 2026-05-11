// ignore_for_file: avoid_print
/// Колишній move_cherie_stage1.py / move_cherie_stage1_part2.py (ідентична логіка).
import 'dart:convert';
import 'dart:io';

final _methodStart = RegExp(
  r'^  (?:[a-zA-Z0-9_<>]+ )?([a-zA-Z0-9_]+Cherie[a-zA-Z0-9_]*)\(',
);

void main() => runCherieMoveStage1();

/// Спільна логіка для історичного `move_cherie_stage1_part2.py`.
void runCherieMoveStage1() {
  final root = Directory.current;
  final questPath = File('${root.path}/lib/screens/main_game/main_game_quest_and_zone.dart');
  final flowsPath = File('${root.path}/lib/data/npcs/cherie/cherie_quest_flows.dart');

  final lines = questPath.readAsLinesSync(encoding: utf8);
  final allM = extract(lines);

  _writeStripped(questPath, lines, allM);

  var mixinLines = flowsPath.readAsLinesSync(encoding: utf8);
  final out = <String>[];
  var inserted = false;
  for (final line in mixinLines) {
    if (line.trim() == '}' && !inserted) {
      for (final m in allM) {
        out.add(m.content);
        out.add('');
      }
      inserted = true;
    }
    out.add(line);
  }
  flowsPath.writeAsStringSync(out.join('\n'), encoding: utf8);

  print('Moved ${allM.length} methods to cherie_quest_flows.dart');
  for (final m in allM) {
    print(' - ${m.name}');
  }
}


class _Block {
  _Block({required this.start, required this.end, required this.content, required this.name});
  final int start;
  final int end;
  final String content;
  final String name;
}

List<_Block> extract(List<String> lines) {
  final methods = <_Block>[];
  var inMethod = false;
  var currentMethod = <String>[];
  var braceCount = 0;
  var startLine = -1;

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    if (!inMethod) {
      final mm = _methodStart.firstMatch(line);
      if (mm != null) {
        final mName = mm.group(1)!;
        final ok = mName.contains('001') ||
            mName.contains('002') ||
            mName.contains('003') ||
            (!mName.contains('Quest') && !mName.contains('Massage') && !mName.contains('Animator'));
        if (ok) {
          inMethod = true;
          currentMethod = [line];
          braceCount = '{'.allMatches(line).length - '}'.allMatches(line).length;
          startLine = i;
        }
      }
    } else {
      currentMethod.add(line);
      braceCount += '{'.allMatches(line).length - '}'.allMatches(line).length;
      if (braceCount <= 0 && currentMethod.join().contains('{')) {
        inMethod = false;
        final nameMatch = RegExp(r'([a-zA-Z0-9_]+Cherie[a-zA-Z0-9_]*)\(').firstMatch(currentMethod.first);
        final name = nameMatch?.group(1) ?? '?';
        methods.add(
          _Block(start: startLine, end: i, content: currentMethod.join(), name: name),
        );
      }
    }
  }
  return methods;
}

void _writeStripped(File path, List<String> lines, List<_Block> blocks) {
  final skip = <int>{};
  for (final m in blocks) {
    for (var j = m.start; j <= m.end; j++) {
      skip.add(j);
    }
  }
  final b = StringBuffer();
  for (var j = 0; j < lines.length; j++) {
    if (!skip.contains(j)) b.writeln(lines[j]);
  }
  path.writeAsStringSync(b.toString(), encoding: utf8);
}
