// ignore_for_file: avoid_print
/// Перевіряє відсутні медіа-асети, на які є посилання в проєкті.
/// Запуск: dart run tool/check_missing_assets.dart
import 'dart:convert';
import 'dart:io';

final _root = Directory.current;
final _scanFiles = <File>[
  File.fromUri(_root.uri.resolve('pubspec.yaml')),
  File.fromUri(_root.uri.resolve('assets/data/location.json')),
];

const _mediaExts = {
  '.jpg',
  '.jpeg',
  '.png',
  '.webp',
  '.gif',
  '.mp4',
  '.webm',
  '.avi',
  '.mov',
};

final _pathRe = RegExp(r"""['"](lib/assets/[^'"]+)['"]""");

void main() {
  final refs = gatherReferencedMedia().toList()..sort();
  final missing = <String>[];
  for (final asset in refs) {
    final file = File.fromUri(_root.uri.resolve(asset));
    if (!file.existsSync()) {
      missing.add(asset);
    }
  }

  print('Scanned media references: ${refs.length}');
  print('Missing media files: ${missing.length}');
  print('');
  if (missing.isEmpty) {
    print('OK: No missing media references found.');
    exit(0);
  }
  print('Missing files:');
  for (final asset in missing) {
    print('- $asset');
  }
  exit(1);
}

List<File> _gatherScanTargets() {
  final targets = <File>[];
  final libDir = Directory.fromUri(_root.uri.resolve('lib/'));
  if (libDir.existsSync()) {
    for (final entity in libDir.listSync(recursive: true, followLinks: false)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        targets.add(entity);
      }
    }
  }
  for (final p in _scanFiles) {
    if (p.existsSync()) targets.add(p);
  }
  return targets;
}

Set<String> gatherReferencedMedia() {
  final refs = <String>{};
  for (final path in _gatherScanTargets()) {
    late final String content;
    try {
      content = path.readAsStringSync(encoding: utf8);
    } on FileSystemException {
      continue;
    }
    for (final m in _pathRe.allMatches(content)) {
      final assetPath = m.group(1)!.trim();
      final ext = extensionFromPath(assetPath).toLowerCase();
      if (_mediaExts.contains(ext)) {
        refs.add(assetPath);
      }
    }
  }
  return refs;
}

String extensionFromPath(String posixPath) {
  final idx = posixPath.lastIndexOf('.');
  if (idx == -1) return '';
  return posixPath.substring(idx);
}
