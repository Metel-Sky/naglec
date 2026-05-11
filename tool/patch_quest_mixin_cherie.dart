// ignore_for_file: avoid_print
/// Колишній test_mixin.py — змінює оголошення міксина.
import 'dart:convert';
import 'dart:io';

void main() {
  final path = File('${Directory.current.path}/lib/screens/main_game/main_game_quest_and_zone.dart');
  var text = path.readAsStringSync(encoding: utf8);
  text = text.replaceAll(
    'mixin MainGameQuestFlows on MainGameScreenStateBase {',
    'mixin MainGameQuestFlows on MainGameScreenStateBase, CherieQuestFlows {',
  );
  path.writeAsStringSync(text, encoding: utf8);
}
