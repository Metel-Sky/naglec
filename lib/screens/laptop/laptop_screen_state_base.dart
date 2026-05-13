import 'package:flutter/material.dart';

import '../../services/locale_controller.dart';
import '../../services/player_stats_controller.dart';
import '../../services/save_service.dart';
import '../../services/service_locator.dart';
import '../../theme/game_theme.dart';
import '../../widgets/insufficient_money_dialog.dart';
import '../../widgets/lesson_video_screen.dart';
import '../laptop_screen.dart' show LaptopScreen;
import 'laptop_shared_widgets.dart';
import 'laptop_study_data.dart';

/// Спільний стан ноутбука: поля навігації, робочий стіл, навчальне відео, оплата уроків.
/// Розділи (порно, магазин тощо) винесені в mixins у підпапках — поля тут **публічні**,
/// щоб mixins з інших файлів мали доступ (приватні члени в Dart — лише в межах однієї бібліотеки).
abstract class LaptopScreenStateBase extends State<LaptopScreen> {
  static const String desktopImagePath = 'lib/assets/gg/windows.jpeg';

  bool showStudySubmenu = false;
  bool showProgrammingLessons = false;
  bool showLockpickLessons = false;
  bool showStealthLessons = false;
  bool showPasswordLessons = false;
  bool showPhoneLessons = false;
  bool showMassageLessons = false;
  bool showSurfSubmenu = false;
  bool showJobVacancies = false;
  bool showShopSubmenu = false;
  bool showPornSubmenu = false;
  bool watchingPornVideo = false;
  int? selectedPornIndex;
  String? currentPorn5VideoPath;
  bool showHiddenCamerasSubmenu = false;
  String? watchingHiddenCameraRoom;
  bool showCompromatSubmenu = false;
  bool watchingCompromatVideo = false;
  bool showUsbCompromatSubmenu = false;
  String? currentCompromatVideoPath;
  String? currentCompromatNpcId;
  /// Джерело поточного відео: 'mom_office' | 'usb' | 'stored'.
  String? currentCompromatSource;
  /// 'programming' | 'lockpick' | 'stealth' | 'passwords' | 'phone' | 'massage' | 'ero_massage'
  String? watchingSubject;
  int? watchingLessonIndex;

  String t(String key) => sl<LocaleController>().t(key);

  bool payForLesson(int price) {
    final playerStats = sl<PlayerStatsController>();
    if (playerStats.money < price) {
      showInsufficientMoneyDialog(context);
      return false;
    }
    playerStats.changeMoney(-price);
    sl<SaveService>().autosave();
    return true;
  }

  Widget buildUsbCompromatSubmenu();
  Widget buildCompromatSubmenu();
  Widget buildCompromatVideo();
  Widget buildSurfSubmenu();
  Widget buildJobVacanciesView();
  Widget buildShopView();
  Widget buildPornSubmenu();
  Widget buildPornVideo();
  Widget buildHiddenCamerasSubmenu();
  Widget buildHiddenCameraFeed(String roomId);
  Widget buildProgrammingLessons();
  Widget buildLockpickLessons();
  Widget buildStealthLessons();
  Widget buildPasswordLessons();
  Widget buildPhoneLessons();
  Widget buildMassageLessons();
  Widget buildStudySubmenu();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1a3a5c),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            desktopImagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: const Color(0xFF1a3a5c),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: buildContent(),
                        ),
                        if (widget.bottomRightOverlay != null)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            width: constraints.maxWidth * 0.3,
                            height: constraints.maxHeight * 0.3,
                            child: widget.bottomRightOverlay!,
                          ),
                      ],
                    );
                  },
                ),
              ),
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1B2A),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.view_module,
                                  color:
                                      Colors.white.withValues(alpha: 0.9),
                                  size: 22),
                              const SizedBox(width: 8),
                              Text(
                                'Start',
                                style: TextStyle(
                                  color:
                                      Colors.white.withValues(alpha: 0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: widget.onClose,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.laptop_chromebook,
                                  color: GameTheme.mainGrey, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                t('laptop_close'),
                                style: const TextStyle(
                                  color: GameTheme.mainGrey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildContent() {
    if (showUsbCompromatSubmenu) {
      if (watchingCompromatVideo) return buildCompromatVideo();
      return buildUsbCompromatSubmenu();
    }
    if (showSurfSubmenu) {
      if (showJobVacancies) return buildJobVacanciesView();
      return buildSurfSubmenu();
    }
    if (showShopSubmenu) return buildShopView();
    if (showPornSubmenu) {
      if (watchingPornVideo) return buildPornVideo();
      return buildPornSubmenu();
    }
    if (showHiddenCamerasSubmenu) {
      if (watchingHiddenCameraRoom != null) {
        return buildHiddenCameraFeed(watchingHiddenCameraRoom!);
      }
      return buildHiddenCamerasSubmenu();
    }
    if (showCompromatSubmenu) {
      if (watchingCompromatVideo) return buildCompromatVideo();
      return buildCompromatSubmenu();
    }
    if (showStudySubmenu) {
      if (watchingSubject != null && watchingLessonIndex != null) {
        return buildEmbeddedVideo(
            watchingSubject!, watchingLessonIndex!);
      }
      if (showProgrammingLessons) return buildProgrammingLessons();
      if (showLockpickLessons) return buildLockpickLessons();
      if (showStealthLessons) return buildStealthLessons();
      if (showPasswordLessons) return buildPasswordLessons();
      if (showPhoneLessons) return buildPhoneLessons();
      if (showMassageLessons) return buildMassageLessons();
      return buildStudySubmenu();
    }
    return laptopDesktopShortcutsGrid(
      context: context,
      t: t,
      openStudy: () => setState(() => showStudySubmenu = true),
      openSurf: () => setState(() => showSurfSubmenu = true),
      openShop: () => setState(() => showShopSubmenu = true),
      openPorn: () => setState(() => showPornSubmenu = true),
      openHiddenCameras: () =>
          setState(() => showHiddenCamerasSubmenu = true),
      openCompromat: () => setState(() => showCompromatSubmenu = true),
      openUsbCompromat: () => setState(() {
        showUsbCompromatSubmenu = true;
        showCompromatSubmenu = false;
      }),
    );
  }

  Widget buildEmbeddedVideo(String subject, int lessonIndex) {
    final videoPath = subject == 'lockpick'
        ? laptopLockpickVideoPaths[lessonIndex - 1]
        : subject == 'stealth'
            ? laptopStealthVideoPaths[lessonIndex - 1]
            : subject == 'passwords'
                ? laptopPasswordVideoPaths[lessonIndex - 1]
                : subject == 'phone'
                    ? laptopPhoneVideoPaths[lessonIndex - 1]
                    : subject == 'massage'
                        ? laptopMassageVideoPaths[lessonIndex - 1]
                        : subject == 'ero_massage'
                            ? laptopEroMassageVideoPath
                            : laptopProgrammingVideoPaths[lessonIndex - 1];
    return EmbeddedLessonVideo(
      videoPath: videoPath,
      onCompleted: () {},
      onClose: (completed) {
        setState(() {
          watchingSubject = null;
          watchingLessonIndex = null;
        });
        if (completed == true && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t('laptop_next_lesson_tomorrow')),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
  }

  void onStudyChoice(String choice) {
    if (choice == 'phones') {
      final playerStats = sl<PlayerStatsController>();
      if (!playerStats.isPhoneCourseUnlocked) {
        showLaptopWarning(context, t('laptop_warn_passwords_first'));
        return;
      }
      setState(() {
        showPhoneLessons = true;
        showProgrammingLessons = false;
        showLockpickLessons = false;
        showStealthLessons = false;
        showPasswordLessons = false;
        showMassageLessons = false;
      });
    }
  }

  void onLaptopAction(BuildContext context, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            t('laptop_feature_coming_soon').replaceAll('%s', action)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Один крок «назад» усередині ноутбука (порядок як у [buildContent]).
  /// Повертає `false` на робочому столі — тоді зовнішня «Назад» закриє ноут і винесе в коридор.
  bool tryPopLaptopHierarchy() {
    if (!mounted) return false;

    if (showUsbCompromatSubmenu) {
      if (watchingCompromatVideo) {
        setState(() => watchingCompromatVideo = false);
        return true;
      }
      setState(() => showUsbCompromatSubmenu = false);
      return true;
    }
    if (showSurfSubmenu) {
      if (showJobVacancies) {
        setState(() => showJobVacancies = false);
        return true;
      }
      setState(() => showSurfSubmenu = false);
      return true;
    }
    if (showShopSubmenu) {
      setState(() => showShopSubmenu = false);
      return true;
    }
    if (showPornSubmenu) {
      if (watchingPornVideo) {
        setState(() {
          watchingPornVideo = false;
          selectedPornIndex = null;
          currentPorn5VideoPath = null;
        });
        widget.onElsaVideoWatchingChanged?.call(false);
        widget.onWatchingPornChanged?.call(false);
        return true;
      }
      setState(() => showPornSubmenu = false);
      return true;
    }
    if (showHiddenCamerasSubmenu) {
      if (watchingHiddenCameraRoom != null) {
        setState(() => watchingHiddenCameraRoom = null);
        return true;
      }
      setState(() => showHiddenCamerasSubmenu = false);
      return true;
    }
    if (showCompromatSubmenu) {
      if (watchingCompromatVideo) {
        setState(() => watchingCompromatVideo = false);
        return true;
      }
      setState(() => showCompromatSubmenu = false);
      return true;
    }
    if (showStudySubmenu) {
      if (watchingSubject != null && watchingLessonIndex != null) {
        setState(() {
          watchingSubject = null;
          watchingLessonIndex = null;
        });
        return true;
      }
      if (showProgrammingLessons) {
        setState(() => showProgrammingLessons = false);
        return true;
      }
      if (showLockpickLessons) {
        setState(() => showLockpickLessons = false);
        return true;
      }
      if (showStealthLessons) {
        setState(() => showStealthLessons = false);
        return true;
      }
      if (showPasswordLessons) {
        setState(() => showPasswordLessons = false);
        return true;
      }
      if (showPhoneLessons) {
        setState(() => showPhoneLessons = false);
        return true;
      }
      if (showMassageLessons) {
        setState(() => showMassageLessons = false);
        return true;
      }
      setState(() => showStudySubmenu = false);
      return true;
    }
    return false;
  }
}
