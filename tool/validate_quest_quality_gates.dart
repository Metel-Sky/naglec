import 'dart:io';

final Set<String> _legacyEventAllowlist = <String>{
  'lib/npcs/den/den_events.dart',
  'lib/npcs/sem/sem_events.dart',
  'lib/npcs/piper/piper_events.dart',
  'lib/npcs/rockefeller/rockefeller_events.dart',
  'lib/npcs/elsa/elsa_events.dart',
  'lib/npcs/danielle/danielle_events.dart',
  'lib/npcs/mom/mom_events.dart',
};

void main() {
  final root = Directory.current;
  final npcsDir = Directory('${root.path}/lib/npcs');
  if (!npcsDir.existsSync()) {
    stderr.writeln('ERROR: lib/npcs not found.');
    exit(2);
  }

  final questFiles = <File>[];
  final eventFiles = <File>[];
  for (final entity in npcsDir.listSync(recursive: true)) {
    if (entity is! File) continue;
    final path = _rel(root.path, entity.path);
    if (path.endsWith('_quests.dart')) {
      questFiles.add(entity);
    } else if (path.endsWith('_events.dart')) {
      eventFiles.add(entity);
    }
  }

  final errors = <String>[];
  final warnings = <String>[];

  for (final f in questFiles) {
    final rel = _rel(root.path, f.path);
    final text = f.readAsStringSync();
    if (text.contains('BuildContext')) {
      errors.add('$rel: BuildContext is forbidden in quest logic files.');
    }
    if (!RegExp(
      r'(QUEST:\s*[a-z0-9_]+_quest_[0-9]{3})|(Квест\s+[0-9]+\s+—\s+[a-z0-9_]+_quest_[0-9]{3})',
      caseSensitive: false,
    ).hasMatch(text)) {
      errors.add('$rel: missing QUEST marker (`QUEST: <npc>_quest_00N`).');
    }
    if (!RegExp(
      r"[a-zA-Z0-9_]*questId\s*=\s*'[a-z0-9_]+_quest_[0-9]{3}'",
      caseSensitive: false,
    ).hasMatch(text)) {
      errors.add('$rel: missing stable questId constant.');
    }
  }

  for (final f in eventFiles) {
    final rel = _rel(root.path, f.path);
    final text = f.readAsStringSync();
    if (text.contains('BuildContext')) {
      errors.add('$rel: BuildContext is forbidden in event logic files.');
    }
    final hasEventMarker =
        RegExp(r'(EVENT:\s*[a-z0-9_]+_event_[0-9]{3})|(_event_[0-9]{3})')
            .hasMatch(text);
    if (!hasEventMarker) {
      if (_legacyEventAllowlist.contains(rel)) {
        warnings.add('$rel: missing numbered EVENT marker (legacy allowlist).');
      } else {
        errors.add('$rel: missing EVENT marker (`EVENT: <npc>_event_00N`).');
      }
    }
  }

  if (warnings.isNotEmpty) {
    stdout.writeln('WARNINGS:');
    for (final w in warnings) {
      stdout.writeln(' - $w');
    }
  }

  if (errors.isNotEmpty) {
    stderr.writeln('QUALITY GATES FAILED:');
    for (final e in errors) {
      stderr.writeln(' - $e');
    }
    exit(1);
  }

  stdout.writeln(
    'Quest quality gates passed: ${questFiles.length} quest files, '
    '${eventFiles.length} event files.',
  );
}

String _rel(String root, String path) {
  final normalizedRoot = root.replaceAll('\\', '/');
  final normalizedPath = path.replaceAll('\\', '/');
  if (normalizedPath.startsWith('$normalizedRoot/')) {
    return normalizedPath.substring(normalizedRoot.length + 1);
  }
  return normalizedPath;
}
