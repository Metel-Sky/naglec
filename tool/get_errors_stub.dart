// ignore_for_file: avoid_print
/// Колишній get_errors.py — заготовка; для аналізу використовуйте `dart analyze` / IDE.
import 'dart:convert';
import 'dart:io';

void main() {
  final f = File('${Directory.current.path}/lib/npcs/cherie/cherie_quests.dart');
  if (!f.existsSync()) {
    print('Файл не знайдено: ${f.path}');
    exit(1);
  }
  final text = f.readAsStringSync(encoding: utf8);
  print('chars: ${text.length}');
}
