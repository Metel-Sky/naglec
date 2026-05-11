// ignore_for_file: avoid_print
/// Колишній cleanup.py — заміни в Dart-файлах навігації.
import 'dart:convert';
import 'dart:io';

void main() {
  for (final rel in [
    'lib/screens/main_game/main_game_screen_state.dart',
    'lib/services/game_navigation_controller.dart',
  ]) {
    _process(File('${Directory.current.path}/$rel'));
  }
}

void _process(File filepath) {
  final lines = filepath.readAsLinesSync(encoding: utf8);
  final out = StringBuffer();
  for (final line in lines) {
    if (line.contains('_syncWorldState();')) continue;
    if (line.contains('final bool hasSelectedNpc = _selectedNpcIdInRoom != null &&')) {
      out.writeln('          final bool hasSelectedNpc = _selectedNpcIdInRoom != null;');
    } else if (line.contains('_spendMoveEnergy();')) {
      out.writeln(line.replaceAll('_spendMoveEnergy();', '_nav.spendMoveEnergy();'));
    } else {
      out.writeln(line);
    }
  }
  filepath.writeAsStringSync(out.toString(), encoding: utf8);
}
