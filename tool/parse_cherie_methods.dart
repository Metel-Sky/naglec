// ignore_for_file: avoid_print
/// Колишній parse_cherie.py — друкує діапазони методів Cherie за евристикою.
import 'dart:convert';
import 'dart:io';

final _start = RegExp(
  r'^  (?:[a-zA-Z0-9_<>]+ )?_?(is|abort|apply|check|reset|on|start|present)Cherie[a-zA-Z0-9_]*\(',
);

void main() {
  final path = File('${Directory.current.path}/lib/screens/main_game/main_game_quest_and_zone.dart');
  final lines = path.readAsLinesSync(encoding: utf8);
  final methods = extract(lines);
  for (final m in methods) {
    print('L${m.start + 1}-L${m.end + 1}: ${m.name}');
  }
}

class _M {
  _M({required this.start, required this.end, required this.name});
  final int start;
  final int end;
  final String name;
}

List<_M> extract(List<String> lines) {
  final methods = <_M>[];
  var inMethod = false;
  var currentMethod = <String>[];
  var braceCount = 0;
  var startLine = -1;

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    if (!inMethod) {
      final mm = _start.firstMatch(line);
      if (mm != null) {
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
        final nameMatch = RegExp(r'([a-zA-Z0-9_]+)\(').firstMatch(currentMethod.first);
        final name = nameMatch?.group(1) ?? '?';
        methods.add(_M(start: startLine, end: i, name: name));
      }
    }
  }
  return methods;
}
