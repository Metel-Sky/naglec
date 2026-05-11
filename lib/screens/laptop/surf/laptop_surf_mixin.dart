import 'package:flutter/material.dart';

import '../../../services/game_world_state.dart';
import '../../../services/player_stats_controller.dart';
import '../../../services/save_service.dart';
import '../../../services/service_locator.dart';
import '../laptop_screen_state_base.dart';
import '../laptop_shared_widgets.dart';

mixin LaptopSurfMixin on LaptopScreenStateBase {
  @override
  Widget buildSurfSubmenu() {
    final playerStats = sl<PlayerStatsController>();
    final canSellSoftware = playerStats.player.programming >= 100;
    final canSellVirus = playerStats.player.hacking >= 100;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          laptopBackButtonRow(
            onBack: () => setState(() => showSurfSubmenu = false),
            backLabel: t('laptop_study_back'),
          ),
          const SizedBox(height: 24),
          laptopStudyOptionTile(
            t('laptop_surf_job'),
            Icons.work_outline,
            () => onSurfChoice('job'),
          ),
          laptopStudyOptionTile(
            t('laptop_surf_news'),
            Icons.newspaper,
            () => onSurfChoice('news'),
          ),
          laptopStudyOptionTile(
            t('laptop_surf_email'),
            Icons.email_outlined,
            () => onSurfChoice('email'),
          ),
          if (canSellSoftware) ...[
            laptopStudyOptionTile(
              t('laptop_surf_sell_software'),
              Icons.sell,
              () => onSurfChoice('sell_software'),
            ),
          ],
          if (canSellVirus) ...[
            laptopStudyOptionTile(
              t('laptop_surf_sell_virus'),
              Icons.bug_report,
              () => onSurfChoice('sell_virus'),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget buildJobVacanciesView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          laptopBackButtonRow(
            onBack: () => setState(() => showJobVacancies = false),
            backLabel: t('laptop_study_back'),
          ),
          const SizedBox(height: 24),
          Builder(
            builder: (context) {
              final world = sl<GameWorldState>();
              return Column(
                children: [
                  if (!world.flyersJobOfferPending)
                    laptopStudyOptionTile(
                      t('job_vacancy_flyers'),
                      Icons.campaign_outlined,
                      () => onJobVacancyTap('flyers'),
                    ),
                  if (!world.flyersJobOfferPending)
                    const SizedBox(height: 10),
                  if (!world.constructionJobOfferPending)
                    laptopStudyOptionTile(
                      t('job_vacancy_construction'),
                      Icons.construction_outlined,
                      () => onJobVacancyTap('construction'),
                    ),
                  if (!world.constructionJobOfferPending)
                    const SizedBox(height: 10),
                  if (!world.callCenterJobOfferPending)
                    laptopStudyOptionTile(
                      t('job_vacancy_call_center'),
                      Icons.headset_mic_outlined,
                      () => onJobVacancyTap('call_center'),
                    ),
                  if (!world.callCenterJobOfferPending)
                    const SizedBox(height: 10),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void onJobVacancyTap(String vacancy) {
    final vacancyName = switch (vacancy) {
      'flyers' => t('job_vacancy_flyers'),
      'construction' => t('job_vacancy_construction'),
      'call_center' => t('job_vacancy_call_center'),
      _ => vacancy,
    };
    showDialog<bool>(
      context: context,
      builder: (ctx) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 320),
          child: AlertDialog(
            title: Center(child: Text(vacancyName)),
            content: Center(child: Text(t('job_confirm_vacancy'))),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(t('shop_no')),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(t('shop_yes')),
              ),
            ],
          ),
        ),
      ),
    ).then((confirmed) {
      if (confirmed != true || !mounted) return;
      if (vacancy == 'flyers') {
        sl<GameWorldState>().flyersJobOfferPending = true;
        sl<SaveService>().autosave();
        setState(() {});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t('job_flyers_accepted')),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
      if (vacancy == 'construction') {
        sl<GameWorldState>().constructionJobOfferPending = true;
        sl<SaveService>().autosave();
        setState(() {});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t('job_construction_accepted')),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
      if (vacancy == 'call_center') {
        sl<GameWorldState>().callCenterJobOfferPending = true;
        sl<SaveService>().autosave();
        setState(() {});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t('job_call_center_accepted')),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
    });
  }

  void onSurfChoice(String choice) {
    if (choice == 'job') {
      setState(() => showJobVacancies = true);
      return;
    }
    if (choice == 'news' || choice == 'email') {
      final label = choice == 'news'
          ? t('laptop_surf_news')
          : t('laptop_surf_email');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              t('laptop_feature_coming_soon').replaceAll('%s', label)),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (choice == 'sell_software') {
      sl<PlayerStatsController>().changeMoney(500);
      sl<SaveService>().autosave();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(t('laptop_surf_sold_software')),
            behavior: SnackBarBehavior.floating),
      );
      return;
    }
    if (choice == 'sell_virus') {
      sl<PlayerStatsController>().changeMoney(1000);
      sl<SaveService>().autosave();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(t('laptop_surf_sold_virus')),
            behavior: SnackBarBehavior.floating),
      );
    }
  }
}
