import 'package:flutter/material.dart';
import '../theme/game_theme.dart';
import '../services/service_locator.dart';
import '../services/locale_controller.dart';
import '../services/settings_controller.dart';
import '../services/save_service.dart';

const String kTelegramUrl = 'https://t.me/';
const String _kUrlPlaceholder = 'https://';

/// Ілюстрація на екрані налаштувань (можна замінити на інший asset).
const String _kSettingsSideImage = 'lib/assets/gg/usdt.gif';

/// Доля від області під картинкою (1.0 − 0.4 = на 40% менше).
const double _kSettingsImageSizeFactor = 0.6;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    sl<SettingsController>().load();
  }

  static const String _kLanguageHeadingKey = 'settings_language_pick_heading';
  static const String _kUsdtCaptionKey = 'settings_usdt_donate_caption';

  /// Заголовок блоку мови (укр/ен/ру + фолбек, якщо в l10n немає ключа).
  String _languageSectionHeading(LocaleController localeCtrl) {
    final raw = localeCtrl.t(_kLanguageHeadingKey);
    if (raw != _kLanguageHeadingKey) {
      return raw.toUpperCase();
    }
    switch (localeCtrl.locale) {
      case localeEn:
        return 'LANGUAGE CHOICE';
      case localeRu:
        return 'ВЫБОР ЯЗЫКА';
      default:
        return 'ВИБІР МОВИ';
    }
  }

  /// Підпис над USDT (фолбек, якщо ключ не підхопився з l10n — інакше видно «settings_…»).
  String _usdtDonateCaption(LocaleController localeCtrl) {
    final raw = localeCtrl.t(_kUsdtCaptionKey);
    if (raw != _kUsdtCaptionKey) return raw;
    switch (localeCtrl.locale) {
      case localeEn:
        return 'Donate USDT to support the project';
      case localeRu:
        return 'Задонать USDT на развитие проекта';
      default:
        return 'Задонать USDT на розвиток проекту';
    }
  }

  String _saveGameButtonLabel(LocaleController localeCtrl) {
    switch (localeCtrl.locale) {
      case localeEn:
        return 'SAVE GAME';
      case localeRu:
        return 'СОХРАНИТЬ ИГРУ';
      default:
        return 'ЗБЕРЕГТИ ГРУ';
    }
  }

  String _gameSavedToast(LocaleController localeCtrl) {
    switch (localeCtrl.locale) {
      case localeEn:
        return 'Game saved.';
      case localeRu:
        return 'Игра сохранена.';
      default:
        return 'Гру збережено.';
    }
  }

  void _openUrl(String url) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            sl<LocaleController>().t('settings_link_shown').replaceAll('%s', url),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeCtrl = sl<LocaleController>();
    final t = localeCtrl.t;

    return ListenableBuilder(
      listenable: Listenable.merge([localeCtrl, sl<SettingsController>()]),
      builder: (context, _) {
        final settings = sl<SettingsController>();
        return Scaffold(
          backgroundColor: GameTheme.bgDark.withValues(alpha: 0.95),
          appBar: AppBar(
        title: Text(t('settings_title'), style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(40, 16, 24, 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: LayoutBuilder(
                          builder: (context, langConstraints) {
                            final dropdownW =
                                (langConstraints.maxWidth * 0.36).clamp(140.0, 240.0);
                            return Align(
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    _languageSectionHeading(localeCtrl),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.bold,
                                      fontSize: (Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14) + 5,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: dropdownW,
                                    child: DropdownButton<String>(
                                      value: localeCtrl.locale,
                                      dropdownColor: GameTheme.bgDark,
                                      isExpanded: true,
                                      underline: const SizedBox(),
                                      borderRadius: BorderRadius.circular(12),
                                      style: const TextStyle(color: Colors.white, fontSize: 16),
                                      alignment: AlignmentDirectional.center,
                                      selectedItemBuilder: (context) => supportedLocales
                                          .map(
                                            (e) => Center(
                                              child: Text(
                                                e.value,
                                                style: const TextStyle(color: Colors.white, fontSize: 16),
                                                textAlign: TextAlign.center,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      items: supportedLocales
                                          .map(
                                            (e) => DropdownMenuItem<String>(
                                              value: e.key,
                                              child: Center(
                                                child: Text(
                                                  e.value,
                                                  style: const TextStyle(color: Colors.white),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (v) {
                                        if (v != null) localeCtrl.setLocale(v);
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  SwitchListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(
                                      t('settings_cheats'),
                                      style: const TextStyle(color: Colors.white70, fontSize: 15),
                                    ),
                                    value: settings.cheatsEnabled,
                                    activeThumbColor: GameTheme.textGreen,
                                    onChanged: (v) => settings.cheatsEnabled = v,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: SizedBox(
                            width: 250,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _menuBtn(
                                  context,
                                  _saveGameButtonLabel(localeCtrl),
                                  () {
                                    sl<SaveService>().autosave();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(_gameSavedToast(localeCtrl)),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                ),
                                _menuBtn(context, t('settings_main_menu').toUpperCase(), () {
                                  Navigator.popUntil(context, (route) => route.isFirst);
                                }),
                                _menuBtn(context, t('settings_back').toUpperCase(), () => Navigator.pop(context)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _socialButton(icon: Icons.telegram, onTap: () => _openUrl(kTelegramUrl)),
                              const SizedBox(width: 16),
                              _socialButton(icon: Icons.link, onTap: () => _openUrl(_kUrlPlaceholder)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
                        child: Text(
                          _usdtDonateCaption(localeCtrl),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: (Theme.of(context).textTheme.titleSmall?.fontSize ?? 14) + 1,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.center,
                          child: FractionallySizedBox(
                            widthFactor: _kSettingsImageSizeFactor,
                            heightFactor: _kSettingsImageSizeFactor,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                _kSettingsSideImage,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Colors.grey.shade900,
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.broken_image, color: Colors.white24, size: 48),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
      },
    );
  }

  Widget _menuBtn(BuildContext context, String text, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: GameTheme.actionButtonStyle(color: Colors.black87),
          onPressed: onTap,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(text, maxLines: 2, textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }

  Widget _socialButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: GameTheme.bgDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: Icon(icon, size: 32, color: GameTheme.mainGrey),
        ),
      ),
    );
  }
}
