import 'package:flutter/foundation.dart';

import '../models/npc_model.dart';
import 'npc_interaction_types.dart';
import '../npcs/mom/mom_events.dart';
import '../npcs/danielle/danielle_events.dart';
import '../npcs/elsa/elsa_events.dart';
import '../npcs/piper/piper_events.dart';
import '../npcs/rockefeller/rockefeller_events.dart';

export 'npc_interaction_types.dart';

/// Слот «Флірт» — зʼявляється тільки при відношенні >= 500 (для всіх NPC).
final List<NpcInteractionSlot> _flirtSlots = [
  NpcInteractionSlot(
    npcId: null,
    location: '',
    hourStart: 0,
    hourEnd: 24,
    minRelationship: 500,
    actions: [flirtActionTemplate],
    excludeFromMaleMinimalMenu: true,
  ),
];

/// Усі слоти взаємодій: злиті з файлів івентів кожного NPC + умовні (Флірт).
final List<NpcInteractionSlot> interactionSlots = [
  ...momInteractionSlots,
  ...danielleInteractionSlots,
  ...elsaInteractionSlots,
  ...piperInteractionSlots,
  ...rockefellerInteractionSlots,
  ..._flirtSlots,
];

/// Збирає список [NPCAction]: спочатку базовий слот (без умов по статах), потім усі івент-слоти, що проходять умови (minRelationship, oneTimeVar тощо).
List<NPCAction> buildActionsFromTemplate(
  NPCModel npc,
  String location,
  int hour,
  VoidCallback onUpdate,
) {
  final list = <NPCAction>[];
  bool baseAdded = false;
  for (final slot in interactionSlots) {
    if (!slot.matches(location, hour, npc.id)) continue;
    if (!slot.isEventSlot) {
      if (!baseAdded) {
        for (final t in slot.actions) {
          list.add(
            _actionFromTemplate(
              npc,
              t,
              onUpdate,
              oneTimeVar: null,
              allowExtraActionForMaleNpc: false,
            ),
          );
        }
        baseAdded = true;
      }
      continue;
    }
    if (!slot.matches(location, hour, npc.id, npc)) continue;
    final maleExtra = !slot.excludeFromMaleMinimalMenu;
    for (final t in slot.actions) {
      list.add(
        _actionFromTemplate(
          npc,
          t,
          onUpdate,
          oneTimeVar: slot.oneTimeVar,
          allowExtraActionForMaleNpc: maleExtra,
        ),
      );
    }
  }
  return list;
}

/// Лише івент-слоти (без базових «Поговорити» / «Комплімент» тощо).
/// Для Cherie в Office Cherie — поки немає слотів у `interactionSlots`, список порожній (окрім глобальних на кшталт «Флірт» за умов).
List<NPCAction> buildEventSlotActionsOnly(
  NPCModel npc,
  String location,
  int hour,
  VoidCallback onUpdate,
) {
  final list = <NPCAction>[];
  for (final slot in interactionSlots) {
    if (!slot.isEventSlot) continue;
    if (!slot.matches(location, hour, npc.id)) continue;
    if (!slot.matches(location, hour, npc.id, npc)) continue;
    final maleExtra = !slot.excludeFromMaleMinimalMenu;
    for (final t in slot.actions) {
      list.add(
        _actionFromTemplate(
          npc,
          t,
          onUpdate,
          oneTimeVar: slot.oneTimeVar,
          allowExtraActionForMaleNpc: maleExtra,
        ),
      );
    }
  }
  return list;
}

/// Будує стандартний набір дій (defaultInteractionActions) для будь‑якого NPC.
List<NPCAction> buildDefaultActions(NPCModel npc, VoidCallback onUpdate) {
  final list = <NPCAction>[];
  for (final t in defaultInteractionActions) {
    list.add(
      _actionFromTemplate(
        npc,
        t,
        onUpdate,
        oneTimeVar: null,
        allowExtraActionForMaleNpc: false,
      ),
    );
  }
  return list;
}

NPCAction _actionFromTemplate(
  NPCModel npc,
  NpcActionTemplate t,
  VoidCallback onUpdate, {
  String? oneTimeVar,
  bool allowExtraActionForMaleNpc = false,
}) {
  return NPCAction(
    label: t.label,
    allowExtraActionForMaleNpc: allowExtraActionForMaleNpc,
    onExecute: () {
      final rel = npc.relationship;
      final useThreshold = t.relThreshold;
      final relThresholdForRel = t.relThresholdForRelationship ?? useThreshold;
      final applyStatChanges = npc.gender != NpcGender.male;

      if (applyStatChanges) {
        if (t.lustIfLow != null && t.lustIfHigh != null) {
          if (rel < useThreshold) {
            npc.changeLust(t.lustIfLow!);
          } else {
            npc.changeLust(t.lustIfHigh!);
          }
        } else {
          npc.changeLust(t.lust);
        }

        if (t.relIfLow != null && t.relIfHigh != null) {
          if (rel < relThresholdForRel) {
            npc.addRelationship(t.relIfLow!);
          } else {
            npc.addRelationship(t.relIfHigh!);
          }
        } else {
          npc.addRelationship(t.relationship);
        }

        if (t.behIfLow != null && t.behIfHigh != null) {
          if (rel < useThreshold) {
            npc.changeBehavior(t.behIfLow!);
          } else {
            npc.changeBehavior(t.behIfHigh!);
          }
        } else {
          npc.changeBehavior(t.behavior);
        }

        if (t.influenceDelta != null) {
          npc.changeInfluence(t.influenceDelta!);
        }
      }

      if (oneTimeVar != null) {
        npc.setVar(oneTimeVar, true);
      }

      if (t.setVarOnExecute != null) {
        for (final e in t.setVarOnExecute!.entries) {
          npc.setVar(e.key, e.value);
        }
      }

      onUpdate();
    },
  );
}
