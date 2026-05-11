import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../services/service_locator.dart';
import '../services/save_service.dart';
import '../services/locale_controller.dart';
import '../theme/game_theme.dart';

class SaveLoadScreen extends StatefulWidget {
  const SaveLoadScreen({super.key});

  @override
  State<SaveLoadScreen> createState() => _SaveLoadScreenState();
}

enum _SaveLoadMode { save, load }

class _SaveLoadScreenState extends State<SaveLoadScreen> {
  String? _appPath;
  _SaveLoadMode _mode = _SaveLoadMode.save;

  @override
  void initState() {
    super.initState();
    _initPath();
  }

  Future<void> _initPath() async {
    await SaveService.ensureLegacyAutosaveMigrated();
    final dir = await getApplicationDocumentsDirectory();
    if (mounted) setState(() => _appPath = dir.path);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: sl<LocaleController>(),
      builder: (context, _) {
        return Scaffold(
          backgroundColor: GameTheme.screenBg,
          body: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                _buildSidebar(),
                const SizedBox(width: 15),
                Expanded(child: _buildMainContent()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSidebar() {
    final t = sl<LocaleController>().t;
    return Container(
      width: 280,
      decoration: BoxDecoration(color: GameTheme.bgDark, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          const Spacer(),
          _sideBtn(t('save_screen_back_to_game'), () => Navigator.pop(context)),
          _sideBtn(
            t('save_screen_save_game'),
            () => setState(() => _mode = _SaveLoadMode.save),
            isActive: _mode == _SaveLoadMode.save,
          ),
          _sideBtn(
            t('save_screen_load_game'),
            () => setState(() => _mode = _SaveLoadMode.load),
            isActive: _mode == _SaveLoadMode.load,
          ),
          _sideBtn(
            t('settings_main_menu'),
            () => Navigator.of(context).pushNamedAndRemoveUntil('/menu', (route) => false),
          ),
          _sideBtn(t('settings_donate'), () {}),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _sideBtn(String text, VoidCallback onTap, {bool isActive = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: isActive ? Colors.white : GameTheme.mainGrey,
            foregroundColor: Colors.black87,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            minimumSize: const Size(double.infinity, 50)),
        onPressed: onTap,
        child: Text(text),
      ),
    );
  }

  Widget _buildMainContent() {
    final t = sl<LocaleController>().t;
    return Column(
      children: [
        Expanded(
          flex: 8,
          child: Container(
            decoration: BoxDecoration(color: GameTheme.bgDark, borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 10),
                Expanded(child: _buildGrid()),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
        Expanded(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(color: GameTheme.bgDark, borderRadius: BorderRadius.circular(12)),
            child: Center(
              child: Text(
                t('save_screen_ad'),
                style: const TextStyle(color: GameTheme.mainGrey),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final t = sl<LocaleController>().t;
    return Row(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(50),
            child: const SizedBox(
              width: 34,
              height: 34,
              child: Center(
                child: Icon(Icons.arrow_back, color: GameTheme.mainGrey, size: 22),
              ),
            ),
          ),
        ),
        const Spacer(),
        Text(
          t('save_screen_header'),
          style: const TextStyle(color: GameTheme.mainGrey, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildGrid() {
    // Поки немає шляху до documents, `exists` для слотів завжди false —
    // натискання в режимі «Завантажити» ігнорується; на планшеті ініт інколи пізніший.
    if (_appPath == null) {
      return const Center(
        child: SizedBox(
          width: 36,
          height: 36,
          child: CircularProgressIndicator(strokeWidth: 2.5, color: GameTheme.mainGrey),
        ),
      );
    }
    final autoLabel = sl<LocaleController>().t('save_autosave_short');
    return LayoutBuilder(
      builder: (_, constraints) {
        const spacing = 10.0;
        final cellWidth = (constraints.maxWidth - (spacing * 2)) / 3;
        final cellHeight = (constraints.maxHeight - (spacing * 2)) / 3;

        return GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          childAspectRatio: cellWidth / cellHeight,
          children: List.generate(9, (index) {
            final slot = index;
            final isAutosaveCell = slot == kAutosaveSlot;
            final imgPath = "$_appPath/preview_$slot.png";
            final exists = _appPath != null && File('$_appPath/save_$slot.json').existsSync();

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  if (isAutosaveCell) {
                    if (exists) {
                      await sl<SaveService>().loadGame(kAutosaveSlot);
                      if (mounted) Navigator.pop(context, true);
                    }
                    return;
                  }
                  if (_mode == _SaveLoadMode.load) {
                    if (!exists) return;
                    await sl<SaveService>().loadGame(slot);
                    if (mounted) Navigator.pop(context, true);
                    return;
                  }
                  // Режим "зберегти": повне стирання слота → новий скрін → новий сейв.
                  await sl<SaveService>().saveGameReplacingManualSlot(slot);
                  if (mounted) setState(() {});
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                decoration: BoxDecoration(
                  color: isAutosaveCell ? const Color(0xFF2A2A3A) : const Color(0xFFC4C4C4),
                  borderRadius: BorderRadius.circular(10),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (isAutosaveCell && !exists)
                      Center(
                        child: Text(
                          autoLabel,
                          style: const TextStyle(
                            color: Colors.white24,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    if (isAutosaveCell && exists)
                      Image.file(
                        File(imgPath),
                        key: ValueKey(
                            '$imgPath${File(imgPath).existsSync() ? File(imgPath).lastModifiedSync().millisecondsSinceEpoch : 0}'),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    if (!isAutosaveCell && exists && _appPath != null)
                      Image.file(
                        File(imgPath),
                        key: ValueKey(
                            '$imgPath${File(imgPath).existsSync() ? File(imgPath).lastModifiedSync().millisecondsSinceEpoch : 0}'),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    if (!isAutosaveCell && !exists) const Center(child: Icon(Icons.add, color: Colors.black12, size: 40)),
                    if (isAutosaveCell && exists)
                      Positioned(
                        bottom: 6,
                        left: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            autoLabel,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    if (!isAutosaveCell && exists) ...[
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              File('$_appPath/save_$slot.json').deleteSync();
                              if (File(imgPath).existsSync()) {
                                evictSavePreviewImageCache(imgPath);
                                File(imgPath).deleteSync();
                              }
                              setState(() {});
                            },
                            customBorder: const CircleBorder(),
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.black54,
                                child: Icon(Icons.delete, size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            );
          }),
        );
      },
    );
  }
}
