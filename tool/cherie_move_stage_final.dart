// ignore_for_file: avoid_print
/// Колишній move_cherie_stage_final.py
import 'dart:convert';
import 'dart:io';

final _cherieName = RegExp(r'\b([a-zA-Z0-9_]*Cherie[a-zA-Z0-9_]*)\(');

void main() {
  final root = Directory.current;
  final questPath = File('${root.path}/lib/screens/main_game/main_game_quest_and_zone.dart');
  final gameFlowPath = File('${root.path}/lib/npcs/cherie/cherie_game_flow.dart');

  final lines = questPath.readAsLinesSync(encoding: utf8);
  final allM = extract(lines);

  _writeStripped(questPath, lines, allM);

  var mixinLines = gameFlowPath.readAsLinesSync(encoding: utf8);
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
  gameFlowPath.writeAsStringSync(out.join('\n'), encoding: utf8);

  print('Moved ${allM.length} remaining methods to cherie_game_flow.dart');
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
    final m = _cherieName.firstMatch(line);
    if (!inMethod &&
        m != null &&
        line.trim().endsWith('{') &&
        !line.trim().startsWith('if') &&
        !line.trim().startsWith('else') &&
        !line.trim().startsWith('for') &&
        !line.trim().startsWith('while')) {
      inMethod = true;
      currentMethod = [line];
      braceCount = '{'.allMatches(line).length - '}'.allMatches(line).length;
      startLine = i;
    } else if (inMethod) {
      currentMethod.add(line);
      braceCount += '{'.allMatches(line).length - '}'.allMatches(line).length;
      if (braceCount <= 0 && currentMethod.join().contains('{')) {
        inMethod = false;
        final nameMatch = RegExp(r'([a-zA-Z0-9_]*Cherie[a-zA-Z0-9_]*)\(').firstMatch(currentMethod.first);
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
