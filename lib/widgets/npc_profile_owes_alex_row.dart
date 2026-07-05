import 'package:flutter/material.dart';

import '../data/npc_profile_display.dart';
import '../models/npc_model.dart';
import '../services/game_world_state.dart';
import '../services/locale_controller.dart';
import '../services/service_locator.dart';

/// Рядок боргу: «Винна Алексу:» ·15px· «Грошей:» **$N** ·15px· «Послуг:» **N**.
class NpcProfileOwesAlexRow extends StatelessWidget {
  const NpcProfileOwesAlexRow({
    super.key,
    required this.npc,
    this.gameWorld,
    this.fontSize = 14,
  });

  static const double segmentGap = 25;

  final NPCModel npc;
  final GameWorldState? gameWorld;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final t = sl<LocaleController>().t;
    final money = NpcProfileDisplay.owesAlexMoney(gameWorld, npc.id);
    final service = NpcProfileDisplay.owesAlexService(gameWorld, npc);
    final baseStyle = TextStyle(
      color: Colors.white70,
      fontSize: fontSize,
      height: 1.35,
    );
    final amountStyle = baseStyle.copyWith(
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text('${t('npc_card_owes_alex')}:', style: baseStyle),
        const SizedBox(width: segmentGap),
        Text('${t('npc_card_owes_alex_money')}:', style: baseStyle),
        Text('\$$money', style: amountStyle),
        const SizedBox(width: segmentGap),
        Text('${t('npc_card_owes_alex_service')}:', style: baseStyle),
        Text('$service', style: amountStyle),
      ],
    );
  }
}
