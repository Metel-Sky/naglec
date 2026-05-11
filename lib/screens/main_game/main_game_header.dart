import 'package:flutter/material.dart';
import '../../services/game_time_controller.dart';
import '../../services/locale_controller.dart';
import '../../services/service_locator.dart';
import 'main_game_header_label.dart';

/// Верхня панель: назад (як у магазині ТРЦ), день, дата, час, назва локації.
class MainGameHeader extends StatelessWidget {
  const MainGameHeader({
    super.key,
    required this.timeController,
    required this.showBackButton,
    required this.onBack,
    required this.locationParts,
    required this.isNpcGalleryOpen,
    required this.isStatsOpen,
    required this.onNextDayName,
    required this.onPrevDayName,
    required this.onAddDay,
    required this.onSubDay,
    required this.onSubHour,
    required this.onSubMinute,
    required this.onAddMinutes5,
    required this.onAddHour,
  });

  final GameTimeController timeController;
  final bool showBackButton;
  final VoidCallback onBack;
  final MainGameHeaderLocationParts locationParts;
  final bool isNpcGalleryOpen;
  final bool isStatsOpen;

  final VoidCallback onNextDayName;
  final VoidCallback onPrevDayName;
  final VoidCallback onAddDay;
  final VoidCallback onSubDay;
  final VoidCallback onSubHour;
  final VoidCallback onSubMinute;
  final VoidCallback onAddMinutes5;
  final VoidCallback onAddHour;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: timeController,
      builder: (context, _) {
        return Row(
          children: [
            if (showBackButton)
              _MainGameBackButton(
                onTap: onBack,
                label: sl<LocaleController>().t('laptop_study_back'),
              ),
            _TimeControlBlock(
              label: timeController.dayName,
              onPlus: onNextDayName,
              onMinus: onPrevDayName,
            ),
            _TimeControlBlock(
              label: timeController.onlyDate,
              onPlus: onAddDay,
              onMinus: onSubDay,
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _MiniBtn(label: '--', onTap: onSubHour),
                  _MiniBtn(label: '-', onTap: onSubMinute),
                  const SizedBox(width: 10),
                  Text(
                    timeController.formattedTime,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  _MiniBtn(label: '+', onTap: onAddMinutes5),
                  _MiniBtn(label: '++', onTap: onAddHour),
                ],
              ),
            ),
            const Spacer(),
            Flexible(
              child: Align(
                alignment: Alignment.centerRight,
                child: isNpcGalleryOpen
                    ? const Text(
                        "ПЕРСОНАЖІ   ",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      )
                    : isStatsOpen
                        ? const Text(
                            "ХАРАКТЕРИСТИКИ   ",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          )
                        : _HeaderLocationAdaptiveText(parts: locationParts),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Якщо рядок «ЗОНА (деталь)» не вміщується в один рядок у відведеній ширині — показуємо лише зону.
class _HeaderLocationAdaptiveText extends StatelessWidget {
  const _HeaderLocationAdaptiveText({required this.parts});

  final MainGameHeaderLocationParts parts;

  static const TextStyle _style = TextStyle(fontSize: 18, color: Colors.white);

  static bool _lineFits(
    BuildContext context,
    String text,
    double maxWidth,
  ) {
    if (maxWidth <= 0 || !maxWidth.isFinite) return false;
    final tp = TextPainter(
      text: TextSpan(text: text, style: _style),
      textDirection: Directionality.of(context),
      maxLines: 1,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(maxWidth: double.infinity);
    return tp.size.width <= maxWidth;
  }

  @override
  Widget build(BuildContext context) {
    final d = parts.parenthesesDetail;
    if (d == null || d.isEmpty) {
      return Text(
        parts.zoneLabel,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.right,
        style: _style,
      );
    }
    final full = '${parts.zoneLabel} ($d)';
    return LayoutBuilder(
      builder: (context, constraints) {
        final showFull = _lineFits(context, full, constraints.maxWidth);
        return Text(
          showFull ? full : parts.zoneLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.right,
          style: _style,
        );
      },
    );
  }
}

class _MainGameBackButton extends StatelessWidget {
  const _MainGameBackButton({required this.onTap, required this.label});

  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back, color: Colors.white.withValues(alpha: 0.95), size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TimeControlBlock extends StatelessWidget {
  const _TimeControlBlock({
    required this.label,
    required this.onPlus,
    required this.onMinus,
  });

  final String label;
  final VoidCallback onPlus;
  final VoidCallback onMinus;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _MiniBtn(label: '-', onTap: onMinus),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
            ),
          ),
          _MiniBtn(label: '+', onTap: onPlus),
        ],
      ),
    );
  }
}

class _MiniBtn extends StatelessWidget {
  const _MiniBtn({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
