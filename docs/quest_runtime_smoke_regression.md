# Quest Runtime Smoke Regression

Manual smoke checklist for pilot migration (`sasha_event_001`, `sasha_event_002`).

## Preconditions

- `SettingsController.useQuestRuntimeV2 = false` -> baseline legacy behavior.
- `SettingsController.questRuntimeMirrorMode = true`.
- Repeat all scenarios with `useQuestRuntimeV2 = true`.

## Scenario A: `sasha_event_001` hall communicate

1. Enter friend hall at valid hour.
2. Verify action set for intro:
   - `Підійти до Саши`
   - `Піти...`
3. Click approach, verify transition to video/talk action set.
4. Click continue, verify money-choice actions:
   - `Дать 3$ і піти`
   - `Послать і піти`
   - `грошей нема, на редбул і я пішов` (only when energy drink exists).
5. Validate side effects:
   - money decreases on give-money path;
   - inventory energy item consumed on energy-drink path;
   - autosave and exit to corridor.

## Scenario B: `sasha_event_002` morning run

1. Enter street overview at 07:00.
2. Verify intro actions:
   - `Підійти`
   - `залишити в спокої`
3. Follow full chain:
   - approach -> `ну і вали` -> pay offer.
4. In pay offer:
   - verify insufficient money dialog when money < 10;
   - verify money path sets after-paid state;
   - verify send-away path exits event.
5. Save/load mid-event and confirm step recovery and action set consistency.

## Scenario C: Mirror mode diagnostics

1. Keep `questRuntimeMirrorMode = true`.
2. Repeat A/B flows with `useQuestRuntimeV2 = false` and then `true`.
3. Confirm no `QUEST_MIRROR_MISMATCH` logs in normal transitions.

## Exit criteria

- No behavior difference between legacy and runtime mode in A/B flows.
- No stale step after save/load.
- No mirror mismatch logs for covered paths.
