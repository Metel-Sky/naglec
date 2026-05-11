// ignore_for_file: avoid_print
/// Перевіряє, що відео-асети — реальні файли, а не вказівники Git LFS.
/// Запуск: `dart run tool/validate_media_assets.dart`
/// Після клону репозиторію: `git lfs install && git lfs pull`
import 'dart:io';

const _lfsPrefix = 'version https://git-lfs.github.com/spec/v1';

Future<void> main() async {
  final root = Directory('lib/assets');
  if (!root.existsSync()) {
    print('No lib/assets — skip.');
    exit(0);
  }
  final bad = <String>[];
  await for (final entity in root.list(recursive: true, followLinks: false)) {
    if (entity is! File) continue;
    final p = entity.path;
    if (!p.endsWith('.webm') && !p.endsWith('.mp4')) continue;
    final size = await entity.length();
    if (size > 512) {
      // Вказівник LFS зазвичай ~130 байт; великі файли — норм.
      continue;
    }
    final head = await entity.openRead(0, 200).first;
    final s = String.fromCharCodes(head);
    if (s.startsWith(_lfsPrefix) || s.contains('git-lfs.github.com')) {
      bad.add('$p (${size} B, Git LFS pointer)');
    }
  }
  if (bad.isEmpty) {
    print('OK: video assets under lib/assets look like real files (no tiny LFS pointers).');
    exit(0);
  }
  stderr.writeln(
    'Помилка: знайдено відео-файли-вказівники Git LFS (реальне відео не завантажено):\n',
  );
  for (final line in bad) {
    stderr.writeln('  $line');
  }
  stderr.writeln(
    '\nВиконайте: git lfs install && git lfs pull\n'
    'Без цього media_kit не може відтворити .webm / .mp4.',
  );
  exit(1);
}
