import 'dart:async';
import 'package:flutter/material.dart';
import '../models/npc_model.dart';
import '../services/npc_service.dart';
import '../services/game_world_state.dart';
import '../services/npc_finance_service.dart';
import '../services/service_locator.dart';
import '../services/game_time_controller.dart';
import '../data/locations_room_data.dart';
import '../theme/game_theme.dart';
import '../services/locale_controller.dart';
import '../data/npc_profile_display.dart';
import '../models/npc_secondary.dart';
import '../utils/npc_portrait_paths.dart';
import 'npc_circle_avatar_image.dart';
import 'npc_profile_owes_alex_row.dart';
import 'lesson_video_screen.dart';
import 'phone_compromat_gallery_data.dart';

enum _PhoneScreen { home, contacts, gallery, video }

/// Телефон: робочий стіл, контакти, галерея компромату.
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
  static const double _phoneOuterRadius = 40;
  static const double _contentInset = 12;
  static const double _phoneInnerRadius = _phoneOuterRadius - _contentInset;

  String? _bottomMessage;
  Timer? _messageTimer;
  _PhoneScreen _screen = _PhoneScreen.home;
  String? _galleryVideoPath;

  void _openContacts() => setState(() => _screen = _PhoneScreen.contacts);

  void _openGallery() => setState(() => _screen = _PhoneScreen.gallery);

  void _goHome() => setState(() {
        _screen = _PhoneScreen.home;
        _galleryVideoPath = null;
      });

  void _openGalleryVideo(String path) => setState(() {
        _galleryVideoPath = path;
        _screen = _PhoneScreen.video;
      });

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
      case 'elsa':
        return 'Сестра';
      case 'piper':
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
    final screenHeight = MediaQuery.of(context).size.height;
    final phoneMaxHeight = screenHeight * 0.75;
    final phoneHeight = phoneMaxHeight.clamp(520.0, 680.0);
    final messageBarHeight = _bottomMessage != null ? 52.0 : 0.0;
    final t = sl<LocaleController>().t;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 360,
          height: phoneHeight,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(_phoneOuterRadius),
            border: Border.all(color: Colors.grey, width: 1),
            boxShadow: [
              BoxShadow(color: Colors.black54, blurRadius: 20, spreadRadius: 2),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildStatusBar(),
                  if (_screen == _PhoneScreen.home)
                    _buildHomeHeader()
                  else if (_screen != _PhoneScreen.video)
                    _buildSubScreenHeader(
                      title: _screen == _PhoneScreen.contacts
                          ? t('phone_home_contacts')
                          : t('phone_home_gallery'),
                    ),
                  Expanded(
                    child: switch (_screen) {
                      _PhoneScreen.home => _buildHomeScreen(messageBarHeight),
                      _PhoneScreen.contacts => _buildContactsScreen(
                          npcService: npcService,
                          contacts: contacts,
                          hour: hour,
                          day: day,
                          messageBarHeight: messageBarHeight,
                        ),
                      _PhoneScreen.gallery => _buildGalleryScreen(
                          messageBarHeight: messageBarHeight,
                        ),
                      _PhoneScreen.video => _buildGalleryVideoScreen(
                          messageBarHeight: messageBarHeight,
                        ),
                    },
                  ),
                ],
              ),
              if (_bottomMessage != null) _buildMessageBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
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
    );
  }

  Widget _buildHomeHeader() {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            onPressed: widget.onClose,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ],
      ),
    );
  }

  Widget _buildSubScreenHeader({required String title}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white70),
            onPressed: _goHome,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            onPressed: widget.onClose,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeScreen(double messageBarHeight) {
    final t = sl<LocaleController>().t;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        _contentInset,
        0,
        _contentInset,
        _contentInset + messageBarHeight,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_phoneInnerRadius),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'lib/assets/left_panel/wallper.webp',
              fit: BoxFit.cover,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.35),
                  ],
                  stops: const [0.45, 1.0],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 36, left: 28, right: 28),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _PhoneHomeApp(
                      icon: Icons.contacts,
                      iconColor: GameTheme.bgDark,
                      label: t('phone_home_contacts'),
                      onTap: _openContacts,
                    ),
                    _PhoneHomeApp(
                      icon: Icons.video_library,
                      iconColor: GameTheme.bgDark,
                      label: t('phone_home_gallery'),
                      onTap: _openGallery,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactsScreen({
    required NPCService npcService,
    required List<NPCModel> contacts,
    required int hour,
    required int day,
    required double messageBarHeight,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        _contentInset,
        0,
        _contentInset,
        _contentInset + messageBarHeight,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_phoneInnerRadius),
        clipBehavior: Clip.antiAlias,
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: _contentInset),
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            final npc = contacts[index];
            final locationId = npcService.getCurrentLocationId(npc, hour, day);
            final locationText = locationId != null
                ? LocationsData.getGeneralLocationName(locationId)
                : '(невідомо)';
            final portraitPath = npcPhoneContactPortraitPath(
              npc,
              npcService,
              hour,
              day,
            );
            return _ContactCard(
              npc: npc,
              portraitPath: portraitPath,
              role: _roleForContact(npc.id),
              locationText: locationText,
              onAvatarTap: () => _showNpcStats(
                context,
                npc,
                npcService,
                hour,
                day,
              ),
              onCall: () => _showPhoneMessage('Дзвінок ${npc.name}...'),
              onSms: () => _showPhoneMessage('SMS для ${npc.name}...'),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGalleryScreen({required double messageBarHeight}) {
    final t = sl<LocaleController>().t;
    final entries = getPhoneCompromatGalleryEntries();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        _contentInset,
        0,
        _contentInset,
        _contentInset + messageBarHeight,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_phoneInnerRadius),
        clipBehavior: Clip.antiAlias,
        child: entries.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    t('phone_gallery_empty'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 15,
                    ),
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, _contentInset),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == entries.length - 1 ? 0 : 10,
                    ),
                    child: _PhoneGalleryTile(
                      label: entry.label,
                      onTap: () => _openGalleryVideo(entry.videoPath),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildGalleryVideoScreen({required double messageBarHeight}) {
    final path = _galleryVideoPath;
    if (path == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        _contentInset,
        0,
        _contentInset,
        _contentInset + messageBarHeight,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_phoneInnerRadius),
        clipBehavior: Clip.antiAlias,
        child: EmbeddedLessonVideo(
          videoPath: path,
          onCompleted: () {},
          onClose: (_) => setState(() => _screen = _PhoneScreen.gallery),
        ),
      ),
    );
  }

  Widget _buildMessageBar() {
    return Positioned(
      left: _contentInset,
      right: _contentInset,
      bottom: _contentInset,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(_phoneInnerRadius),
          bottomRight: Radius.circular(_phoneInnerRadius),
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.grey.shade800,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
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
    );
  }

  void _showNpcStats(
    BuildContext context,
    NPCModel npc,
    NPCService npcService,
    int hour,
    int weekday,
  ) {
    final role = _roleForContact(npc.id);
    final portraitPath = npcPhoneContactPortraitPath(npc, npcService, hour, weekday);
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 9, vertical: 32),
        child: _NpcStatsDialog(npc: npc, role: role, portraitPath: portraitPath),
      ),
    );
  }

}

/// Діалог картки NPC: аватар зліва, стати з +/- справа (як у картки ГГ).
class _NpcStatsDialog extends StatefulWidget {
  final NPCModel npc;
  final String role;
  final String? portraitPath;

  const _NpcStatsDialog({
    required this.npc,
    required this.role,
    required this.portraitPath,
  });

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
    final avatarPath = widget.portraitPath;

    return Container(
      constraints: BoxConstraints(
        maxWidth: 700,
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
                          if (isSecondaryNpc(npc))
                            const Padding(
                              padding: EdgeInsets.only(top: 24),
                              child: Text(
                                'Категорія: другорядний персонаж. Стати не ведуться.',
                                style: TextStyle(color: Colors.white54, fontSize: 15, height: 1.35),
                              ),
                            )
                          else if (isRelationshipInfluenceOnlyNpc(npc)) ...[
                            const Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: Text(
                                'Категорія: чоловічий персонаж. У статах лише відносини та вплив ГГ.',
                                style: TextStyle(color: Colors.white54, fontSize: 14, height: 1.35),
                              ),
                            ),
                            _buildStatRowWithButtons(
                              'Відносини',
                              '${npc.relationship.round()} / 1000',
                              tier: _relationTierLabel(npc.relationship.round()),
                              onMinus: () => _change(() {
                                npc.changeTrust(-2);
                                npc.changeLove(-2);
                              }),
                              onPlus: () => _change(() {
                                npc.changeTrust(2);
                                npc.changeLove(2);
                              }),
                            ),
                            _buildStatRowWithButtons(
                              'Гроші',
                              '\$${npc.money}',
                              onMinus: () => _change(() => npc.changeMoney(-100)),
                              onPlus: () => _change(() => npc.changeMoney(100)),
                            ),
                            _buildStatRowWithButtons(
                              'Вплив ГГ',
                              '${npc.influenceFromGg} / 100',
                              onMinus: () => _change(() => npc.changeInfluence(-1)),
                              onPlus: () => _change(() => npc.changeInfluence(1)),
                            ),
                            _buildOwesAlexRows(npc),
                            _buildStatRowReadOnly(
                              sl<LocaleController>().t('npc_card_debt_gg_owes_npc'),
                              '\$${NpcFinanceService.ggOwesNpc(sl<GameWorldState>(), npc.id)}',
                            ),
                          ]
                          else ...[
                            _buildStatRowWithButtons(
                              'Хтивість',
                              '${npc.lust.round()} / 1000',
                              tier: _lustTierLabel(npc.lust.round()),
                              onMinus: () => _change(() => npc.changeLust(-25)),
                              onPlus: () => _change(() => npc.changeLust(25)),
                            ),
                            _buildStatRowWithButtons(
                              'Відносини',
                              '${npc.relationship.round()} / 1000',
                              tier: _relationTierLabel(npc.relationship.round()),
                              onMinus: () => _change(() {
                                npc.changeTrust(-2);
                                npc.changeLove(-2);
                              }),
                              onPlus: () => _change(() {
                                npc.changeTrust(2);
                                npc.changeLove(2);
                              }),
                            ),
                            _buildStatRowWithButtons(
                              'Поведінка',
                              '${npc.behavior.round()} / 1000',
                              tier: _behaviorTierLabel(npc.behavior.round()),
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
                              'Гроші',
                              '\$${npc.money}',
                              onMinus: () => _change(() => npc.changeMoney(-100)),
                              onPlus: () => _change(() => npc.changeMoney(100)),
                            ),
                            _buildStatRowWithButtons(
                              'Вплив ГГ',
                              '${npc.influenceFromGg} / 100',
                              onMinus: () => _change(() => npc.changeInfluence(-1)),
                              onPlus: () => _change(() => npc.changeInfluence(1)),
                            ),
                            _buildOwesAlexRows(npc),
                            _buildStatRowReadOnly(
                              sl<LocaleController>().t('npc_card_debt_gg_owes_npc'),
                              '\$${NpcFinanceService.ggOwesNpc(sl<GameWorldState>(), npc.id)}',
                            ),
                          ],
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
              '${NpcProfileDisplay.cardTitleLine(npc, world: sl<GameWorldState>())}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarPlaceholder() {
    return Container(
      color: GameTheme.mainGrey.withValues(alpha: 0.5),
      child: const Center(
        child: Icon(Icons.person, size: 120, color: Colors.white24),
      ),
    );
  }

  void _change(VoidCallback action) {
    action();
    setState(() {});
  }

  Widget _buildOwesAlexRows(NPCModel npc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: NpcProfileOwesAlexRow(
        gameWorld: sl<GameWorldState>(),
        npc: npc,
        fontSize: 16,
      ),
    );
  }

  Widget _buildStatRowReadOnly(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: _labelWidth,
            child: Text('$label:', style: const TextStyle(fontSize: 16, color: Colors.white70)),
          ),
          const SizedBox(width: _gapBetweenColumns),
          SizedBox(width: _buttonColumnWidth, child: const SizedBox.shrink()),
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
          SizedBox(width: _buttonColumnWidth, child: const SizedBox.shrink()),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _labelWidth,
            child: Text('$label:', style: const TextStyle(fontSize: 16, color: Colors.white70)),
          ),
          const SizedBox(width: _gapBetweenColumns),
          SizedBox(width: _buttonColumnWidth, child: _miniBtn('-', onMinus)),
          const SizedBox(width: _gapBetweenColumns),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
                if (tier != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      tier,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: Colors.white54),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: _gapBetweenColumns),
          SizedBox(width: _buttonColumnWidth, child: _miniBtn('+', onPlus)),
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

class _PhoneHomeApp extends StatelessWidget {
  const _PhoneHomeApp({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: 32, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              shadows: [
                Shadow(color: Colors.black54, blurRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhoneGalleryTile extends StatelessWidget {
  const _PhoneGalleryTile({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: GameTheme.mainGrey.withValues(alpha: 0.95),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.play_circle_filled,
                  size: 28, color: GameTheme.bgDark.withValues(alpha: 0.85)),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactCard extends StatefulWidget {
  final NPCModel npc;
  final String? portraitPath;
  final String role;
  final String locationText;
  final VoidCallback onAvatarTap;
  final VoidCallback onCall;
  final VoidCallback onSms;

  const _ContactCard({
    required this.npc,
    required this.portraitPath,
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

  Widget _contactAvatar(NPCModel npc) {
    final path = widget.portraitPath;
    const size = 56.0;
    if (path != null) {
      return NpcCircleAvatarImage(
        size: size,
        imagePath: path,
        errorBuilder: (_, __, ___) => _avatarPlaceholder(size),
      );
    }
    return _avatarPlaceholder(size);
  }

  Widget _avatarPlaceholder(double size) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: GameTheme.bgDark.withValues(alpha: 0.3),
      child: Icon(Icons.person, size: size * 0.6, color: GameTheme.bgDark),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: GameTheme.mainGrey.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
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
                    color: GameTheme.bgDark.withValues(alpha: 0.5),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final t = sl<LocaleController>().t;
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
                                  label: Text(t('phone_call'), style: const TextStyle(color: Colors.white)),
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
                                  label: Text(t('phone_sms'), style: const TextStyle(color: Colors.white)),
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
