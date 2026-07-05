import '../../services/npc_service.dart';

/// Ночівля в будинку кориша (гостьова кімната).
abstract final class FriendHouseOvernight {
  FriendHouseOvernight._();

  static const int minHostRelationship = 500;

  /// Після 21:00 або вночі до ранку.
  static bool isOvernightHour(int hour) => hour >= 21 || hour < 7;

  static bool bothHostsTrustGg(NPCService npcService) {
    final danielle = npcService.npcById('danielle');
    final sasha = npcService.npcById('sasha');
    if (danielle == null || sasha == null) return false;
    return danielle.relationship >= minHostRelationship &&
        sasha.relationship >= minHostRelationship;
  }

  static bool canOffer({
    required NPCService npcService,
    required int hour,
  }) =>
      isOvernightHour(hour) && bothHostsTrustGg(npcService);
}
