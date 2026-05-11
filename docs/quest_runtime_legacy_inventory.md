# Legacy Quest Inventory And Migration Map

This document is the migration source-of-truth for quest/event state currently
spread across UI flows and `GameWorldState`.

## 1) Current quest/event owners

- Primary mixed flow: `lib/screens/main_game/main_game_quest_and_zone.dart`
- World persistence: `lib/services/game_world_state.dart`
- NPC quest modules:
  - `lib/npcs/cherie/cherie_quests.dart`
  - `lib/npcs/rockefeller/rockefeller_quests.dart`
- NPC event modules:
  - `lib/npcs/sasha/sasha_events.dart`
  - `lib/npcs/danielle/danielle_events.dart`
  - `lib/npcs/sem/sem_events.dart`
  - `lib/npcs/den/den_events.dart`
  - `lib/npcs/cherie/cherie_events.dart`
  - `lib/npcs/rockefeller/rockefeller_events.dart`
  - `lib/npcs/mom/mom_events.dart`
  - `lib/npcs/elsa/elsa_events.dart`
  - `lib/npcs/piper/piper_events.dart`

## 2) Persisted quest/event state inventory (legacy)

### Cherie

- `cherie_quest_001`
  - `giftShopAnimatorJobOfferPending`
  - `lastGiftShopAnimatorDateKey`
  - `giftShopAnimatorPendingFinishDateKey`
  - `giftShopAnimatorShiftsCompleted`
  - `cherieAnimatorIntroStep`
  - `cherieAnimatorIntroTc2SlotKeyStash`
  - `cherieAnimatorIntroTc2TipsStash`
  - `cherieAnimatorWorkVideoCount`
  - `cherieAnimatorNextQuestDayCounter`
  - `cherieAnimatorNextQuestLastDateKey`
- `cherie_quest_002`
  - `cherieQuest002Step`
  - `cherieQuest002WarehouseWhoAsked`
  - `cherieQuest002SundayBlocked`
  - `cherieQuest002MassageFinishOnlyNextHallVisit`
  - `cherieQuest002MassageLegsCooldownMondays`
  - `cherieQuest002MassageCooldownMondayTickKey`
  - `cherieQuest002MassageLegsReturnPending`
  - legacy-only: `cherieQuest002EpilogueWeeksRemaining`
  - legacy-only: `cherieQuest002EpilogueTickDateKey`
- `cherie_quest_003`
  - `cherieQuest003Step`
- `cherie_quest_004`
  - `cherieQuest004Step`
  - `cherieQuest004Branch`
  - `cherieQuest004LegsMassagePhase`
- `cherie_quest_005`
  - `cherieQuest005Step`
  - `cherieQuest005Actor`
  - `cherieQuest005Lizun`
  - `cherieQuest005Step42PantsPick`
  - `cherieQuest005Complete`
- `cherie_quest_006`
  - `cherieQuest006Step`
  - `cherieQuest006Complete`
  - `cherieRelationshipNewStage`
- `cherie_event_004`
  - `cherieMassageFunEventStep`
  - `cherieMassageFunCompletions`

### Rockefeller

- `rockefeller_quest_001`
  - `rockefellerNikeOfficeStep`
  - `rockefellerNikeWorkStarted`
  - `rockefellerNikeShootingDays`
  - `rockefellerNikeShootingInProgress`
  - `rockefellerNikeFinalReviewInProgress`
  - `rockefellerNikeAdCompleted`
  - `rockefellerCherie005IncompleteAskLastDateKey`

### Danielle/Sem branch

- Spy and caught storyline (legacy event-like flow)
  - `spyOnSemParentsDone`
  - `spyOnSemParentsSpottedByDanielle`
  - `spyOnSemParentsParentsRoomPeekDone`
  - `spyOnSemParentsPlayerArousalDeltaApplied`
  - `danielleSpyCaughtConfrontationDone`

### Sasha

- `sasha_event_002` is persisted in `NPCModel.variables` (not in
  `GameWorldState`):
  - `sashaMorningRunLastDateKey`
  - `sashaMorningRunStep`
  - `sashaMorningRunTimesCompleted`
  - `sashaDebtBucks`

## 3) Mapping: legacy field -> target runtime shape

Target runtime storage model:
- `QuestStateRepository.questStep(questId)` -> `int`
- `QuestStateRepository.questFlags(questId)` -> `Map<String, dynamic>`
- `QuestStateRepository.questMeta(questId)` -> `Map<String, dynamic>`

### Mapping table

- `cherieQuest003Step`
  - target: `questStep('cherie_quest_003')`
- `cherieQuest004Step`
  - target: `questStep('cherie_quest_004')`
- `cherieQuest004Branch`
  - target: `questFlags('cherie_quest_004')['branch']`
- `cherieQuest004LegsMassagePhase`
  - target: `questFlags('cherie_quest_004')['legsMassagePhase']`
- `cherieQuest005Step`
  - target: `questStep('cherie_quest_005')`
- `cherieQuest005Actor`
  - target: `questFlags('cherie_quest_005')['actorCounter']`
- `cherieQuest005Lizun`
  - target: `questFlags('cherie_quest_005')['lizunCounter']`
- `cherieQuest005Step42PantsPick`
  - target: `questFlags('cherie_quest_005')['step42PantsPick']`
- `cherieQuest005Complete`
  - target: `questFlags('cherie_quest_005')['complete']`
- `cherieQuest006Step`
  - target: `questStep('cherie_quest_006')`
- `cherieQuest006Complete`
  - target: `questFlags('cherie_quest_006')['complete']`
- `cherieRelationshipNewStage`
  - target: `questMeta('cherie_quest_006')['relationshipNewStage']`
- `rockefellerNikeOfficeStep`
  - target: `questStep('rockefeller_quest_001')`
- `rockefellerNikeWorkStarted`
  - target: `questFlags('rockefeller_quest_001')['workStarted']`
- `rockefellerNikeShootingDays`
  - target: `questFlags('rockefeller_quest_001')['shootingDays']`
- `rockefellerNikeShootingInProgress`
  - target: `questFlags('rockefeller_quest_001')['shootingInProgress']`
- `rockefellerNikeFinalReviewInProgress`
  - target: `questFlags('rockefeller_quest_001')['finalReviewInProgress']`
- `rockefellerNikeAdCompleted`
  - target: `questFlags('rockefeller_quest_001')['adCompleted']`

## 4) Priority migration order

1. `sasha_event_002` (pilot in runtime, isolated, no Cherie dependencies)
2. `rockefeller_quest_001` (bounded state machine)
3. `cherie_quest_003` -> `cherie_quest_006`
4. `cherie_quest_002` (highest branching complexity)
5. Legacy Danielle/Sem storyline to explicit event state.

## 5) Backward compatibility rules

- Runtime loads legacy keys first if runtime key is absent.
- Runtime writes new keys, but legacy mirrors are kept until full cutover.
- Save migration is idempotent (safe on every load).
