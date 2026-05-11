import 'package:flutter/material.dart';

import '../../../services/game_time_controller.dart';
import '../../../services/player_stats_controller.dart';
import '../../../services/save_service.dart';
import '../../../services/service_locator.dart';
import '../laptop_screen_state_base.dart';
import '../laptop_shared_widgets.dart';
import '../laptop_study_data.dart';

mixin LaptopStudyMixin on LaptopScreenStateBase {
  Widget programmingLessonButton({
    required int lessonIndex,
    required bool completed,
    required bool isNextLesson,
    required bool canWatchToday,
    required int price,
    required VoidCallback onTap,
  }) {
    final levelKey = 'laptop_lesson_level_$lessonIndex';
    final levelLabel = t(levelKey);
    final title = 'Урок $lessonIndex ($levelLabel) $price\$';
    final enabled = isNextLesson && canWatchToday;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white.withValues(alpha: enabled ? 0.2 : 0.08),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  completed
                      ? Icons.check_circle
                      : (enabled
                          ? Icons.play_circle_filled
                          : Icons.lock_outline),
                  size: 28,
                  color: completed
                      ? const Color(0xFF4CAF50)
                      : (enabled ? Colors.white : Colors.white54),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: (enabled ? Colors.white : Colors.white54)
                                .withValues(alpha: 0.95),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (completed) ...[
                        const SizedBox(width: 8),
                        Text(
                          '(${t('laptop_lesson_completed')})',
                          style: const TextStyle(
                            color: Color(0xFF4CAF50),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onProgrammingLessonTap(int lessonIndex) {
    final playerStats = sl<PlayerStatsController>();
    final gameDate = sl<GameTimeController>().dateTime;
    final isNextLesson =
        lessonIndex == playerStats.programmingLessonsCompleted + 1;

    if (!isNextLesson) {
      if (lessonIndex <= playerStats.programmingLessonsCompleted) {
        return;
      }
      showLaptopWarning(context, t('laptop_warn_watch_in_order'));
      return;
    }
    if (!playerStats.canWatchProgrammingLessonToday(
        gameDate)) {
      showLaptopWarning(context, t('laptop_warn_already_watched'));
      return;
    }
    if (!payForLesson(laptopPriceProgramming)) return;
    playerStats.completeProgrammingLesson(lessonIndex, gameDate);
    sl<SaveService>().autosave();

    setState(() {
      watchingSubject = 'programming';
      watchingLessonIndex = lessonIndex;
    });
  }

  void onLockpickLessonTap(int lessonIndex) {
    final playerStats = sl<PlayerStatsController>();
    final gameDate = sl<GameTimeController>().dateTime;
    final isNextLesson =
        lessonIndex == playerStats.lockpickLessonsCompleted + 1;

    if (!isNextLesson) {
      if (lessonIndex <= playerStats.lockpickLessonsCompleted) return;
      showLaptopWarning(context, t('laptop_warn_watch_in_order'));
      return;
    }
    if (!playerStats.canWatchLockpickLessonToday(
        gameDate)) {
      showLaptopWarning(context, t('laptop_warn_already_watched'));
      return;
    }
    if (!payForLesson(laptopPriceLockpick)) return;
    playerStats.completeLockpickLesson(lessonIndex, gameDate);
    sl<SaveService>().autosave();

    setState(() {
      watchingSubject = 'lockpick';
      watchingLessonIndex = lessonIndex;
    });
  }

  void onStealthLessonTap(int lessonIndex) {
    final playerStats = sl<PlayerStatsController>();
    final gameDate = sl<GameTimeController>().dateTime;
    final isNextLesson =
        lessonIndex == playerStats.stealthLessonsCompleted + 1;

    if (!isNextLesson) {
      if (lessonIndex <= playerStats.stealthLessonsCompleted) return;
      showLaptopWarning(context, t('laptop_warn_watch_in_order'));
      return;
    }
    if (!playerStats.canWatchStealthLessonToday(
        gameDate)) {
      showLaptopWarning(context, t('laptop_warn_already_watched'));
      return;
    }
    if (!payForLesson(laptopPriceStealth)) return;
    playerStats.completeStealthLesson(lessonIndex, gameDate);
    sl<SaveService>().autosave();

    setState(() {
      watchingSubject = 'stealth';
      watchingLessonIndex = lessonIndex;
    });
  }

  void onPasswordLessonTap(int lessonIndex) {
    final playerStats = sl<PlayerStatsController>();
    final gameDate = sl<GameTimeController>().dateTime;
    final isNextLesson =
        lessonIndex == playerStats.passwordLessonsCompleted + 1;

    if (!isNextLesson) {
      if (lessonIndex <= playerStats.passwordLessonsCompleted) return;
      showLaptopWarning(context, t('laptop_warn_watch_in_order'));
      return;
    }
    if (!playerStats.canWatchPasswordLessonToday(
        gameDate)) {
      showLaptopWarning(context, t('laptop_warn_already_watched'));
      return;
    }
    if (!payForLesson(laptopPricePasswords)) return;
    playerStats.completePasswordLesson(lessonIndex, gameDate);
    sl<SaveService>().autosave();

    setState(() {
      watchingSubject = 'passwords';
      watchingLessonIndex = lessonIndex;
    });
  }

  void onPhoneLessonTap(int lessonIndex) {
    final playerStats = sl<PlayerStatsController>();
    final gameDate = sl<GameTimeController>().dateTime;
    final isNextLesson = lessonIndex == playerStats.phoneLessonsCompleted + 1;

    if (!isNextLesson) {
      if (lessonIndex <= playerStats.phoneLessonsCompleted) return;
      showLaptopWarning(context, t('laptop_warn_watch_in_order'));
      return;
    }
    if (!playerStats.canWatchPhoneLessonToday(
        gameDate)) {
      showLaptopWarning(context, t('laptop_warn_already_watched'));
      return;
    }
    if (!payForLesson(laptopPricePhone)) return;
    playerStats.completePhoneLesson(lessonIndex, gameDate);
    sl<SaveService>().autosave();

    setState(() {
      watchingSubject = 'phone';
      watchingLessonIndex = lessonIndex;
    });
  }

  void onMassageLessonTap(int lessonIndex) {
    final playerStats = sl<PlayerStatsController>();
    final gameDate = sl<GameTimeController>().dateTime;
    final isNextLesson =
        lessonIndex == playerStats.massageLessonsCompleted + 1;

    if (!isNextLesson) {
      if (lessonIndex <= playerStats.massageLessonsCompleted) return;
      showLaptopWarning(context, t('laptop_warn_watch_in_order'));
      return;
    }
    if (!playerStats.canWatchMassageLessonToday(
        gameDate)) {
      showLaptopWarning(context, t('laptop_warn_already_watched'));
      return;
    }
    if (!payForLesson(laptopPriceMassage)) return;
    playerStats.completeMassageLesson(lessonIndex, gameDate);
    playerStats.changeArousal(5);
    sl<SaveService>().autosave();

    setState(() {
      watchingSubject = 'massage';
      watchingLessonIndex = lessonIndex;
    });
  }

  void onEroMassageTap() {
    final playerStats = sl<PlayerStatsController>();
    final gameDate = sl<GameTimeController>().dateTime;
    if (playerStats.massage_experience >= playerStats.maxMassage_experience) {
      showLaptopWarning(context, t('laptop_massage_max_reached'));
      return;
    }
    if (!playerStats.canWatchEroMassageToday(gameDate)) {
      showLaptopWarning(context, t('laptop_warn_already_watched'));
      return;
    }
    if (!payForLesson(laptopPriceEroMassage)) return;
    playerStats.completeEroMassage(gameDate);
    sl<SaveService>().autosave();

    setState(() {
      watchingSubject = 'ero_massage';
      watchingLessonIndex = 1;
    });
  }

  @override
  Widget buildStudySubmenu() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          laptopBackButtonRow(
            onBack: () => setState(() => showStudySubmenu = false),
            backLabel: t('laptop_study_back'),
          ),
          const SizedBox(height: 24),
          laptopStudyOptionTile(
            t('laptop_study_programming'),
            Icons.code,
            () => setState(() {
              showProgrammingLessons = true;
              showLockpickLessons = false;
              showStealthLessons = false;
              showPasswordLessons = false;
              showPhoneLessons = false;
              showMassageLessons = false;
            }),
          ),
          laptopStudyOptionTile(
            t('laptop_study_lockpick'),
            Icons.lock_open,
            () => setState(() {
              showLockpickLessons = true;
              showProgrammingLessons = false;
              showStealthLessons = false;
              showPasswordLessons = false;
              showPhoneLessons = false;
              showMassageLessons = false;
            }),
          ),
          laptopStudyOptionTile(
            t('laptop_study_stealth'),
            Icons.directions_walk,
            () => setState(() {
              showStealthLessons = true;
              showProgrammingLessons = false;
              showLockpickLessons = false;
              showPasswordLessons = false;
              showPhoneLessons = false;
              showMassageLessons = false;
            }),
          ),
          laptopStudyOptionTile(
            t('laptop_study_passwords'),
            Icons.password,
            () => setState(() {
              showPasswordLessons = true;
              showProgrammingLessons = false;
              showLockpickLessons = false;
              showStealthLessons = false;
              showPhoneLessons = false;
              showMassageLessons = false;
            }),
          ),
          laptopStudyOptionTile(
            t('laptop_study_phones'),
            Icons.smartphone,
            () => onStudyChoice('phones'),
          ),
          laptopStudyOptionTile(
            t('laptop_study_massage'),
            Icons.spa,
            () => setState(() {
              showMassageLessons = true;
              showProgrammingLessons = false;
              showLockpickLessons = false;
              showStealthLessons = false;
              showPasswordLessons = false;
              showPhoneLessons = false;
            }),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildProgrammingLessons() {
    final playerStats = sl<PlayerStatsController>();
    final gameDate = sl<GameTimeController>().dateTime;
    final canWatchToday =
        playerStats.canWatchProgrammingLessonToday(gameDate);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          laptopBackButtonRow(
            onBack: () => setState(() => showProgrammingLessons = false),
            backLabel: t('laptop_study_back'),
          ),
          const SizedBox(height: 24),
          for (int i = 1; i <= 5; i++) ...[
            programmingLessonButton(
              lessonIndex: i,
              completed: i <= playerStats.programmingLessonsCompleted,
              isNextLesson:
                  i == playerStats.programmingLessonsCompleted + 1,
              canWatchToday: canWatchToday,
              price: laptopPriceProgramming,
              onTap: () => onProgrammingLessonTap(i),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget buildLockpickLessons() {
    final playerStats = sl<PlayerStatsController>();
    final canWatchToday = playerStats.canWatchLockpickLessonToday(
        sl<GameTimeController>().dateTime);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          laptopBackButtonRow(
            onBack: () => setState(() => showLockpickLessons = false),
            backLabel: t('laptop_study_back'),
          ),
          const SizedBox(height: 24),
          for (int i = 1; i <= 5; i++) ...[
            programmingLessonButton(
              lessonIndex: i,
              completed: i <= playerStats.lockpickLessonsCompleted,
              isNextLesson: i == playerStats.lockpickLessonsCompleted + 1,
              canWatchToday: canWatchToday,
              price: laptopPriceLockpick,
              onTap: () => onLockpickLessonTap(i),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget buildStealthLessons() {
    final playerStats = sl<PlayerStatsController>();
    final canWatchToday = playerStats.canWatchStealthLessonToday(
        sl<GameTimeController>().dateTime);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          laptopBackButtonRow(
            onBack: () => setState(() => showStealthLessons = false),
            backLabel: t('laptop_study_back'),
          ),
          const SizedBox(height: 24),
          for (int i = 1; i <= 5; i++) ...[
            programmingLessonButton(
              lessonIndex: i,
              completed: i <= playerStats.stealthLessonsCompleted,
              isNextLesson: i == playerStats.stealthLessonsCompleted + 1,
              canWatchToday: canWatchToday,
              price: laptopPriceStealth,
              onTap: () => onStealthLessonTap(i),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget buildPasswordLessons() {
    final playerStats = sl<PlayerStatsController>();
    final canWatchToday = playerStats.canWatchPasswordLessonToday(
        sl<GameTimeController>().dateTime);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          laptopBackButtonRow(
            onBack: () => setState(() => showPasswordLessons = false),
            backLabel: t('laptop_study_back'),
          ),
          const SizedBox(height: 24),
          for (int i = 1; i <= 5; i++) ...[
            programmingLessonButton(
              lessonIndex: i,
              completed: i <= playerStats.passwordLessonsCompleted,
              isNextLesson: i == playerStats.passwordLessonsCompleted + 1,
              canWatchToday: canWatchToday,
              price: laptopPricePasswords,
              onTap: () => onPasswordLessonTap(i),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget buildPhoneLessons() {
    final playerStats = sl<PlayerStatsController>();
    final canWatchToday = playerStats.canWatchPhoneLessonToday(
        sl<GameTimeController>().dateTime);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          laptopBackButtonRow(
            onBack: () => setState(() => showPhoneLessons = false),
            backLabel: t('laptop_study_back'),
          ),
          const SizedBox(height: 24),
          for (int i = 1; i <= 5; i++) ...[
            programmingLessonButton(
              lessonIndex: i,
              completed: i <= playerStats.phoneLessonsCompleted,
              isNextLesson: i == playerStats.phoneLessonsCompleted + 1,
              canWatchToday: canWatchToday,
              price: laptopPricePhone,
              onTap: () => onPhoneLessonTap(i),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget buildMassageLessons() {
    final playerStats = sl<PlayerStatsController>();
    final gameDate = sl<GameTimeController>().dateTime;
    final canWatchToday =
        playerStats.canWatchMassageLessonToday(gameDate);
    final eroUnlocked = playerStats.isEroMassageUnlocked;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          laptopBackButtonRow(
            onBack: () => setState(() => showMassageLessons = false),
            backLabel: t('laptop_study_back'),
          ),
          const SizedBox(height: 24),
          for (int i = 1; i <= 10; i++) ...[
            programmingLessonButton(
              lessonIndex: i,
              completed: i <= playerStats.massageLessonsCompleted,
              isNextLesson: i == playerStats.massageLessonsCompleted + 1,
              canWatchToday: canWatchToday,
              price: laptopPriceMassage,
              onTap: () => onMassageLessonTap(i),
            ),
          ],
          if (eroUnlocked) ...[
            const SizedBox(height: 16),
            if (playerStats.massage_experience >=
                playerStats.maxMassage_experience) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle,
                            size: 28, color: Colors.white54),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            t('laptop_massage_max_reached'),
                            style: TextStyle(
                                color: Colors.white54, fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ] else ...[
              laptopStudyOptionTile(
                '${t('laptop_study_ero_massage')} $laptopPriceEroMassage\$',
                Icons.favorite,
                onEroMassageTap,
              ),
            ],
          ],
        ],
      ),
    );
  }
}
