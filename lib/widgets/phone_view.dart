import 'dart:async';
import 'package:flutter/material.dart';
import '../models/npc_model.dart';
import '../services/npc_service.dart';
import '../services/service_locator.dart';
import '../services/game_time_controller.dart';
import '../data/locations_room_data.dart';
import '../theme/game_theme.dart';

/// Телефон зі списком контактів: аватар (тап = статистика NPC), місце знаходження, подзвонити/SMS.
class PhoneView extends StatefulWidget {
  final VoidCallback onClose;
  final GameTimeController timeController;

  const PhoneView({
    super.key,
    required this.onClose,
    required this.timeController,
  });

  @override
  State<PhoneView> createState() => _PhoneViewState();
}

class _PhoneViewState extends State<PhoneView> {
  String? _bottomMessage;
  Timer? _messageTimer;

  void _showPhoneMessage(String text) {
    _messageTimer?.cancel();
    setState(() => _bottomMessage = text);
    _messageTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _bottomMessage = null);
    });
  }

  /// Контакти для відображення: перші 3 за замовчуванням, решта — після першого контакту.
  static List<NPCModel> getVisibleContacts(NPCService npcService) {
    final list = <NPCModel>[];
    for (final id in NPCService.defaultContactIds) {
      try {
        final npc = npcService.allNPCs.firstWhere((n) => n.id == id);
        list.add(npc);
      } catch (_) {}
    }
    for (final npc in npcService.allNPCs) {
      if (NPCService.defaultContactIds.contains(npc.id)) continue;
      if (npc.variables['phone_unlocked'] == true) list.add(npc);
    }
    return list;
  }

  static String _roleForContact(String npcId) {
    switch (npcId) {
      case 'mom':
        return 'Мама';
      case 'yong_sister':
        return 'Сестра';
      case 'rita':
        return 'Сестра';
      default:
        return 'Контакт';
    }
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final npcService = sl<NPCService>();
    final contacts = getVisibleContacts(npcService);
    final hour = widget.timeController.dateTime.hour;
    final day = widget.timeController.weekdayIndex;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 320,
          constraints: BoxConstraints(
            minHeight: 580,
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.grey, width: 1),
            boxShadow: [
              BoxShadow(color: Colors.black54, blurRadius: 20, spreadRadius: 2),
            ],
          ),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Верхня панель (notch)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${widget.timeController.dateTime.hour.toString().padLeft(2, '0')}:${widget.timeController.dateTime.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const Icon(Icons.signal_cellular_4_bar, color: Colors.white54, size: 18),
                        const Icon(Icons.battery_full, color: Colors.white54, size: 18),
                      ],
                    ),
                  ),
                  // Заголовок
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Контакти',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70),
                          onPressed: widget.onClose,
                        ),
                      ],
                    ),
                  ),
                  // Список контактів
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        final npc = contacts[index];
                        final locationId = npcService.getCurrentLocationId(npc, hour, day);
                        final locationText = locationId != null
                            ? LocationsData.getGeneralLocationName(locationId)
                            : '(невідомо)';
                        return _ContactCard(
                          npc: npc,
                          role: _roleForContact(npc.id),
                          locationText: locationText,
                          onAvatarTap: () => _showNpcStats(context, npc),
                          onCall: () => _showPhoneMessage('Дзвінок ${npc.name}...'),
                          onSms: () => _showPhoneMessage('SMS для ${npc.name}...'),
                        );
                      },
                    ),
                  ),
                ],
              ),
              // Полоска повідомлення приклеєна до нижнього краю телефону
              if (_bottomMessage != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Material(
                    color: Colors.grey.shade800,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, size: 20, color: Colors.grey.shade300),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _bottomMessage!,
                                style: TextStyle(color: Colors.grey.shade200, fontSize: 14),
                                overflow: TextOverflow.ellipsis,
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
        ),
      ),
    );
  }

  void _showNpcStats(BuildContext context, NPCModel npc) {
    final role = _roleForContact(npc.id);
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: _NpcStatsDialog(npc: npc, role: role),
      ),
    );
  }

}

/// Діалог картки NPC: аватар зліва, стати з +/- справа (як у картки ГГ).
class _NpcStatsDialog extends StatefulWidget {
  final NPCModel npc;
  final String role;

  const _NpcStatsDialog({required this.npc, required this.role});

  @override
  State<_NpcStatsDialog> createState() => _NpcStatsDialogState();
}

class _NpcStatsDialogState extends State<_NpcStatsDialog> {
  static const double _labelWidth = 130.0;
  static const double _buttonColumnWidth = 44.0;
  static const double _gapBetweenColumns = 16.0;

  @override
  Widget build(BuildContext context) {
    final npc = widget.npc;
    final role = widget.role;
    final avatarPath = _avatarPathForNpc(npc);

    return Container(
      constraints: BoxConstraints(
        maxWidth: 680,
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: BoxDecoration(
        color: GameTheme.bgDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 20, right: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  role,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 400,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: avatarPath != null
                            ? Image.asset(
                                avatarPath,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _avatarPlaceholder(),
                              )
                            : _avatarPlaceholder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatRowWithButtons(
                            'Хтивість',
                            '${npc.lust} / 1000',
                            tier: _lustTierLabel(npc.lust),
                            onMinus: () => _change(() => npc.changeLust(-25)),
                            onPlus: () => _change(() => npc.changeLust(25)),
                          ),
                          _buildStatRowWithButtons(
                            'Відношення',
                            '${npc.relationship} / 1000',
                            tier: _relationTierLabel(npc.relationship),
                            onMinus: () => _change(() { npc.changeTrust(-2); npc.changeLove(-2); }),
                            onPlus: () => _change(() { npc.changeTrust(2); npc.changeLove(2); }),
                          ),
                          _buildStatRowWithButtons(
                            'Поведінка',
                            '${npc.behavior} / 1000',
                            tier: _behaviorTierLabel(npc.behavior),
                            onMinus: () => _change(() => npc.changeBehavior(-25)),
                            onPlus: () => _change(() => npc.changeBehavior(25)),
                          ),
                          _buildStatRowWithButtons(
                            'Збудження',
                            '${npc.arousal} / 100',
                            onMinus: () => _change(() => npc.changeArousal(-10)),
                            onPlus: () => _change(() => npc.changeArousal(10)),
                          ),
                          _buildStatRowWithButtons(
                            'Вплив гг',
                            '${npc.influenceFromGg} / 1000',
                            onMinus: () => _change(() => npc.changeTrust(-1)),
                            onPlus: () => _change(() => npc.changeTrust(1)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: GameTheme.cardDecoration(),
            child: Text(
              '${npc.fullName}, ${npc.age} років',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
            ),
          ),
        ],
      ),
    );
  }

  String? _avatarPathForNpc(NPCModel npc) {
    if (npc.avatarPath != null && npc.avatarPath!.isNotEmpty) return npc.avatarPath;
    for (final p in npc.schedule) {
      if (p.spritePath.endsWith('.jpg') || p.spritePath.endsWith('.png')) return p.spritePath;
    }
    return null;
  }

  Widget _avatarPlaceholder() {
    return Container(
      color: GameTheme.mainGrey.withOpacity(0.5),
      child: const Center(
        child: Icon(Icons.person, size: 120, color: Colors.white24),
      ),
    );
  }

  void _change(VoidCallback action) {
    action();
    setState(() {});
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: _labelWidth,
            child: Text('$label:', style: const TextStyle(fontSize: 16, color: Colors.white70)),
          ),
          const SizedBox(width: _gapBetweenColumns),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRowWithButtons(
    String label,
    String value, {
    String? tier,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              SizedBox(
                width: _labelWidth,
                child: Text('$label:', style: const TextStyle(fontSize: 16, color: Colors.white70)),
              ),
              const SizedBox(width: _gapBetweenColumns),
              SizedBox(width: _buttonColumnWidth, child: _miniBtn('-', onMinus)),
              const SizedBox(width: _gapBetweenColumns),
              Expanded(
                child: Center(
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: _gapBetweenColumns),
              SizedBox(width: _buttonColumnWidth, child: _miniBtn('+', onPlus)),
            ],
          ),
          if (tier != null)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 2),
              child: Text('· $tier', style: const TextStyle(fontSize: 14, color: Colors.white54)),
            ),
        ],
      ),
    );
  }

  Widget _miniBtn(String label, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white24),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  static String _lustTierLabel(int v) {
    if (v < 100) return 'Скромна';
    if (v < 200) return 'Звичайна';
    if (v < 300) return 'Розкріпачена';
    if (v < 400) return 'Без комплексів';
    if (v < 500) return 'Розпущена';
    if (v < 600) return 'Розпущена';
    if (v < 800) return 'Розбещена';
    return 'Вавилонська блудниця';
  }

  static String _relationTierLabel(int v) {
    if (v < 100) return 'Ненавидить';
    if (v < 200) return 'Негативне';
    if (v < 300) return 'Недолюблює';
    if (v < 400) return 'Нейтральне';
    if (v < 500) return 'Доброзичливе';
    if (v < 600) return 'Доброзичливе';
    if (v < 800) return 'Завжди готова допомогти';
    return 'Готова на все';
  }

  static String _behaviorTierLabel(int v) {
    if (v < 100) return 'Високомірна';
    if (v < 250) return 'Вперта';
    if (v < 400) return 'Нормальна';
    if (v < 600) return 'Поступлива';
    if (v < 800) return 'Залежна';
    return 'Покірна';
  }
}

class _ContactCard extends StatefulWidget {
  final NPCModel npc;
  final String role;
  final String locationText;
  final VoidCallback onAvatarTap;
  final VoidCallback onCall;
  final VoidCallback onSms;

  const _ContactCard({
    required this.npc,
    required this.role,
    required this.locationText,
    required this.onAvatarTap,
    required this.onCall,
    required this.onSms,
  });

  @override
  State<_ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<_ContactCard> {
  bool _menuExpanded = false;

  static String? _avatarPathFor(NPCModel npc) {
    if (npc.avatarPath != null && npc.avatarPath!.isNotEmpty) return npc.avatarPath;
    for (final p in npc.schedule) {
      if (p.spritePath.endsWith('.jpg') || p.spritePath.endsWith('.png')) return p.spritePath;
    }
    return null;
  }

  Widget _contactAvatar(NPCModel npc) {
    final path = _avatarPathFor(npc);
    const size = 56.0;
    if (path != null) {
      return ClipOval(
        child: SizedBox(
          width: size,
          height: size,
          child: Image.asset(
            path,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _avatarPlaceholder(size),
          ),
        ),
      );
    }
    return _avatarPlaceholder(size);
  }

  Widget _avatarPlaceholder(double size) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: GameTheme.bgDark.withOpacity(0.3),
      child: Icon(Icons.person, size: size * 0.6, color: GameTheme.bgDark),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: GameTheme.mainGrey.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: widget.onAvatarTap,
                  child: _contactAvatar(widget.npc),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.npc.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.role,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.locationText,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade900,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.black54,
                  ),
                  onPressed: () => setState(() => _menuExpanded = !_menuExpanded),
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: _menuExpanded
                ? Material(
                    color: GameTheme.bgDark.withOpacity(0.5),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final half = constraints.maxWidth / 2;
                          final callWidth = half + 10;
                          final smsWidth = half - 10;
                          return Row(
                            children: [
                              SizedBox(
                                width: callWidth,
                                child: TextButton.icon(
                                  onPressed: () {
                                    setState(() => _menuExpanded = false);
                                    widget.onCall();
                                  },
                                  icon: const Icon(Icons.call, color: Colors.green, size: 20),
                                  label: const Text('Подзвонити', style: TextStyle(color: Colors.white)),
                                ),
                              ),
                              SizedBox(
                                width: smsWidth,
                                child: TextButton.icon(
                                  onPressed: () {
                                    setState(() => _menuExpanded = false);
                                    widget.onSms();
                                  },
                                  icon: const Icon(Icons.message, color: Colors.blue, size: 20),
                                  label: const Text('SMS', style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
