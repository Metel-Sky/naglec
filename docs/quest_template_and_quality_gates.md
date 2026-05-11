# Quest Template And Quality Gates

This is the canonical template for any new NPC quest/event.

## A) Content spec template (mandatory)

Use this block in task/spec docs before implementation:

```text
- QUEST: <npc>_quest_00N
  NPC: <npc_id>
  Version: 1

  - Step 1
    Place: <location_room_id>
    Start trigger: <button/action>
    Entry conditions: <conditions>
    Action panel buttons: <list>
    Entry video: <asset path or 'без відео'>
    Entry dialogue key: <l10n_uk_key>
    Exit rules: <where transition goes>
```

Mandatory:
- no raw RU text in UI;
- only l10n keys;
- quest buttons only in action panel;
- explicit abort behavior.

## B) Code template (mandatory)

Location:
- `lib/npcs/<npc>/<npc>_quests.dart`

Minimum skeleton:

```dart
/// QUEST: <npc>_quest_00N
abstract final class <Npc>Quest00N {
  static const String questId = '<npc>_quest_00N';
}
```

For events:
- `lib/npcs/<npc>/<npc>_events.dart`
- include marker `// EVENT: <npc>_event_00N`.

## C) Runtime integration template

- register `QuestDefinition` in runtime registry;
- use `QuestStateRepository` for persisted step/flags/counters;
- side effects through `QuestEffectRunner`;
- action panel consumes runtime actions, no quest-specific giant if in UI.

## D) Quality gates (script)

Run:

```bash
dart run tool/validate_quest_quality_gates.dart
```

The script checks:
- no `BuildContext` in `*_quests.dart` / `*_events.dart`;
- each `*_quests.dart` has quest marker and `questId`;
- each `*_events.dart` has event marker (or allowlisted legacy file).
