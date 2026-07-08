import '../data/locations_room_data.dart';
import '../data/npc_finance_state.dart';
import '../npcs/piper/piper_quests.dart';
import 'game_time_controller.dart';

class GameWorldState {
  /// Поточна глобальна зона (HOME, CITY, COLLEGE, etc.)
  String currentZone;

  /// Id кімнати (English key: corridor, kitchen, college_hall, etc.)
  String currentRoom;

  /// Чи знаходиться гг всередині кімнати
  bool isInsideRoom;

  /// На вулиці: id будинку (friend_house, aunt_house, …), null = на вулиці, не в будинку
  String? currentStreetHouse;

  /// Кімнати, де встановлено приховані камери (mom_room, piper_room, elsa_room)
  List<String> installedSpyCameraRooms = [];

  /// Після підтвердження вакансії «Роздавати флаєри» в ноутбуці — у місті показувати пропозицію піти роздавати флаєри
  bool flyersJobOfferPending = false;

  /// Дата останнього роздавання флаєрів (ключ "yyyy-MM-dd") — один раз на добу
  String? lastFlyersDateKey;

  /// Після підтвердження вакансії «Підсобник на будівництві» — у місті показувати пропозицію піти працювати
  bool constructionJobOfferPending = false;

  /// Дата останньої роботи на будівництві (ключ "yyyy-MM-dd") — один раз на добу
  String? lastConstructionDateKey;

  /// Після підтвердження вакансії «Менеджер в колл-центр» — у колл-центрі показувати пропозицію піти працювати
  bool callCenterJobOfferPending = false;

  /// Дата останньої роботи в колл-центрі (ключ "yyyy-MM-dd") — один раз на добу
  String? lastCallCenterDateKey;

  /// Після згоди з Cherie в офісі (квест аніматора) — у залі магазину подарунків ТРЦ доступна зміна.
  bool giftShopAnimatorJobOfferPending = false;

  /// Останній слот зміни аніматора ([CherieQuest001.giftShopAnimatorShiftSlotKey]) або легасі "y-m-d".
  String? lastGiftShopAnimatorDateKey;

  /// Після «Працювати» — очікується «Закінчити» ([giftShopAnimatorShiftSlotKey] або легасі "y-m-d").
  String? giftShopAnimatorPendingFinishDateKey;

  /// Скільки разів ГГ **завершив** зміну аніматора (кнопка «Закінчити» після роботи).
  int giftShopAnimatorShiftsCompleted = 0;

  /// Інтро першої зміни аніматора: 0 — немає; 1…4 — кроки; 5 — tc_2 + діалог до «Піти».
  int cherieAnimatorIntroStep = 0;

  /// Крок 5 інтро: слот і чайові для нагороди ([GameUiStateController] не в сейві).
  String? cherieAnimatorIntroTc2SlotKeyStash;
  int? cherieAnimatorIntroTc2TipsStash;

  /// Скільки разів переглянуто робоче відео аніматора (+1 після кожного показу).
  int cherieAnimatorWorkVideoCount = 0;

  /// Дні (ігровий календар) після згоди на квест Cherie-аніматор, 0…5 — умова для наступного квесту.
  int cherieAnimatorNextQuestDayCounter = 0;

  /// Останній ігровий день, для якого зафіксовано лічильник (ключ "yyyy-M-d").
  String? cherieAnimatorNextQuestLastDateKey;

  // --- Cherie квест 002 (склад / коробки), офіс вихідні ---
  /// 0 — не стартовано; 1…4 офіс/склад; 5…9 зал Home Cherie.
  int cherieQuest002Step = 0;

  /// Квест 002 крок 4: натиснуто «А ти хто така?» — альтернативний текст у діалозі.
  bool cherieQuest002WarehouseWhoAsked = false;

  /// Легасі сейвів: епілоги 10/11 більше не використовуються.
  int cherieQuest002EpilogueWeeksRemaining = 0;

  /// Легасі сейвів.
  String? cherieQuest002EpilogueTickDateKey;

  /// Якщо ГГ вийшов з квесту в суботу — у неділю квест 002 недоступний (скидається в понеділок).
  bool cherieQuest002SundayBlocked = false;

  /// Після першого «Закінчити» на кроці 8: наступний вхід у зал — лише одна кнопка на кроці 8.
  bool cherieQuest002MassageFinishOnlyNextHallVisit = false;

  /// Скільки понеділків залишилось до повернення обох кнопок («ноги»); лічиться після finish-only візиту.
  int cherieQuest002MassageLegsCooldownMondays = 0;

  /// Щоб лічильник cooldown спрацьовував один раз на ігровий понеділок (yyyy-M-d).
  String? cherieQuest002MassageCooldownMondayTickKey;

  /// Cooldown вичерпано — можна знову крок 8 з двома кнопками (гілка ніг).
  bool cherieQuest002MassageLegsReturnPending = false;

  /// cherie_quest_003: 0 — не активний; 1–3 — кроки в офісі ТРЦ.
  int cherieQuest003Step = 0;

  /// cherie_quest_004: 0 — не активний; 1 — офіс; 3–10 спальня; 11 зал (контракт).
  int cherieQuest004Step = 0;

  /// 0 — звичайна гілка; 1 — після відбою груди (massage_no_2); 2 — після відбою «кицька» (massage_no_1).
  int cherieQuest004Branch = 0;

  /// У кроці 4: `false` — massage_3 + «Запропонувати ноги»; `true` — massage_4 + «Лягти на спину» / «Закінчити».
  bool cherieQuest004LegsMassagePhase = false;

  /// cherie_quest_005: 0 — не активний; 1 — офіс; 2–13 — спальня (реклама).
  int cherieQuest005Step = 0;

  /// Лічильник «фотосесія в трусах» (гілки після примірки; колишній actor).
  int cherieQuest005Actor = 0;

  /// Лічильник «лизун»: 0 — нейтрально; 1 — погодився; 2 — відмова; макс. 3.
  int cherieQuest005Lizun = 0;

  /// Крок 4.2 (step 6): яку картинку показати — 0 `pants_1_stoyak`, 1 `pants`, 2 `pants_rek` (рандом при вході з кроку 4).
  int cherieQuest005Step42PantsPick = 0;

  /// Лінія cherie_quest_005 виконана, якщо [cherieQuest005Actor] ≥ 10 (поріг — `CherieQuest005.completeActorThreshold`).
  bool cherieQuest005Complete = false;

  /// cherie_quest_006: 0 — не активний; 1–3 — офіс (новий етап відносин).
  int cherieQuest006Step = 0;

  /// Одноразовий квест cherie_quest_006 завершено.
  bool cherieQuest006Complete = false;

  /// Після 006: прапорець «новий етап відносин» для подальшого сюжету / UI.
  bool cherieRelationshipNewStage = false;

  /// EVENT cherie_event_004: 0 — не активний; 1 офіс … 8 спальня.
  int cherieMassageFunEventStep = 0;

  /// mom_quest_001 (пляж): 0 — немає активної сцени; 1…27 кроки сценарію.
  int momQuest001Step = 0;

  /// Лічильник прогресу «пляж» (0…4). Після фіналу кроку 27 лишається 4.
  int momQuest001Beach = 0;

  /// Після «Погодитись» у залі (крок 1): суб/нд 12–14 мама в залі замість старих слотів.
  bool momQuest001InvitationAccepted = false;

  /// Останній тиждень (ключ понеділка `yyyy-MM-dd`), коли завершено поїздку на пляж (mom_quest_001); раз на тиждень.
  String? momQuest001LastBeachTripWeekKey;

  /// EVENT mom_event_002: 0 — не активний; 1 пропозиція (кухня); 2 чистка (двір); 3 оплата (кухня).
  int momEvent002Step = 0;

  /// ГG прийняв пропозицію почистити басейн у поточному слоті (Пн/Чт).
  bool momPoolEventActive = false;

  /// День тижня слоту (0 = Пн, 3 = Чт), коли прийняли пропозицію; −1 — немає.
  int momPoolEventSlotWeekday = -1;

  /// Ключ понеділка тижня слоту (`yyyy-MM-dd`), коли прийняли пропозицію.
  String? momPoolEventSlotWeekKey;

  /// ГG почистив басейн і чекає розмови з мамою на кухні.
  bool momPoolCleanPendingPay = false;

  /// Останній тиждень понеділкового слоту mom_event_002 (ключ понеділка `yyyy-MM-dd`).
  String? momPoolMonWeekKey;

  /// Останній тиждень четвергового слоту mom_event_002 (ключ понеділка `yyyy-MM-dd`).
  String? momPoolThuWeekKey;

  /// Скільки разів мама заплатила \$50 за чистку басейну.
  int momPoolCleanPaidCount = 0;

  /// Скільки разів мама «винна» ГG після mom_event_002.
  int momOwesGgCount = 0;

  /// Після 5 оплат \$50 — вибір «\$50» або «будеш винна».
  bool momPoolPayOrDebtChoiceUnlocked = false;

  /// Чит змінив стан mom_event_002 — перезапустити перевірку на кухні.
  bool momEvent002PendingKitchenRecheck = false;

  /// piper_quest_001: 0 — фон; 1–5 — основний флоу; 6 — фінал проходу кризи.
  /// Крок 7 (7A/7B/7C) — unlock ГG, окремі прапори, не [piperQuest001Step].
  int piperQuest001Step = 0;
  /// Скільки разів закрито крок 6 (завершено прохід кризи).
  int piperQuest001PassesCompleted = 0;
  /// piper_quest_001 крок 2: ролик «просить не здавати» уже відтворено (не перезапускати).
  bool piperQuest001Step2VideoSeen = false;
  /// piper_quest_001 крок 2 (ГG карає): підменю «Домовитись» — «Покажи сіськи» / «Покажи дупу».
  bool piperQuest001Step2GgDealSubmenu = false;
  /// Після «Покажи сіськи/дупу»: картинка або відмова — очікує «Піти».
  bool piperQuest001GgDealRevealPending = false;
  bool piperQuest001GgDealRevealSuccess = false;
  /// `breasts` | `ass` | `full`
  String piperQuest001GgDealRevealKind = '';
  /// Успішне «Покажи дупу» в «Домовитись» (назавжди — для spank_002).
  bool piperQuest001GgDealAssShown = false;
  /// Успішне «Покажи сіськи» в «Домовитись» (назавжди — для spank_003).
  bool piperQuest001GgDealBreastsShown = false;
  /// Успішних «Роздягнись повністю» (для tier statів у таблиці Notion).
  int piperQuest001GgDealFullStripCount = 0;
  /// Скільки разів завершено «Покарати жорстко» (spank_004 tier statів).
  int piperQuest001HarshPunishCount = 0;
  /// piper_quest_001 крок 3: дзвінок мами (mom_phone) переглянуто до кінця.
  bool piperQuest001Step3VideoSeen = false;
  /// piper_quest_001 крок 5: криза ≥ 6 — після spank_003 доступна «Покарати жорстко».
  bool piperQuest001Step5HarshOfferActive = false;
  /// piper_quest_001 крок 5: активне spank_004 після «Покарати жорстко».
  bool piperQuest001HarshPunishActive = false;
  /// Жорстке покарання: «Роздвинути ноги» уже зараховано в лічильник «Секс» (1 раз за сесію).
  bool piperQuest001HarshSpreadLegsSexCounted = false;
  /// piper_quest_001 «Везунчик»: stat-gate обійдено — уся harsh-гілка до кінця сесії.
  bool piperQuest001VezunchykActive = false;
  /// piper_quest_001 крок 5: поточне відео покарання переглянуто до кінця.
  bool piperQuest001Step5VideoSeen = false;
  /// piper_quest_001 крок 3: ГГ уже натиснув «Підслухати» (лише «Піти»).
  bool piperQuest001Step3CallOverheard = false;
  /// piper_quest_001 крок 4: ГГ підслухав сварку (опційно; без відео).
  bool piperQuest001Step4ScoldingOverheard = false;
  /// piper_quest_001 крок 4: найраніша дата (`yyyy-M-d`) вечірнього старту в коридорі.
  String? piperQuest001Step4EarliestDayKey;

  /// piper_quest_001: після здачі мамі — короткий діалог «Ти розповів…» + «Назад».
  bool piperQuest001SnitchAckPending = false;
  /// Legacy двокроковий «Поговорити» на кухні (0/1/2). Крок 7A — [piperGgPunishmentGranted].
  int piperQuest001GgPunishTalkPhase = 0;
  /// piper_quest_001 крок 7A: мама дозволила ГG наказувати Пайпер замість неї.
  bool piperGgPunishmentGranted = false;
  /// piper_quest_001 крок 7B: ГG сказав Пайпер у `piper_room` (діє з **наступної** кризи).
  bool piperGgPunishmentAnnouncedToPiper = false;
  /// piper_quest_001: чи ГG карає в **поточній** кризі (встановлюється при старті нової двійки).
  bool piperGgPunishmentThisCrisis = false;
  /// piper_quest_001: добровільне покарання spank_001 у `piper_room` уже використано в цій кризі.
  bool piperGgVoluntaryPunishDoneThisCrisis = false;
  /// piper_quest_001 крок 7C: `gg_punisher` / `gg_cover` / `homework_deal`.
  String piperPunishmentBranch = '';
  int piperBadGradesCount = 0;
  bool piperGradeCrisisActive = false;
  bool piperGradeSecretKnown = false;
  bool piperHelpRequested = false;
  bool piperCrisisResolved = false;
  bool piperSnitchedToMom = false;
  bool piperMomTalkingAboutGrades = false;
  bool teacherCallPending = false;
  bool teacherCalledMom = false;
  String? piperBadGradeDayKey;
  int piperWorkdaysSinceBadGrade = 0;
  String? teacherCallDayKey;
  bool piperApproachSlot1Done = false;
  bool piperApproachSlot2Done = false;
  String piperBadGradeSubject = '';
  String piperBadGradeTeacherId = '';
  bool piperBadGradeToday = false;
  String? piperBadGradeWeekKey;
  String? piperBadGradeLastRollDayKey;
  bool piperPunishmentPending = false;
  int piperPunishmentCrisisN = 0;
  bool piperUnderPunishment = false;
  bool teacherDealHookOpen = false;
  bool piperNoPhone = false;
  String piperDebtType = '';

  /// Piper зал (вихідні): 0 — фон; 1 — відео + діалог; 2 — гілка (куріння).
  int piperHallEventStep = 0;
  /// 1 — куріння (`piper_event_001`); 2 — навчання; 3 — фітнес.
  int piperHallEventVariant = 0;
  /// Ролик уже відтворено → діалог + кнопки.
  bool piperHallEventVideoSeen = false;
  /// `piper_event_001`: `snitch` / `blackmail` / `punish`.
  String piperHallEventBranch = '';
  /// ГG бачив Piper за курінням (накопичувальний прапор).
  bool piperSmokingSecretKnown = false;
  /// Лічильники проходів повторюваних івентів залу.
  int piperEvent001Completions = 0;
  int piperEvent002Completions = 0;
  int piperEvent003Completions = 0;

  /// gg_event_001_stojak: дата останнього скидання прапорів мами/сестер о 6:00 (`yyyy-M-d`).
  String? ggEvent001StojakLastResetDayKey;

  /// Днів без миття ГГ (0 — сьогодні мився або нова гра; ≥3 — «смердить»).
  int ggDaysSinceWash = 0;

  /// Останній ігровий день, для якого застосовано [GgHygiene.syncDayTick].
  String? ggHygieneLastTickGameDayKey;

  /// Скільки разів завершено івент (фінал кроку 6 «Піти» або кроку 8 «Піти»).
  int cherieMassageFunCompletions = 0;

  /// rockefeller_quest_001: 0 — не активний; 1 — старт; 2 — офер; 3 — погодження.
  int rockefellerNikeOfficeStep = 0;
  /// Після «Погодитись» — відкрито роботу «Зніматись в рекламі».
  bool rockefellerNikeWorkStarted = false;
  /// Лічильник днів зйомок (макс 5).
  int rockefellerNikeShootingDays = 0;
  /// Активна сесія «Зніматись в рекламі» (кнопка «Закінчити»).
  bool rockefellerNikeShootingInProgress = false;
  /// Активний фінальний перегляд ролика (кнопка «Отримати гроші та піти»).
  bool rockefellerNikeFinalReviewInProgress = false;
  /// Квест завершено.
  bool rockefellerNikeAdCompleted = false;

  /// При cherie_quest_005 не виконано: дата останнього «Запитати про роботу»
  /// (ключ [GameTimeController.onlyDate], dd.MM.yyyy) — не частіше разу на добу, лише 9–18.
  String? rockefellerCherie005IncompleteAskLastDateKey;

  /// Дата останнього завершеного тренування з гантелями в залі дому ГГ
  /// (ключ [GameTimeController.onlyDate], dd.MM.yyyy) — не частіше разу на добу.
  String? homeHallDumbbellsWorkoutLastDateKey;
  /// Дата останнього завершеного тренування з гирею в залі дому ГГ
  /// (ключ [GameTimeController.onlyDate], dd.MM.yyyy) — не частіше разу на добу.
  String? homeHallKettlebellWorkoutLastDateKey;

  /// Скільки разів ГG відпочив у залі («Відпочити годинку») — для майбутніх квестів/івентів.
  int hallRestCount = 0;

  /// Дата, коли за продаж білизни в туалеті коледжу вже «спалила» одна власниця
  /// (ключ [GameTimeController.onlyDate], dd.MM.yyyy) — не більше одного викриття на добу.
  String? underwearSaleExposureDayKey;

  /// Id власниці, яка дізналась про продаж у цей [underwearSaleExposureDayKey].
  String? underwearSaleExposedOwnerId;

  /// Ключ тижня (понеділок "yyyy-MM-dd"), для якого задано дні відкритих дверей
  String? lastDoorWeekKey;
  /// День тижня (0–6), коли двері мами «відчинені» цього тижня (рандомно кожен понеділок)
  int? momDoorOpenWeekday;
  int? elsaDoorOpenWeekday;
  int? piperDoorOpenWeekday;

  /// Ключ кімнати вже випав при обшуку (одноразово на гру для кожного ключа).
  bool homeRoomSearchKeyElsaGranted = false;
  bool homeRoomSearchKeyPiperGranted = false;
  bool homeRoomSearchKeyMomGranted = false;

  /// Обшук спальні Shalina (елітний ЖК, кв. 3): одноразові знахідки.
  bool shalinaRoomSearchCash100Granted = false;
  bool shalinaRoomSearchEcstasyGranted = false;

  /// Дім друга (Сем): нічні двері кімнат батьків і Саші (23–7), окремий рандом на тиждень.
  int? friendHouseDanielleDoorOpenWeekday;
  int? friendHouseSashaDoorOpenWeekday;

  /// work_03 у кабінеті мами: ГG зняв/зберіг компромат на флешку та ноут.
  bool hasMomOfficeCompromatVideo3 = false;

  /// Компроматні відео, які збережені на ноуті (по нпс).
  /// Наприклад: ['mom', 'elsa', 'piper', 'luda'].
  List<String> compromatNpcIds = [];

  /// Відео компромату у галереї телефона (id записів, напр. juniper_manuel_compromat).
  List<String> phoneCompromatEntryIds = [];

  /// Дата/час покупки картки в VIP тренажерку (ISO). Строк дії — 30 днів.
  String? vipGymCardPurchasedAtIso;

  /// Seed для відео мами на кухні: новий при кожному заході в кухню (рандомне відео).
  int? kitchenVisitSeed;
  /// Seed для нічних sleep-відео в кімнаті мами (22–6): новий при кожному вході.
  int? momRoomNightVisitSeed;
  /// Seed для відео мами у ванні (душ): новий при кожному заході в bathroom.
  int? momBathroomVisitSeed;

  /// Seed для відео Пайпер у ванні (душ): новий при кожному заході в bathroom.
  int? piperBathroomVisitSeed;
  /// Квест Danielle / Sem: підглядання біля кімнати батьків (spyOnSemParents) вже відіграно.
  bool spyOnSemParentsDone = false;

  /// Після фінального ролика: Danielle «піймала» погляд гравця.
  bool spyOnSemParentsSpottedByDanielle = false;

  /// Повне підглядання сцени в кімнаті батьків (після 3-го відео).
  bool spyOnSemParentsParentsRoomPeekDone = false;

  /// Скільки збудження ГГ додано при завершенні spyOnSemParents (для симетричного відкату).
  double? spyOnSemParentsPlayerArousalDeltaApplied;

  /// Перший день поточної гри (`dd.MM.yyyy`) — база для «день N від старту».
  String? gameStartDateKey;

  // --- sem_quest_001: арка Juniper (знайомство, стосунки з Sem) ---
  /// Натяк Sem «пора шукати дівчину» (sem_quest_001) — старт таймера Juniper.
  bool semJuniperGirlsTalkDone = false;

  /// Розмова про сестру Sasha на фасаді (sem_quest_001).
  bool semGirlsSisterTalkDone = false;

  /// Дата останньої розмови на тему (dd.MM.yyyy) — для «Новин Sem» і 14-денного івенту.
  String? semJuniperLastTopicTalkDateKey;

  /// Sem познайомився з Juniper у коледжі (через 3 дні після розмови «про дівчат»).
  bool semJuniperCollegeMeetDone = false;

  /// «Новини Sem» на фасаді пройдено (≈ через тиждень після першої розмови).
  bool semJuniperFollowUpDone = false;

  /// ГG познайомився з Juniper (сцена в кімнаті Sem).
  bool semJuniperMet = false;

  /// У коридорі вже показано текст про шум із кімнати Sem (перед входом у кімнату).
  bool semJuniperCorridorNoiseShown = false;

  /// Juniper і Sem офіційно зустрічаються — у профілі статус «Дівчина Sem».
  bool semJuniperDating = false;

  /// Дата початку стосунків (dd.MM.yyyy) — для 3-тижневих вечірніх візитів.
  String? semJuniperDatingStartDateKey;

  /// Legacy save; більше не використовується.
  String? semJuniperEveningClipShownDateKey;

  /// Legacy save; більше не використовується.
  String? semJuniperShowerSceneDateKey;

  /// Остання ігрова година (`dd.MM.yyyy_H`), коли нараховано бонуси за відео Juniper.
  String? semJuniperVideoStatsHourKey;

  /// Сцена 4 відео у кімнаті Sem (суб 12:00 / нд 16:00) — повний перегляд відіграно.
  bool semJuniperSemRoomSexCompleted = false;

  /// Скільки разів ГG доглянув усю сцену в кімнаті Sem (4 відео до кінця).
  int semJuniperSemRoomSexWitnessCount = 0;

  /// Скільки «палива» зібрано (0…4); перше — після `junip_sem_room_sex_04_palivo`.
  int palivo = 0;

  /// Розмова «Розповісти, що бачив Semа з Juniper» — відіграно.
  bool semPalivoWitnessTalkDone = false;

  /// Розмова «Вибачитись за інцидент» з Juniper — відіграно.
  bool juniperPalivoApologyTalkDone = false;

  /// QUEST: juniper_quest_001 — крок 1 (ванна Sem, junip_manuel_01) завершено.
  bool juniperManuelKompromatStep1Done = false;

  /// QUEST: juniper_quest_001 — день, коли ГG побачив Manuel + Juniper (крок 1).
  String? juniperManuelKompromatStep1WitnessDateKey;

  /// QUEST: juniper_quest_001 — година того перегляду (зазвичай 12).
  int? juniperManuelKompromatStep1WitnessHour;

  /// QUEST: juniper_quest_001 — день завершення кроку 1 («Зняти на відео»), fallback для кроку 2.
  String? juniperManuelKompromatStep1DoneDateKey;

  /// QUEST: juniper_quest_001 — крок 2 (зал Sem, junip_manuel_zal_01) завершено.
  bool juniperManuelKompromatStep2Done = false;

  /// QUEST: juniper_quest_001 — день завершення кроку 2 («Тікати»), якір для кроку 3.
  String? juniperManuelKompromatStep2DoneDateKey;

  /// Чит: не чекати 5 днів між кроком 1 і 2 kompromat.
  bool juniperManuelKompromatStep2SkipFiveDaysCheat = false;

  /// QUEST: juniper_quest_001 — крок 3 (ванна Sem, junip_manuel_02) завершено.
  bool juniperManuelKompromatStep3Done = false;

  /// QUEST: juniper_quest_001 — день завершення кроку 3, якір для кроку 4.
  String? juniperManuelKompromatStep3DoneDateKey;

  /// Чит: не чекати 5 днів між кроком 2 і 3 kompromat.
  bool juniperManuelKompromatStep3SkipFiveDaysCheat = false;

  /// QUEST: juniper_quest_001 — крок 4 (ванна Sem, junip_manuel_03) / квест завершено.
  bool juniperManuelKompromatStep4Done = false;

  /// Чит: не чекати 3 дні між кроком 3 і 4 kompromat.
  bool juniperManuelKompromatStep4SkipThreeDaysCheat = false;

  /// QUEST: juniper_quest_002_naslidku — розмова про компромат розпочата.
  bool juniperQuest002NaslidkuStarted = false;

  /// QUEST: juniper_quest_002_naslidku — крок 1 (показ відео) завершено.
  bool juniperQuest002Step1Done = false;

  /// QUEST: juniper_quest_003 — старт (кнопка «Вздрочнуть» у гостиній Sem).
  bool juniperQuest003Started = false;

  /// QUEST: juniper_quest_003 — після catch-відео: Juniper у залі, підслуховування.
  bool juniperQuest003HallFollowUpActive = false;

  /// QUEST: juniper_quest_003 — with_gg_02 у залі Sem відіграно.
  bool juniperQuest003HallSceneDone = false;

  /// QUEST: juniper_quest_003 — catch-відео в гостиній: Juniper тимчасово в залі сцени.
  bool juniperQuest003LoungePinActive = false;

  /// QUEST: juniper_quest_003 — календарний день catch-сцени (sex о 18:00).
  String? juniperQuest003CatchDateKey;

  /// QUEST: juniper_quest_003 — день, коли catch sex о 18:00 уже відіграно (1 раз на добу).
  String? juniperQuest003CatchDaySemRoomSexPlayedDateKey;

  /// Квест «спалився»: розмова з Danielle після підглядання — відіграно.
  bool danielleSpyCaughtConfrontationDone = false;
  /// Скільки разів ГГ уже проходив розмову «спалився» з Danielle.
  int danielleSpyCaughtConfrontationCount = 0;

  /// Останній ігровий день (`yyyy-MM-dd`), для якого застосовано економіку NPC.
  String? lastNpcEconomyProcessedDateKey;

  /// Останній календарний місяць (`yyyy-MM`), для якого вже проведено щомісячну лотерею NPC.
  String? lastNpcLotteryMonthKey;

  /// Фінанси NPC з ГГ: ключ — id NPC, значення — [NpcFinanceRecord.toJson].
  Map<String, Map<String, dynamic>> npcFinanceByNpcId = {};

  /// Останній рік-тиждень (`yyyy_weekIndex`), коли непрацюючий NPC уже зробив імпульсну покупку в ТРЦ.
  Map<String, String> npcTrcImpulseYearWeekByNpcId = {};

  /// Остання оброблена ігрова доба для штрафів боргу / автопогашень (`yyyy-MM-dd` з 06:00).
  String? lastNpcFinanceGameDayKey;

  GameWorldState({
    this.currentZone = "HOME",
    this.currentRoom = LocationsData.corridor,
    this.isInsideRoom = false,
    this.currentStreetHouse,
  });

  Map<String, dynamic> toJson() => {
        'currentZone': currentZone,
        'currentRoom': currentRoom,
        'gameStartDateKey': gameStartDateKey,
        'isInsideRoom': isInsideRoom,
        'currentStreetHouse': currentStreetHouse,
        'installedSpyCameraRooms': installedSpyCameraRooms,
        'flyersJobOfferPending': flyersJobOfferPending,
        'lastFlyersDateKey': lastFlyersDateKey,
        'constructionJobOfferPending': constructionJobOfferPending,
        'lastConstructionDateKey': lastConstructionDateKey,
        'callCenterJobOfferPending': callCenterJobOfferPending,
        'lastCallCenterDateKey': lastCallCenterDateKey,
        'giftShopAnimatorJobOfferPending': giftShopAnimatorJobOfferPending,
        'lastGiftShopAnimatorDateKey': lastGiftShopAnimatorDateKey,
        'giftShopAnimatorPendingFinishDateKey': giftShopAnimatorPendingFinishDateKey,
        'giftShopAnimatorShiftsCompleted': giftShopAnimatorShiftsCompleted,
        'cherieAnimatorIntroStep': cherieAnimatorIntroStep,
        'cherieAnimatorIntroTc2SlotKeyStash': cherieAnimatorIntroTc2SlotKeyStash,
        'cherieAnimatorIntroTc2TipsStash': cherieAnimatorIntroTc2TipsStash,
        'cherieAnimatorWorkVideoCount': cherieAnimatorWorkVideoCount,
        'cherieAnimatorNextQuestDayCounter': cherieAnimatorNextQuestDayCounter,
        'cherieAnimatorNextQuestLastDateKey': cherieAnimatorNextQuestLastDateKey,
        'cherieQuest002Step': cherieQuest002Step,
        'cherieQuest002WarehouseWhoAsked': cherieQuest002WarehouseWhoAsked,
        'cherieQuest002EpilogueWeeksRemaining': cherieQuest002EpilogueWeeksRemaining,
        'cherieQuest002EpilogueTickDateKey': cherieQuest002EpilogueTickDateKey,
        'cherieQuest002SundayBlocked': cherieQuest002SundayBlocked,
        'cherieQuest002MassageFinishOnlyNextHallVisit':
            cherieQuest002MassageFinishOnlyNextHallVisit,
        'cherieQuest002MassageLegsCooldownMondays':
            cherieQuest002MassageLegsCooldownMondays,
        'cherieQuest002MassageCooldownMondayTickKey':
            cherieQuest002MassageCooldownMondayTickKey,
        'cherieQuest002MassageLegsReturnPending':
            cherieQuest002MassageLegsReturnPending,
        'cherieQuest003Step': cherieQuest003Step,
        'cherieQuest004Step': cherieQuest004Step,
        'cherieQuest004Branch': cherieQuest004Branch,
        'cherieQuest004LegsMassagePhase': cherieQuest004LegsMassagePhase,
        'cherieQuest005Step': cherieQuest005Step,
        'cherieQuest005Actor': cherieQuest005Actor,
        'cherieQuest005Lizun': cherieQuest005Lizun,
        'cherieQuest005Step42PantsPick': cherieQuest005Step42PantsPick,
        'cherieQuest005Complete': cherieQuest005Actor >= 10,
        'cherieQuest006Step': cherieQuest006Step,
        'cherieQuest006Complete': cherieQuest006Complete,
        'cherieRelationshipNewStage': cherieRelationshipNewStage,
        'cherieMassageFunEventStep': cherieMassageFunEventStep,
        'momQuest001Step': momQuest001Step,
        'momQuest001Beach': momQuest001Beach,
        'momQuest001InvitationAccepted': momQuest001InvitationAccepted,
        'momQuest001LastBeachTripWeekKey': momQuest001LastBeachTripWeekKey,
        'momEvent002Step': momEvent002Step,
        'momPoolEventActive': momPoolEventActive,
        'momPoolEventSlotWeekday': momPoolEventSlotWeekday,
        'momPoolEventSlotWeekKey': momPoolEventSlotWeekKey,
        'momPoolCleanPendingPay': momPoolCleanPendingPay,
        'momPoolMonWeekKey': momPoolMonWeekKey,
        'momPoolThuWeekKey': momPoolThuWeekKey,
        'momPoolCleanPaidCount': momPoolCleanPaidCount,
        'momOwesGgCount': momOwesGgCount,
        'momPoolPayOrDebtChoiceUnlocked': momPoolPayOrDebtChoiceUnlocked,
        'momEvent002PendingKitchenRecheck': momEvent002PendingKitchenRecheck,
        'piperQuest001Step': piperQuest001Step,
        'piperQuest001PassesCompleted': piperQuest001PassesCompleted,
        'piperQuest001Step2VideoSeen': piperQuest001Step2VideoSeen,
        'piperQuest001Step2GgDealSubmenu': piperQuest001Step2GgDealSubmenu,
        'piperQuest001GgDealRevealPending': piperQuest001GgDealRevealPending,
        'piperQuest001GgDealRevealSuccess': piperQuest001GgDealRevealSuccess,
        'piperQuest001GgDealRevealKind': piperQuest001GgDealRevealKind,
        'piperQuest001GgDealAssShown': piperQuest001GgDealAssShown,
        'piperQuest001GgDealBreastsShown': piperQuest001GgDealBreastsShown,
        'piperQuest001GgDealFullStripCount': piperQuest001GgDealFullStripCount,
        'piperQuest001HarshPunishCount': piperQuest001HarshPunishCount,
        'piperQuest001Step3VideoSeen': piperQuest001Step3VideoSeen,
        'piperQuest001Step5VideoSeen': piperQuest001Step5VideoSeen,
        'piperQuest001Step5HarshOfferActive':
            piperQuest001Step5HarshOfferActive,
        'piperQuest001HarshPunishActive': piperQuest001HarshPunishActive,
        'piperQuest001HarshSpreadLegsSexCounted':
            piperQuest001HarshSpreadLegsSexCounted,
        'piperQuest001VezunchykActive': piperQuest001VezunchykActive,
        'piperQuest001Step3CallOverheard': piperQuest001Step3CallOverheard,
        'piperQuest001Step4ScoldingOverheard':
            piperQuest001Step4ScoldingOverheard,
        'piperQuest001Step4EarliestDayKey': piperQuest001Step4EarliestDayKey,
        'piperBadGradesCount': piperBadGradesCount,
        'piperGradeCrisisActive': piperGradeCrisisActive,
        'piperGradeSecretKnown': piperGradeSecretKnown,
        'piperHelpRequested': piperHelpRequested,
        'piperCrisisResolved': piperCrisisResolved,
        'piperSnitchedToMom': piperSnitchedToMom,
        'piperMomTalkingAboutGrades': piperMomTalkingAboutGrades,
        'piperQuest001SnitchAckPending': piperQuest001SnitchAckPending,
        'piperQuest001GgPunishTalkPhase': piperQuest001GgPunishTalkPhase,
        'piperGgPunishmentGranted': piperGgPunishmentGranted,
        'piperGgPunishmentAnnouncedToPiper': piperGgPunishmentAnnouncedToPiper,
        'piperGgPunishmentThisCrisis': piperGgPunishmentThisCrisis,
        'piperGgVoluntaryPunishDoneThisCrisis':
            piperGgVoluntaryPunishDoneThisCrisis,
        'piperPunishmentBranch': piperPunishmentBranch,
        'teacherCallPending': teacherCallPending,
        'teacherCalledMom': teacherCalledMom,
        'piperBadGradeDayKey': piperBadGradeDayKey,
        'piperWorkdaysSinceBadGrade': piperWorkdaysSinceBadGrade,
        'teacherCallDayKey': teacherCallDayKey,
        'piperApproachSlot1Done': piperApproachSlot1Done,
        'piperApproachSlot2Done': piperApproachSlot2Done,
        'piperBadGradeSubject': piperBadGradeSubject,
        'piperBadGradeTeacherId': piperBadGradeTeacherId,
        'piperBadGradeToday': piperBadGradeToday,
        'piperBadGradeWeekKey': piperBadGradeWeekKey,
        'piperBadGradeLastRollDayKey': piperBadGradeLastRollDayKey,
        'piperPunishmentPending': piperPunishmentPending,
        'piperPunishmentCrisisN': piperPunishmentCrisisN,
        'piperUnderPunishment': piperUnderPunishment,
        'teacherDealHookOpen': teacherDealHookOpen,
        'piperNoPhone': piperNoPhone,
        'piperDebtType': piperDebtType,
        'piperHallEventStep': piperHallEventStep,
        'piperHallEventVariant': piperHallEventVariant,
        'piperHallEventVideoSeen': piperHallEventVideoSeen,
        'piperHallEventBranch': piperHallEventBranch,
        'piperSmokingSecretKnown': piperSmokingSecretKnown,
        'piperEvent001Completions': piperEvent001Completions,
        'piperEvent002Completions': piperEvent002Completions,
        'piperEvent003Completions': piperEvent003Completions,
        'ggEvent001StojakLastResetDayKey': ggEvent001StojakLastResetDayKey,
        'ggDaysSinceWash': ggDaysSinceWash,
        'ggHygieneLastTickGameDayKey': ggHygieneLastTickGameDayKey,
        'cherieMassageFunCompletions': cherieMassageFunCompletions,
        'rockefellerNikeOfficeStep': rockefellerNikeOfficeStep,
        'rockefellerNikeWorkStarted': rockefellerNikeWorkStarted,
        'rockefellerNikeShootingDays': rockefellerNikeShootingDays,
        'rockefellerNikeShootingInProgress': rockefellerNikeShootingInProgress,
        'rockefellerNikeFinalReviewInProgress':
            rockefellerNikeFinalReviewInProgress,
        'rockefellerNikeAdCompleted': rockefellerNikeAdCompleted,
        'rockefellerCherie005IncompleteAskLastDateKey':
            rockefellerCherie005IncompleteAskLastDateKey,
        'homeHallDumbbellsWorkoutLastDateKey':
            homeHallDumbbellsWorkoutLastDateKey,
        'homeHallKettlebellWorkoutLastDateKey':
            homeHallKettlebellWorkoutLastDateKey,
        'hallRestCount': hallRestCount,
        'underwearSaleExposureDayKey': underwearSaleExposureDayKey,
        'underwearSaleExposedOwnerId': underwearSaleExposedOwnerId,
        'lastDoorWeekKey': lastDoorWeekKey,
        'momDoorOpenWeekday': momDoorOpenWeekday,
        'elsaDoorOpenWeekday': elsaDoorOpenWeekday,
        'piperDoorOpenWeekday': piperDoorOpenWeekday,
        'homeRoomSearchKeyElsaGranted': homeRoomSearchKeyElsaGranted,
        'homeRoomSearchKeyPiperGranted': homeRoomSearchKeyPiperGranted,
        'homeRoomSearchKeyMomGranted': homeRoomSearchKeyMomGranted,
        'shalinaRoomSearchCash100Granted': shalinaRoomSearchCash100Granted,
        'shalinaRoomSearchEcstasyGranted': shalinaRoomSearchEcstasyGranted,
        'friendHouseDanielleDoorOpenWeekday':
            friendHouseDanielleDoorOpenWeekday,
        'friendHouseSashaDoorOpenWeekday': friendHouseSashaDoorOpenWeekday,
        'kitchenVisitSeed': kitchenVisitSeed,
        'momRoomNightVisitSeed': momRoomNightVisitSeed,
        'momBathroomVisitSeed': momBathroomVisitSeed,
        'piperBathroomVisitSeed': piperBathroomVisitSeed,
        'hasMomOfficeCompromatVideo3': hasMomOfficeCompromatVideo3,
        'compromatNpcIds': compromatNpcIds,
        'phoneCompromatEntryIds': phoneCompromatEntryIds,
        'vipGymCardPurchasedAtIso': vipGymCardPurchasedAtIso,
        'spyOnSemParentsDone': spyOnSemParentsDone,
        'spyOnSemParentsSpottedByDanielle': spyOnSemParentsSpottedByDanielle,
        'spyOnSemParentsParentsRoomPeekDone': spyOnSemParentsParentsRoomPeekDone,
        'spyOnSemParentsPlayerArousalDeltaApplied':
            spyOnSemParentsPlayerArousalDeltaApplied,
        'semJuniperGirlsTalkDone': semJuniperGirlsTalkDone,
        'semGirlsSisterTalkDone': semGirlsSisterTalkDone,
        'semJuniperLastTopicTalkDateKey': semJuniperLastTopicTalkDateKey,
        'semJuniperCollegeMeetDone': semJuniperCollegeMeetDone,
        'semJuniperFollowUpDone': semJuniperFollowUpDone,
        'semJuniperMet': semJuniperMet,
        'semJuniperCorridorNoiseShown': semJuniperCorridorNoiseShown,
        'semJuniperDating': semJuniperDating,
        'semJuniperDatingStartDateKey': semJuniperDatingStartDateKey,
        'semJuniperEveningClipShownDateKey': semJuniperEveningClipShownDateKey,
        'semJuniperShowerSceneDateKey': semJuniperShowerSceneDateKey,
        'semJuniperVideoStatsHourKey': semJuniperVideoStatsHourKey,
        'semJuniperSemRoomSexCompleted': semJuniperSemRoomSexCompleted,
        'semJuniperSemRoomSexWitnessCount': semJuniperSemRoomSexWitnessCount,
        'palivo': palivo,
        'semPalivoWitnessTalkDone': semPalivoWitnessTalkDone,
        'juniperPalivoApologyTalkDone': juniperPalivoApologyTalkDone,
        'juniperManuelKompromatStep1Done': juniperManuelKompromatStep1Done,
        'juniperManuelKompromatStep1WitnessDateKey':
            juniperManuelKompromatStep1WitnessDateKey,
        'juniperManuelKompromatStep1WitnessHour':
            juniperManuelKompromatStep1WitnessHour,
        'juniperManuelKompromatStep1DoneDateKey':
            juniperManuelKompromatStep1DoneDateKey,
        'juniperManuelKompromatStep2Done': juniperManuelKompromatStep2Done,
        'juniperManuelKompromatStep2DoneDateKey':
            juniperManuelKompromatStep2DoneDateKey,
        'juniperManuelKompromatStep2SkipFiveDaysCheat':
            juniperManuelKompromatStep2SkipFiveDaysCheat,
        'juniperManuelKompromatStep3Done': juniperManuelKompromatStep3Done,
        'juniperManuelKompromatStep3DoneDateKey':
            juniperManuelKompromatStep3DoneDateKey,
        'juniperManuelKompromatStep3SkipFiveDaysCheat':
            juniperManuelKompromatStep3SkipFiveDaysCheat,
        'juniperManuelKompromatStep4Done': juniperManuelKompromatStep4Done,
        'juniperManuelKompromatStep4SkipThreeDaysCheat':
            juniperManuelKompromatStep4SkipThreeDaysCheat,
        'juniperQuest002NaslidkuStarted': juniperQuest002NaslidkuStarted,
        'juniperQuest002Step1Done': juniperQuest002Step1Done,
        'juniperQuest003Started': juniperQuest003Started,
        'juniperQuest003HallFollowUpActive': juniperQuest003HallFollowUpActive,
        'juniperQuest003HallSceneDone': juniperQuest003HallSceneDone,
        'juniperQuest003LoungePinActive': juniperQuest003LoungePinActive,
        'juniperQuest003CatchDateKey': juniperQuest003CatchDateKey,
        'juniperQuest003CatchDaySemRoomSexPlayedDateKey':
            juniperQuest003CatchDaySemRoomSexPlayedDateKey,
        'danielleSpyCaughtConfrontationDone': danielleSpyCaughtConfrontationDone,
        'danielleSpyCaughtConfrontationCount':
            danielleSpyCaughtConfrontationCount,
        'lastNpcEconomyProcessedDateKey': lastNpcEconomyProcessedDateKey,
        'lastNpcLotteryMonthKey': lastNpcLotteryMonthKey,
        'npcFinanceByNpcId': npcFinanceByNpcId,
        'npcTrcImpulseYearWeekByNpcId': npcTrcImpulseYearWeekByNpcId,
        'lastNpcFinanceGameDayKey': lastNpcFinanceGameDayKey,
      };

  void loadFromJson(Map<String, dynamic> json) {
    currentZone = json['currentZone'] ?? currentZone;
    currentRoom = json['currentRoom'] ?? currentRoom;
    if (currentRoom == 'lisa_room') currentRoom = 'elsa_room';
    currentRoom = LocationsData.migrateLegacyRoomId(currentRoom);
    isInsideRoom = json['isInsideRoom'] ?? isInsideRoom;
    currentStreetHouse = json['currentStreetHouse'] as String?;
    gameStartDateKey = json['gameStartDateKey'] as String? ??
        GameTimeController.defaultGameStartDateKey;
    final list = json['installedSpyCameraRooms'];
    installedSpyCameraRooms = list != null
        ? List<String>.from(list as List)
        : [];
    installedSpyCameraRooms = installedSpyCameraRooms.map((r) {
      if (r == 'lisa_room') return 'elsa_room';
      return LocationsData.migrateLegacyRoomId(r);
    }).toList();
    flyersJobOfferPending = json['flyersJobOfferPending'] == true;
    lastFlyersDateKey = json['lastFlyersDateKey'] as String?;
    constructionJobOfferPending = json['constructionJobOfferPending'] == true;
    lastConstructionDateKey = json['lastConstructionDateKey'] as String?;
    callCenterJobOfferPending = json['callCenterJobOfferPending'] == true;
    lastCallCenterDateKey = json['lastCallCenterDateKey'] as String?;
    giftShopAnimatorJobOfferPending =
        json['giftShopAnimatorJobOfferPending'] == true ||
            json['flowerShopAnimatorJobOfferPending'] == true;
    lastGiftShopAnimatorDateKey =
        json['lastGiftShopAnimatorDateKey'] as String? ??
            json['lastFlowerShopAnimatorDateKey'] as String?;
    giftShopAnimatorPendingFinishDateKey =
        json['giftShopAnimatorPendingFinishDateKey'] as String?;
    giftShopAnimatorShiftsCompleted =
        (json['giftShopAnimatorShiftsCompleted'] as num?)?.toInt() ?? 0;
    cherieAnimatorIntroStep =
        ((json['cherieAnimatorIntroStep'] as num?)?.toInt() ?? 0).clamp(0, 5);
    cherieAnimatorIntroTc2SlotKeyStash =
        json['cherieAnimatorIntroTc2SlotKeyStash'] as String?;
    cherieAnimatorIntroTc2TipsStash =
        (json['cherieAnimatorIntroTc2TipsStash'] as num?)?.toInt();
    cherieAnimatorWorkVideoCount =
        (json['cherieAnimatorWorkVideoCount'] as num?)?.toInt() ?? 0;
    cherieAnimatorNextQuestDayCounter =
        (json['cherieAnimatorNextQuestDayCounter'] as num?)?.toInt() ?? 0;
    if (cherieAnimatorNextQuestDayCounter > 5) {
      cherieAnimatorNextQuestDayCounter = 5;
    }
    cherieAnimatorNextQuestLastDateKey =
        json['cherieAnimatorNextQuestLastDateKey'] as String?;
    var q2Step = ((json['cherieQuest002Step'] as num?)?.toInt() ?? 0);
    if (q2Step >= 10) {
      q2Step = 0;
    }
    cherieQuest002Step = q2Step.clamp(0, 9);
    cherieQuest002WarehouseWhoAsked =
        json['cherieQuest002WarehouseWhoAsked'] == true;
    cherieQuest002EpilogueWeeksRemaining =
        ((json['cherieQuest002EpilogueWeeksRemaining'] as num?)?.toInt() ?? 0)
            .clamp(0, 99);
    cherieQuest002EpilogueTickDateKey =
        json['cherieQuest002EpilogueTickDateKey'] as String?;
    cherieQuest002SundayBlocked = json['cherieQuest002SundayBlocked'] == true;
    cherieQuest002MassageFinishOnlyNextHallVisit =
        json['cherieQuest002MassageFinishOnlyNextHallVisit'] == true;
    cherieQuest002MassageLegsCooldownMondays =
        ((json['cherieQuest002MassageLegsCooldownMondays'] as num?)?.toInt() ??
                0)
            .clamp(0, 99);
    cherieQuest002MassageCooldownMondayTickKey =
        json['cherieQuest002MassageCooldownMondayTickKey'] as String?;
    cherieQuest002MassageLegsReturnPending =
        json['cherieQuest002MassageLegsReturnPending'] == true;
    cherieQuest003Step =
        ((json['cherieQuest003Step'] as num?)?.toInt() ?? 0).clamp(0, 3);
    cherieQuest004Step =
        ((json['cherieQuest004Step'] as num?)?.toInt() ?? 0).clamp(0, 11);
    // Колишній офісний крок 2 злито з кроком 1 (усі кроки багаторазові).
    if (cherieQuest004Step == 2) {
      cherieQuest004Step = 1;
    }
    cherieQuest004Branch =
        ((json['cherieQuest004Branch'] as num?)?.toInt() ?? 0).clamp(0, 3);
    cherieQuest004LegsMassagePhase =
        json['cherieQuest004LegsMassagePhase'] == true;
    cherieQuest005Step =
        ((json['cherieQuest005Step'] as num?)?.toInt() ?? 0).clamp(0, 20);
    cherieQuest005Actor =
        ((json['cherieQuest005Actor'] as num?)?.toInt() ?? 0).clamp(0, 99);
    cherieQuest005Lizun =
        ((json['cherieQuest005Lizun'] as num?)?.toInt() ?? 0).clamp(0, 3);
    cherieQuest005Step42PantsPick =
        ((json['cherieQuest005Step42PantsPick'] as num?)?.toInt() ?? 0)
            .clamp(0, 2);
    // Єдиний критерій «005 виконано» — лічильник actor ≥ 10 (ігноруємо застарілий прапор у сейві).
    cherieQuest005Complete = cherieQuest005Actor >= 10;
    cherieQuest006Step =
        ((json['cherieQuest006Step'] as num?)?.toInt() ?? 0).clamp(0, 10);
    cherieQuest006Complete = json['cherieQuest006Complete'] == true;
    cherieRelationshipNewStage = json['cherieRelationshipNewStage'] == true;
    cherieMassageFunEventStep =
        ((json['cherieMassageFunEventStep'] as num?)?.toInt() ?? 0).clamp(0, 20);
    momQuest001Step =
        ((json['momQuest001Step'] as num?)?.toInt() ?? 0).clamp(0, 27);
    momQuest001Beach =
        ((json['momQuest001Beach'] as num?)?.toInt() ?? 0).clamp(0, 4);
    momQuest001InvitationAccepted =
        json['momQuest001InvitationAccepted'] == true;
    momQuest001LastBeachTripWeekKey =
        json['momQuest001LastBeachTripWeekKey'] as String?;
    momEvent002Step =
        ((json['momEvent002Step'] as num?)?.toInt() ?? 0).clamp(0, 3);
    momPoolEventActive = json['momPoolEventActive'] == true;
    momPoolEventSlotWeekday =
        ((json['momPoolEventSlotWeekday'] as num?)?.toInt() ?? -1).clamp(-1, 6);
    momPoolEventSlotWeekKey = json['momPoolEventSlotWeekKey'] as String?;
    momPoolCleanPendingPay = json['momPoolCleanPendingPay'] == true;
    momPoolMonWeekKey = json['momPoolMonWeekKey'] as String?;
    momPoolThuWeekKey = json['momPoolThuWeekKey'] as String?;
    momPoolCleanPaidCount =
        ((json['momPoolCleanPaidCount'] as num?)?.toInt() ?? 0).clamp(0, 9999);
    momOwesGgCount =
        ((json['momOwesGgCount'] as num?)?.toInt() ?? 0).clamp(0, 9999);
    momPoolPayOrDebtChoiceUnlocked =
        json['momPoolPayOrDebtChoiceUnlocked'] == true;
    momEvent002PendingKitchenRecheck =
        json['momEvent002PendingKitchenRecheck'] == true;
    final legacyStep = (json['piperQuest001Step'] as num?)?.toInt();
    piperQuest001Step =
        (legacyStep == 7 ? 6 : (legacyStep ?? 0)).clamp(0, 6);
    piperQuest001PassesCompleted =
        ((json['piperQuest001PassesCompleted'] as num?)?.toInt() ?? 0)
            .clamp(0, 9999);
    piperQuest001Step2VideoSeen =
        json['piperQuest001Step2VideoSeen'] == true;
    piperQuest001Step2GgDealSubmenu =
        json['piperQuest001Step2GgDealSubmenu'] == true;
    piperQuest001GgDealRevealPending =
        json['piperQuest001GgDealRevealPending'] == true;
    piperQuest001GgDealRevealSuccess =
        json['piperQuest001GgDealRevealSuccess'] == true;
    piperQuest001GgDealRevealKind =
        json['piperQuest001GgDealRevealKind'] as String? ?? '';
    piperQuest001GgDealAssShown =
        json['piperQuest001GgDealAssShown'] == true;
    piperQuest001GgDealBreastsShown =
        json['piperQuest001GgDealBreastsShown'] == true;
    piperQuest001GgDealFullStripCount =
        (json['piperQuest001GgDealFullStripCount'] as num?)?.toInt() ?? 0;
    piperQuest001HarshPunishCount =
        (json['piperQuest001HarshPunishCount'] as num?)?.toInt() ?? 0;
    piperQuest001Step3VideoSeen =
        json['piperQuest001Step3VideoSeen'] == true;
    piperQuest001Step5VideoSeen =
        json['piperQuest001Step5VideoSeen'] == true;
    piperQuest001Step5HarshOfferActive =
        json['piperQuest001Step5HarshOfferActive'] == true;
    piperQuest001HarshPunishActive =
        json['piperQuest001HarshPunishActive'] == true;
    piperQuest001HarshSpreadLegsSexCounted =
        json['piperQuest001HarshSpreadLegsSexCounted'] == true;
    piperQuest001VezunchykActive =
        json['piperQuest001VezunchykActive'] == true;
    piperQuest001Step3CallOverheard =
        json['piperQuest001Step3CallOverheard'] == true;
    piperQuest001Step4ScoldingOverheard =
        json['piperQuest001Step4ScoldingOverheard'] == true;
    piperQuest001Step4EarliestDayKey =
        json['piperQuest001Step4EarliestDayKey'] as String?;
    piperBadGradesCount =
        ((json['piperBadGradesCount'] as num?)?.toInt() ?? 0).clamp(0, 9999);
    piperGradeCrisisActive = json['piperGradeCrisisActive'] == true;
    piperGradeSecretKnown = json['piperGradeSecretKnown'] == true;
    piperHelpRequested = json['piperHelpRequested'] == true;
    piperCrisisResolved = json['piperCrisisResolved'] == true;
    piperSnitchedToMom = json['piperSnitchedToMom'] == true;
    piperMomTalkingAboutGrades = json['piperMomTalkingAboutGrades'] == true;
    piperQuest001SnitchAckPending =
        json['piperQuest001SnitchAckPending'] == true;
    piperQuest001GgPunishTalkPhase =
        ((json['piperQuest001GgPunishTalkPhase'] as num?)?.toInt() ?? 0)
            .clamp(0, 2);
    piperGgPunishmentGranted = json['piperGgPunishmentGranted'] == true;
    piperGgPunishmentAnnouncedToPiper =
        json['piperGgPunishmentAnnouncedToPiper'] == true;
    piperGgPunishmentThisCrisis = json['piperGgPunishmentThisCrisis'] == true;
    piperGgVoluntaryPunishDoneThisCrisis =
        json['piperGgVoluntaryPunishDoneThisCrisis'] == true;
    piperPunishmentBranch = json['piperPunishmentBranch'] as String? ?? '';
    teacherCallPending = json['teacherCallPending'] == true;
    teacherCalledMom = json['teacherCalledMom'] == true;
    piperBadGradeDayKey = json['piperBadGradeDayKey'] as String?;
    piperWorkdaysSinceBadGrade =
        ((json['piperWorkdaysSinceBadGrade'] as num?)?.toInt() ?? 0)
            .clamp(0, 99);
    teacherCallDayKey = json['teacherCallDayKey'] as String?;
    piperApproachSlot1Done = json['piperApproachSlot1Done'] == true;
    piperApproachSlot2Done = json['piperApproachSlot2Done'] == true;
    piperBadGradeSubject = json['piperBadGradeSubject'] as String? ?? '';
    piperBadGradeTeacherId = json['piperBadGradeTeacherId'] as String? ?? '';
    piperBadGradeToday = json['piperBadGradeToday'] == true;
    piperBadGradeWeekKey = json['piperBadGradeWeekKey'] as String?;
    piperBadGradeLastRollDayKey =
        json['piperBadGradeLastRollDayKey'] as String?;
    piperPunishmentPending = json['piperPunishmentPending'] == true;
    piperPunishmentCrisisN =
        ((json['piperPunishmentCrisisN'] as num?)?.toInt() ?? 0).clamp(0, 99);
    piperUnderPunishment = json['piperUnderPunishment'] == true;
    teacherDealHookOpen = json['teacherDealHookOpen'] == true;
    piperNoPhone = json['piperNoPhone'] == true;
    piperDebtType = json['piperDebtType'] as String? ?? '';
    piperHallEventStep =
        ((json['piperHallEventStep'] as num?)?.toInt() ??
                (json['piperQuest002Step'] as num?)?.toInt() ??
                0)
            .clamp(0, 2);
    final legacyComplete = json['piperQuest002Complete'] == true;
    if (legacyComplete && piperHallEventStep > 0) {
      piperHallEventStep = 0;
    }
    piperHallEventVariant =
        ((json['piperHallEventVariant'] as num?)?.toInt() ??
                (json['piperQuest002VideoVariant'] as num?)?.toInt() ??
                0)
            .clamp(0, 3);
    piperHallEventVideoSeen =
        json['piperHallEventVideoSeen'] == true ||
            json['piperQuest002VideoSeen'] == true;
    piperHallEventBranch = (json['piperHallEventBranch'] as String? ??
            json['piperQuest002Branch'] as String? ??
            '')
        .trim();
    piperSmokingSecretKnown = json['piperSmokingSecretKnown'] == true;
    piperEvent001Completions =
        ((json['piperEvent001Completions'] as num?)?.toInt() ?? 0)
            .clamp(0, 9999);
    piperEvent002Completions =
        ((json['piperEvent002Completions'] as num?)?.toInt() ?? 0)
            .clamp(0, 9999);
    piperEvent003Completions =
        ((json['piperEvent003Completions'] as num?)?.toInt() ?? 0)
            .clamp(0, 9999);
    ggEvent001StojakLastResetDayKey =
        json['ggEvent001StojakLastResetDayKey'] as String?;
    ggDaysSinceWash = (json['ggDaysSinceWash'] as num?)?.toInt() ?? 0;
    ggHygieneLastTickGameDayKey =
        json['ggHygieneLastTickGameDayKey'] as String?;
    cherieMassageFunCompletions =
        ((json['cherieMassageFunCompletions'] as num?)?.toInt() ?? 0).clamp(0, 9999);
    rockefellerNikeOfficeStep =
        ((json['rockefellerNikeOfficeStep'] as num?)?.toInt() ?? 0).clamp(0, 3);
    rockefellerNikeWorkStarted = json['rockefellerNikeWorkStarted'] == true;
    rockefellerNikeShootingDays =
        ((json['rockefellerNikeShootingDays'] as num?)?.toInt() ?? 0)
            .clamp(0, 5);
    rockefellerNikeShootingInProgress =
        json['rockefellerNikeShootingInProgress'] == true;
    rockefellerNikeFinalReviewInProgress =
        json['rockefellerNikeFinalReviewInProgress'] == true;
    rockefellerNikeAdCompleted = json['rockefellerNikeAdCompleted'] == true;
    rockefellerCherie005IncompleteAskLastDateKey =
        json['rockefellerCherie005IncompleteAskLastDateKey'] as String?;
    homeHallDumbbellsWorkoutLastDateKey =
        json['homeHallDumbbellsWorkoutLastDateKey'] as String?;
    homeHallKettlebellWorkoutLastDateKey =
        json['homeHallKettlebellWorkoutLastDateKey'] as String?;
    hallRestCount = (json['hallRestCount'] as num?)?.toInt() ?? 0;
    underwearSaleExposureDayKey =
        json['underwearSaleExposureDayKey'] as String?;
    underwearSaleExposedOwnerId =
        json['underwearSaleExposedOwnerId'] as String?;
    // Колишній крок «ноги» був step 5; тепер step 4 + [cherieQuest004LegsMassagePhase].
    if (cherieQuest004Step == 5) {
      cherieQuest004Step = 4;
      cherieQuest004LegsMassagePhase = true;
    }
    lastDoorWeekKey = json['lastDoorWeekKey'] as String?;
    momDoorOpenWeekday = json['momDoorOpenWeekday'] as int?;
    elsaDoorOpenWeekday = json['elsaDoorOpenWeekday'] as int? ?? json['lisaDoorOpenWeekday'] as int?;
    piperDoorOpenWeekday = json['piperDoorOpenWeekday'] as int?;
    homeRoomSearchKeyElsaGranted = json['homeRoomSearchKeyElsaGranted'] == true;
    homeRoomSearchKeyPiperGranted = json['homeRoomSearchKeyPiperGranted'] == true;
    homeRoomSearchKeyMomGranted = json['homeRoomSearchKeyMomGranted'] == true;
    shalinaRoomSearchCash100Granted = json['shalinaRoomSearchCash100Granted'] == true;
    shalinaRoomSearchEcstasyGranted = json['shalinaRoomSearchEcstasyGranted'] == true;
    friendHouseDanielleDoorOpenWeekday =
        json['friendHouseDanielleDoorOpenWeekday'] as int?;
    friendHouseSashaDoorOpenWeekday =
        json['friendHouseSashaDoorOpenWeekday'] as int?;
    hasMomOfficeCompromatVideo3 = json['hasMomOfficeCompromatVideo3'] == true;
    final compromatList = json['compromatNpcIds'];
    compromatNpcIds = compromatList != null
        ? List<String>.from(compromatList as List)
        : [];
    final phoneCompromatList = json['phoneCompromatEntryIds'];
    phoneCompromatEntryIds = phoneCompromatList != null
        ? List<String>.from(phoneCompromatList as List)
        : [];
    vipGymCardPurchasedAtIso = json['vipGymCardPurchasedAtIso'] as String?;
    compromatNpcIds = compromatNpcIds.map((id) {
      if (id == 'lisa') return 'elsa';
      if (id == 'elsa') return 'piper';
      if (id == 'piper') return 'elsa';
      return id;
    }).toList();
    spyOnSemParentsDone = json['spyOnSemParentsDone'] == true;
    spyOnSemParentsSpottedByDanielle =
        json['spyOnSemParentsSpottedByDanielle'] == true;
    spyOnSemParentsParentsRoomPeekDone =
        json['spyOnSemParentsParentsRoomPeekDone'] == true;
    final arousalDelta = json['spyOnSemParentsPlayerArousalDeltaApplied'];
    spyOnSemParentsPlayerArousalDeltaApplied = arousalDelta is num
        ? arousalDelta.toDouble()
        : null;
    semJuniperGirlsTalkDone = json['semJuniperGirlsTalkDone'] == true;
    semGirlsSisterTalkDone = json['semGirlsSisterTalkDone'] == true;
    semJuniperLastTopicTalkDateKey =
        json['semJuniperLastTopicTalkDateKey'] as String?;
    semJuniperCollegeMeetDone = json['semJuniperCollegeMeetDone'] == true;
    semJuniperFollowUpDone = json['semJuniperFollowUpDone'] == true;
    semJuniperMet = json['semJuniperMet'] == true;
    semJuniperCorridorNoiseShown = json['semJuniperCorridorNoiseShown'] == true;
    semJuniperDating = json['semJuniperDating'] == true;
    semJuniperDatingStartDateKey =
        json['semJuniperDatingStartDateKey'] as String?;
    if (semJuniperDating && semJuniperDatingStartDateKey == null) {
      semJuniperDatingStartDateKey = semJuniperLastTopicTalkDateKey;
    }
    semJuniperEveningClipShownDateKey =
        json['semJuniperEveningClipShownDateKey'] as String?;
    semJuniperShowerSceneDateKey =
        json['semJuniperShowerSceneDateKey'] as String?;
    semJuniperVideoStatsHourKey =
        json['semJuniperVideoStatsHourKey'] as String?;
    semJuniperSemRoomSexCompleted =
        json['semJuniperSemRoomSexCompleted'] == true;
    semJuniperSemRoomSexWitnessCount =
        (json['semJuniperSemRoomSexWitnessCount'] as num?)?.toInt() ?? 0;
    final palivoRaw = json['palivo'];
    if (palivoRaw is num) {
      palivo = palivoRaw.toInt().clamp(0, 4);
    } else if (palivoRaw == true) {
      palivo = 1;
    } else {
      palivo = 0;
    }
    semPalivoWitnessTalkDone = json['semPalivoWitnessTalkDone'] == true;
    juniperPalivoApologyTalkDone =
        json['juniperPalivoApologyTalkDone'] == true;
    juniperManuelKompromatStep1Done =
        json['juniperManuelKompromatStep1Done'] == true;
    juniperManuelKompromatStep1WitnessDateKey =
        json['juniperManuelKompromatStep1WitnessDateKey'] as String?;
    juniperManuelKompromatStep1WitnessHour =
        (json['juniperManuelKompromatStep1WitnessHour'] as num?)?.toInt();
    juniperManuelKompromatStep1DoneDateKey =
        json['juniperManuelKompromatStep1DoneDateKey'] as String?;
    juniperManuelKompromatStep2Done =
        json['juniperManuelKompromatStep2Done'] == true;
    juniperManuelKompromatStep2DoneDateKey =
        json['juniperManuelKompromatStep2DoneDateKey'] as String?;
    juniperManuelKompromatStep2SkipFiveDaysCheat =
        json['juniperManuelKompromatStep2SkipFiveDaysCheat'] == true;
    juniperManuelKompromatStep3Done =
        json['juniperManuelKompromatStep3Done'] == true;
    juniperManuelKompromatStep3DoneDateKey =
        json['juniperManuelKompromatStep3DoneDateKey'] as String?;
    juniperManuelKompromatStep3SkipFiveDaysCheat =
        json['juniperManuelKompromatStep3SkipFiveDaysCheat'] == true;
    juniperManuelKompromatStep4Done =
        json['juniperManuelKompromatStep4Done'] == true;
    juniperManuelKompromatStep4SkipThreeDaysCheat =
        json['juniperManuelKompromatStep4SkipThreeDaysCheat'] == true;
    juniperQuest002NaslidkuStarted =
        json['juniperQuest002NaslidkuStarted'] == true;
    juniperQuest002Step1Done = json['juniperQuest002Step1Done'] == true;
    juniperQuest003Started = json['juniperQuest003Started'] == true;
    juniperQuest003HallFollowUpActive =
        json['juniperQuest003HallFollowUpActive'] == true;
    juniperQuest003HallSceneDone =
        json['juniperQuest003HallSceneDone'] == true;
    juniperQuest003LoungePinActive =
        json['juniperQuest003LoungePinActive'] == true;
    juniperQuest003CatchDateKey =
        json['juniperQuest003CatchDateKey'] as String?;
    juniperQuest003CatchDaySemRoomSexPlayedDateKey =
        json['juniperQuest003CatchDaySemRoomSexPlayedDateKey'] as String?;
    danielleSpyCaughtConfrontationDone =
        json['danielleSpyCaughtConfrontationDone'] == true;
    danielleSpyCaughtConfrontationCount =
        (json['danielleSpyCaughtConfrontationCount'] as num?)?.toInt() ?? 0;
    kitchenVisitSeed = (json['kitchenVisitSeed'] as num?)?.toInt();
    momRoomNightVisitSeed = (json['momRoomNightVisitSeed'] as num?)?.toInt();
    momBathroomVisitSeed = (json['momBathroomVisitSeed'] as num?)?.toInt();
    piperBathroomVisitSeed = (json['piperBathroomVisitSeed'] as num?)?.toInt();
    lastNpcEconomyProcessedDateKey =
        json['lastNpcEconomyProcessedDateKey'] as String?;
    lastNpcLotteryMonthKey = json['lastNpcLotteryMonthKey'] as String?;
    final nf = json['npcFinanceByNpcId'];
    if (nf is Map) {
      npcFinanceByNpcId = nf.map(
        (k, v) {
          final m = Map<String, dynamic>.from(v as Map);
          final r = NpcFinanceRecord.fromJson(m);
          return MapEntry(k.toString(), r.toJson());
        },
      );
    } else {
      npcFinanceByNpcId = {};
    }
    final nyw = json['npcTrcImpulseYearWeekByNpcId'];
    if (nyw is Map) {
      npcTrcImpulseYearWeekByNpcId = nyw.map(
        (k, v) => MapEntry(k.toString(), v.toString()),
      );
    } else {
      npcTrcImpulseYearWeekByNpcId = {};
    }
    lastNpcFinanceGameDayKey = json['lastNpcFinanceGameDayKey'] as String?;
  }

  /// Скидає локацію до початкової для нової гри
  void reset() {
    currentZone = "HOME";
    currentRoom = LocationsData.corridor;
    isInsideRoom = false;
    currentStreetHouse = null;
    gameStartDateKey = GameTimeController.defaultGameStartDateKey;
    installedSpyCameraRooms = [];
    flyersJobOfferPending = false;
    lastFlyersDateKey = null;
    constructionJobOfferPending = false;
    lastConstructionDateKey = null;
    callCenterJobOfferPending = false;
    lastCallCenterDateKey = null;
    giftShopAnimatorJobOfferPending = false;
    lastGiftShopAnimatorDateKey = null;
    giftShopAnimatorPendingFinishDateKey = null;
    giftShopAnimatorShiftsCompleted = 0;
    cherieAnimatorIntroStep = 0;
    cherieAnimatorIntroTc2SlotKeyStash = null;
    cherieAnimatorIntroTc2TipsStash = null;
    cherieAnimatorWorkVideoCount = 0;
    cherieAnimatorNextQuestDayCounter = 0;
    cherieAnimatorNextQuestLastDateKey = null;
    cherieQuest002Step = 0;
    cherieQuest002EpilogueWeeksRemaining = 0;
    cherieQuest002EpilogueTickDateKey = null;
    cherieQuest002SundayBlocked = false;
    cherieQuest002WarehouseWhoAsked = false;
    cherieQuest002MassageFinishOnlyNextHallVisit = false;
    cherieQuest002MassageLegsCooldownMondays = 0;
    cherieQuest002MassageCooldownMondayTickKey = null;
    cherieQuest002MassageLegsReturnPending = false;
    cherieQuest003Step = 0;
    cherieQuest004Step = 0;
    cherieQuest004Branch = 0;
    cherieQuest004LegsMassagePhase = false;
    cherieQuest005Step = 0;
    cherieQuest005Actor = 0;
    cherieQuest005Lizun = 0;
    cherieQuest005Step42PantsPick = 0;
    cherieQuest005Complete = false;
    cherieQuest006Step = 0;
    cherieQuest006Complete = false;
    cherieRelationshipNewStage = false;
    cherieMassageFunEventStep = 0;
    momQuest001Step = 0;
    momQuest001Beach = 0;
    momQuest001InvitationAccepted = false;
    momQuest001LastBeachTripWeekKey = null;
    momEvent002Step = 0;
    momPoolEventActive = false;
    momPoolEventSlotWeekday = -1;
    momPoolEventSlotWeekKey = null;
    momPoolCleanPendingPay = false;
    momPoolMonWeekKey = null;
    momPoolThuWeekKey = null;
    momPoolCleanPaidCount = 0;
    momOwesGgCount = 0;
    momPoolPayOrDebtChoiceUnlocked = false;
    momEvent002PendingKitchenRecheck = false;
    PiperQuest001.resetCheat(this);
    ggEvent001StojakLastResetDayKey = null;
    ggDaysSinceWash = 0;
    ggHygieneLastTickGameDayKey = null;
    cherieMassageFunCompletions = 0;
    rockefellerNikeOfficeStep = 0;
    rockefellerNikeWorkStarted = false;
    rockefellerNikeShootingDays = 0;
    rockefellerNikeShootingInProgress = false;
    rockefellerNikeFinalReviewInProgress = false;
    rockefellerNikeAdCompleted = false;
    rockefellerCherie005IncompleteAskLastDateKey = null;
    homeHallDumbbellsWorkoutLastDateKey = null;
    homeHallKettlebellWorkoutLastDateKey = null;
    hallRestCount = 0;
    underwearSaleExposureDayKey = null;
    underwearSaleExposedOwnerId = null;
    lastDoorWeekKey = null;
    momDoorOpenWeekday = null;
    elsaDoorOpenWeekday = null;
    piperDoorOpenWeekday = null;
    homeRoomSearchKeyElsaGranted = false;
    homeRoomSearchKeyPiperGranted = false;
    homeRoomSearchKeyMomGranted = false;
    shalinaRoomSearchCash100Granted = false;
    shalinaRoomSearchEcstasyGranted = false;
    friendHouseDanielleDoorOpenWeekday = null;
    friendHouseSashaDoorOpenWeekday = null;
    kitchenVisitSeed = null;
    momRoomNightVisitSeed = null;
    momBathroomVisitSeed = null;
    piperBathroomVisitSeed = null;
    hasMomOfficeCompromatVideo3 = false;
    compromatNpcIds = [];
    phoneCompromatEntryIds = [];
    vipGymCardPurchasedAtIso = null;
    spyOnSemParentsDone = false;
    spyOnSemParentsSpottedByDanielle = false;
    spyOnSemParentsParentsRoomPeekDone = false;
    spyOnSemParentsPlayerArousalDeltaApplied = null;
    semJuniperGirlsTalkDone = false;
    semGirlsSisterTalkDone = false;
    semJuniperLastTopicTalkDateKey = null;
    semJuniperCollegeMeetDone = false;
    semJuniperFollowUpDone = false;
    semJuniperMet = false;
    semJuniperCorridorNoiseShown = false;
    semJuniperDating = false;
    semJuniperDatingStartDateKey = null;
    semJuniperEveningClipShownDateKey = null;
    semJuniperShowerSceneDateKey = null;
    semJuniperVideoStatsHourKey = null;
    semJuniperSemRoomSexCompleted = false;
    semJuniperSemRoomSexWitnessCount = 0;
    palivo = 0;
    semPalivoWitnessTalkDone = false;
    juniperPalivoApologyTalkDone = false;
    juniperManuelKompromatStep1Done = false;
    juniperManuelKompromatStep1WitnessDateKey = null;
    juniperManuelKompromatStep1WitnessHour = null;
    juniperManuelKompromatStep1DoneDateKey = null;
    juniperManuelKompromatStep2Done = false;
    juniperManuelKompromatStep2DoneDateKey = null;
    juniperManuelKompromatStep2SkipFiveDaysCheat = false;
    juniperManuelKompromatStep3Done = false;
    juniperManuelKompromatStep3DoneDateKey = null;
    juniperManuelKompromatStep3SkipFiveDaysCheat = false;
    juniperManuelKompromatStep4Done = false;
    juniperManuelKompromatStep4SkipThreeDaysCheat = false;
    juniperQuest002NaslidkuStarted = false;
    juniperQuest002Step1Done = false;
    juniperQuest003Started = false;
    juniperQuest003HallFollowUpActive = false;
    juniperQuest003HallSceneDone = false;
    juniperQuest003LoungePinActive = false;
    juniperQuest003CatchDateKey = null;
    juniperQuest003CatchDaySemRoomSexPlayedDateKey = null;
    danielleSpyCaughtConfrontationDone = false;
    danielleSpyCaughtConfrontationCount = 0;
    lastNpcEconomyProcessedDateKey = null;
    lastNpcLotteryMonthKey = null;
    npcFinanceByNpcId = {};
    npcTrcImpulseYearWeekByNpcId = {};
    lastNpcFinanceGameDayKey = null;
  }
}

