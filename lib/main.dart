import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:media_kit/media_kit.dart';
import 'package:naglec/theme/game_theme.dart';
import 'package:naglec/widgets/news_panel.dart';
import 'dart:io'; // Потрібно для Platform
import 'package:window_manager/window_manager.dart'; // Імпортуємо пакет
import 'screens/main_game_screen.dart';
import 'screens/save_load_screen.dart';
import 'screens/settings_screen.dart';
import 'services/service_locator.dart';
import 'data/shop_products_catalog.dart';
import 'services/locations_loader.dart';
import 'services/save_service.dart';
import 'services/locale_controller.dart';
import 'services/settings_controller.dart';
import 'services/desktop_window_geometry_store.dart';

/// Аргумент маршруту `/menu`: після холодного старту відкрити збереження без додаткового натискання.
const String _kMainMenuArgAutoResume = 'auto_resume';

bool _isDesktopOs() =>
    !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

/// macOS: з engine підтягнути фактично натиснуті клавіші, щоб рідше ловити
/// assert у [HardwareKeyboard] (дубль KeyDown при зміні фокусу/розкладки).
Future<void> _syncMacOsHardwareKeyboard() async {
  if (kIsWeb || !Platform.isMacOS) return;
  try {
    await HardwareKeyboard.instance.syncKeyboardState();
  } catch (_) {
    // getKeyboardState може бути ще не готовий на дуже ранній фазі
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && Platform.isAndroid) {
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  // На мобільних ховаємолгрл верхній системний статус-бар, щоб ігрове поле
  // починалось з самого верху екрана (на Android-планшетах без зайвої смуги).
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: const [SystemUiOverlay.bottom],
    );
  }

  setupServiceLocator();

  // Вікно готуємо, але не показуємо — показ після першого кадру в LoadingScreen, щоб не було чорного екрану
  if (_isDesktopOs()) {
    await windowManager.ensureInitialized();
    final windowOptions = WindowOptions(
      size: DesktopWindowGeometryStore.defaultWindowSize,
      center: true,
      minimumSize: DesktopWindowGeometryStore.minimumWindowSize,
      maximumSize: DesktopWindowGeometryStore.maximumWindowSize,
      title: 'Have It All',
    );
    await windowManager.waitUntilReadyToShow(windowOptions, null);
  }

  runApp(const NaglecGame());
}

/// Екран завантаження: показується одразу (швидкий перший кадр), важку ініціалізацію робить після малювання.
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  String _status = 'Завантаження...';
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Показуємо вікно після першого кадру (на десктопі), щоб користувач одразу бачив контент, а не чорний екран
      if (_isDesktopOs()) {
        await windowManager.show();
        await windowManager.focus();
        await _syncMacOsHardwareKeyboard();
      }
      _load();
    });
  }

  Future<void> _load() async {
    final navigator = Navigator.of(context);
    try {
      setState(() => _status = 'Локації...');
      await LocationsLoader.load(rootBundle);
      setState(() => _status = 'Каталог магазинів...');
      await ShopProductsCatalog.load(rootBundle);
      setState(() => _status = 'Налаштування...');
      await sl<LocaleController>().loadLocale();
      await sl<SettingsController>().load();
      MediaKit.ensureInitialized();
      if (!mounted) return;
      final hasAutosave = await SaveService.hasAutosave();
      if (hasAutosave) {
        await sl<SaveService>().loadAutosave();
        if (!mounted) return;
        navigator.pushReplacementNamed('/menu', arguments: _kMainMenuArgAutoResume);
      } else {
        navigator.pushReplacementNamed('/menu');
      }
    } catch (e, st) {
      debugPrint('LoadingScreen error: $e\n$st');
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameTheme.screenBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
            ] else ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(_status, style: const TextStyle(fontSize: 18)),
            ],
          ],
        ),
      ),
    );
  }
}

class NaglecGame extends StatefulWidget {
  const NaglecGame({super.key});

  @override
  State<NaglecGame> createState() => _NaglecGameState();
}

class _NaglecGameState extends State<NaglecGame>
    with WindowListener, WidgetsBindingObserver {
  Future<void> _applyImmersiveMode() async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyImmersiveMode();
    });
    if (_isDesktopOs()) {
      windowManager.addListener(this);
      windowManager.setPreventClose(true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_isDesktopOs()) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _applyImmersiveMode();
      _syncMacOsHardwareKeyboard();
    }
  }

  @override
  void onWindowFocus() {
    _syncMacOsHardwareKeyboard();
  }

  @override
  void onWindowClose() async {
    if (!_isDesktopOs()) return;
    await DesktopWindowGeometryStore.saveNow();
    await windowManager.setPreventClose(false);
    await windowManager.close();
  }

  @override
  Widget build(BuildContext context) {
    final localeCtrl = sl<LocaleController>();
    return ListenableBuilder(
      listenable: localeCtrl,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark(),
          locale: localeCtrl.flutterLocale,
          initialRoute: '/',
          routes: {
            '/': (context) => const LoadingScreen(),
            '/menu': (context) {
              final resume = ModalRoute.of(context)?.settings.arguments == _kMainMenuArgAutoResume;
              return MainMenuScreen(openGameOnFirstFrame: resume);
            },
          },
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('uk'),
            Locale('en'),
            Locale('ru'),
          ],
        );
      },
    );
  }
}

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key, this.openGameOnFirstFrame = false});

  /// Після автозавантаження сейву на екрані завантаження — одразу відкрити ігровий екран (стек: меню → гра).
  final bool openGameOnFirstFrame;

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.openGameOnFirstFrame) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MainGameScreen()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameTheme.screenBg,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 1024,
            minHeight: 650,
            maxWidth: 2560,
            maxHeight: 1440,
          ),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 250, // Не менше 250
                      maxWidth: 300, // ширина лівої панелі Не більше 350
                    ),
                    child: const LeftMenuPanel(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        Expanded(flex: 3, child: MainArtCard()),
                        SizedBox(height: 12),
                        Expanded(flex: 1, child: NewsPanel()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LeftMenuPanel extends StatelessWidget {
  const LeftMenuPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final t = sl<LocaleController>().t;
    return Container(
      decoration: BoxDecoration(
        color: GameTheme.bgDark,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      child: Column(
        children: [
          const Spacer(),
          _buildMenuButton(context, t, t('menu_new_game_btn'), id: 'new_game'),
          _buildMenuButton(context, t, t('menu_continue'), id: 'continue'),
          _buildMenuButton(context, t, t('menu_load_game'), id: 'load'),
          _buildMenuButton(context, t, t('menu_settings'), id: 'settings'),
          _buildMenuButton(context, t, t('menu_gallery'), id: 'gallery'),
          _buildMenuButton(context, t, t('menu_help_project'), id: 'help'),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              Icon(Icons.monetization_on, size: 40),
              Icon(Icons.telegram, size: 40),
              Icon(Icons.camera_alt, size: 40),
              Icon(Icons.facebook, size: 40),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String Function(String) t,
    String text, {
    String? id,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        height: 45,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withAlpha(230),
            foregroundColor: Colors.black,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () async {
            if (id == 'settings') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
              return;
            }
            if (id == 'new_game') {
              try {
                await startNewGameSession();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const MainGameScreen()),
                    (route) => false,
                  );
                }
              } catch (e, st) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${t('error_prefix')}$e'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 5),
                    ),
                  );
                }
                debugPrint('startNewGameSession error: $e\n$st');
              }
            } else if (id == 'continue') {
              final hasAuto = await SaveService.hasAutosave();
              if (hasAuto) {
                await sl<SaveService>().loadAutosave();
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MainGameScreen()),
                  );
                }
              } else {
                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(t('menu_continue')),
                      content: Text(t('continue_no_save_hint')),
                      actionsAlignment: MainAxisAlignment.center,
                      actions: [
                        TextButton(
                          onPressed: () async {
                            Navigator.of(ctx).pop();
                            try {
                              await startNewGameSession();
                              if (context.mounted) {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => const MainGameScreen(),
                                  ),
                                  (route) => false,
                                );
                              }
                            } catch (e, st) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${t('error_prefix')}$e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                              debugPrint('startNewGameSession error: $e\n$st');
                            }
                          },
                          child: Text(t('menu_new_game_btn')),
                        ),
                      ],
                    ),
                  );
                }
              }
            } else if (id == 'load') {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SaveLoadScreen()),
              );

              // Якщо зі слоту була завантажена гра – відкриваємо її
              if (result == true) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MainGameScreen()),
                );
              }
            }
          },
          child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        ),
      ),
    );
  }
}

class MainArtCard extends StatelessWidget {
  const MainArtCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GameTheme.bgDark,
        borderRadius: BorderRadius.circular(15),
        image: const DecorationImage(
          image: AssetImage('lib/assets/location/home_gg/home_gg.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}