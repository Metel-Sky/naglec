// ignore_for_file: avoid_print
/// Колишній fix_methods2.py
import 'dart:convert';
import 'dart:io';

void main() {
  final root = Directory.current;
  final questPath = File('${root.path}/lib/screens/main_game/main_game_quest_and_zone.dart');
  final flowsPath = File('${root.path}/lib/data/npcs/cherie/cherie_quest_flows.dart');

  var lines = questPath.readAsLinesSync(encoding: utf8);

  List<_Block> extract(List<String> src, List<String> names) {
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
          if ((line.contains('$n(') || line.contains('$n (')) &&
              line.contains('{') &&
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

  const names = [
    '_buildGiftShopAnimatorFinishButton',
    '_buildGiftShopAnimatorWorkButton',
    '_healCherieAnimatorIntroIfStuckAfterShifts',
    '_cherieQuest002StartPlayerGates',
    '_randomMassageFunTips50to150',
  ];

  final allM = extract(lines, names);
  _stripAndRewrite(questPath, lines, allM);

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
}

class _Block {
  _Block({required this.start, required this.end, required this.content});
  final int start;
  final int end;
  final String content;
}

void _stripAndRewrite(File path, List<String> lines, List<_Block> blocks) {
  final skip = <int>{};
  for (final m in blocks) {
    for (var i = m.start; i <= m.end; i++) skip.add(i);
  }
  final b = StringBuffer();
  for (var i = 0; i < lines.length; i++) {
    if (!skip.contains(i)) b.writeln(lines[i]);
  }
  path.writeAsStringSync(b.toString(), encoding: utf8);
}
