import 'dart:math';

import 'package:flutter/material.dart';

import '../../../services/player_stats_controller.dart';
import '../../../services/save_service.dart';
import '../../../services/service_locator.dart';
import '../../../widgets/lesson_video_screen.dart';
import '../laptop_screen_state_base.dart';
import '../laptop_shared_widgets.dart';
import 'laptop_porn_data.dart';

mixin LaptopPornMixin on LaptopScreenStateBase {
  @override
  Widget buildPornSubmenu() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          laptopBackButtonRow(
            onBack: () => setState(() => showPornSubmenu = false),
            backLabel: t('laptop_study_back'),
          ),
          const SizedBox(height: 24),
          for (int i = 1; i <= 5; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () {
                    String? chosenPath;
                    if (i == 5) {
                      chosenPath = laptopPorn5VideoPaths[
                          Random().nextInt(laptopPorn5VideoPaths.length)];
                      widget.onElsaVideoWatchingChanged
                          ?.call(chosenPath.contains('elsa_kompromat'));
                    }
                    setState(() {
                      watchingPornVideo = true;
                      selectedPornIndex = i;
                      if (i == 5) currentPorn5VideoPath = chosenPath;
                    });
                    widget.onWatchingPornChanged?.call(true);
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Icon(Icons.play_circle_filled,
                            size: 28,
                            color: Colors.white.withValues(alpha: 0.95)),
                        const SizedBox(width: 16),
                        Text(
                          '${t('laptop_porn')} $i',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget buildPornVideo() {
    final index = (selectedPornIndex ?? 1) - 1;
    final videoPath = (selectedPornIndex == 5 &&
            currentPorn5VideoPath != null)
        ? currentPorn5VideoPath!
        : laptopPornVideoPaths[
            index.clamp(0, laptopPornVideoPaths.length - 1)];
    return EmbeddedLessonVideo(
      videoPath: videoPath,
      onCompleted: () {
        final playerStats = sl<PlayerStatsController>();
        playerStats.changeArousal(20);
        playerStats.changeLust(1);
        sl<SaveService>().autosave();
      },
      onClose: (completed) {
        widget.onElsaVideoWatchingChanged?.call(false);
        setState(() {
          watchingPornVideo = false;
          selectedPornIndex = null;
          currentPorn5VideoPath = null;
        });
        widget.onWatchingPornChanged?.call(false);
      },
    );
  }
}
