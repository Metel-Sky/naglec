import '../../models/npc_model.dart';
import '../../models/item_model.dart';
import '../../data/locations_room_data.dart';
import 'mom_video_func.dart';

/// Портрет для галереї «Персонажі»; аватар для телефону, профілю, смуги NPC.
const String kMomGalleryPortraitPath = 'lib/assets/npcs/mom/mom.jpg';
const String kMomAvatarPath = 'lib/assets/npcs/mom/mom_ava.png';

/// Заглушка офісу / work slot — не показувати як силует NPC у домі (кухня тощо).
const String kMomWorkplacePlaceholderPath =
    'lib/assets/npcs/mom/mom_work_place.jpg';

/// Особисті речі Cory, які можуть випадати при обшуку її кімнати.
const List<LootOption> momPersonalLoot = [
  LootOption(item: GameItems.panties, weight: 0.1),
  LootOption(item: GameItems.bra, weight: 0.1),
  LootOption(item: GameItems.dildo, weight: 0.05),
  LootOption(item: GameItems.analPlug, weight: 0.03),
  LootOption(item: GameItems.vibratorRemote, weight: 0.03),
  LootOption(item: GameItems.roomKey, weight: 0.05),
];

const List<NpcOwnedItem> _coryOwnedItems = [
  NpcOwnedItem(
    id: 'cory_cheap_phone',
    name: 'Дешевий телефон',
    imagePath: 'lib/assets/items/old_samsung.jpg',
  ),
  NpcOwnedItem(
    id: 'cory_office_key',
    name: 'Ключ від офісу',
    imagePath: 'lib/assets/items/lib_key.png',
  ),
];

/// Модель NPC: Cory (статистика, розклад, аватар).
NPCModel createMomNpc() {
  return NPCModel(
    id: 'mom',
    name: 'Cory',
    fullName: 'Cory',
    status: 'Мати',
    bodyDescription:
        'Класична MILF: дуже красива, підтягута, з усім при собі. Завжди виглядає '
        'як бізнес-леді й тримає форму; груди силіконові, попа — натуральна, кругла.',
    biographyType:
        'Це Корі, моя мати. Точніше моя мачуха, але з поваги і любові до неї я не можу '
        'її так називати. Моя рідна мати загинула при моєму народженні, а батько — '
        'у автокатастрофі три роки тому. Мені не було куди дітися, і Корі не змогла '
        '«відшити» мене кудись — залишила жити з собою. Вона ніколи не казала, що я '
        'прийомний, ніколи не ображала — і вже вважає мене своїм названим сином. '
        'Piper і Elsa — її рідні доньки.\n\n'
        'Після загибелі її чоловіка — мого батька — Корі довго була в депресії. '
        'Вона втратила компанії й заощадження; лишилися лише цей дім і простенька '
        'робота менеджеркою. Заробляє небагато, а будинок у кредиті — майже всю '
        'зарплату забирає банк, інакше заберуть житло. Я допомагаю їй, як можу, '
        'і колись обіцяв повністю взяти її на забезпечення й виплатити кредит.\n\n'
        'Корі дуже втомлюється; на особисте життя майже не лишається часу. Проте '
        'завжди виглядає охайно й привабливо, часто займається фітнесом і йогою вдома. '
        'Її мрія — закрити іпотеку, купити машину і нарешті менше працювати.',
    biographyAppearance:
        'Класична MILF, але дуже красива: підтягута, доглянута, з усім «при собі». '
        'Завжди схожа на бізнес-леді — охайна, зібрана, у гарній формі. Груди — '
        'силіконові, але виглядають природно; попа — натуральна, кругла, дуже гарна. '
        'Навіть після важкого дня тримає себе так, ніби збиралася на важливу зустріч.',
    weaknesses: [
      'Втома: після роботи й домашніх справ майже не лишається сил.',
      'Іпотека: більшість зарплати йде в банк за будинок.',
      'Мало часу на себе: особисте життя постійно відкладається.',
      'Мрія: виплатити кредит, купити машину і менше працювати.',
    ],
    checkpoints: const [],
    age: 37,
    items: List<NpcOwnedItem>.from(_coryOwnedItems),
    galleryPortraitPath: kMomGalleryPortraitPath,
    avatarPath: kMomAvatarPath,
    // Час включно: 7–7 = 7:00–7:59, 10–17 = 10:00–17:59; через північ 23–6 = 23:00–6:59.
    schedule: [
      SchedulePoint(
        hourStart: 7,
        hourEnd: 7,
        location: 'kitchen',
        actionLabel: 'Готує сніданок',
        spritePath: momKitchenMorning(),
        days: [0, 1, 2, 3, 4],
      ),
      SchedulePoint(
        hourStart: 8,
        hourEnd: 8,
        location: 'mom_room',
        actionLabel: 'Перевдягається',
        // Ввечері в залі — без відео, статичний кадр.
        spritePath: 'lib/assets/npcs/mom/mom_work_place.jpg',
        days: [0, 1, 2, 3, 4],
      ),
      SchedulePoint(
        hourStart: 9,
        hourEnd: 9,
        location: 'bathroom',
        actionLabel: 'Миється',
        spritePath: momShowerMorningVideos(),
        days: [0, 1, 2, 3, 4],
      ),

      SchedulePoint(
        hourStart: 10,
        hourEnd: 13,
        location: LocationsData.cityBcLogisticsMomOffice,
        actionLabel: 'Робота',
        spritePath: '',
        days: [0, 1, 2, 3, 4],
      ),

      SchedulePoint(
        hourStart: 14,
        hourEnd: 14,
        location: LocationsData.cityParkCoffee,
        actionLabel: "Кав'ярня",
        spritePath: "lib/assets/npcs/mom/mom.jpg",
        days: [0, 1, 2, 3, 4],
      ),

      SchedulePoint(
        hourStart: 15,
        hourEnd: 17,
        location: LocationsData.cityBcLogisticsMomOffice,
        actionLabel: 'Робота',
        spritePath: '',
        days: [0, 1, 2, 3, 4],
      ),
      SchedulePoint(
        hourStart: 18,
        hourEnd: 19,
        // Маркер: фактична кімната обирається через NpcCityRoamingService.
        location: LocationsData.cityOverview,
        actionLabel: 'Гуляє по місту',
        spritePath: '',
        days: [1, 3, 4],
      ),
      SchedulePoint(
        hourStart: 18,
        hourEnd: 19,
        // Понеділок: VIP тренажерка (рандом hall/spa/sauna/massage у NPCService).
        location: LocationsData.cityVipGym,
        actionLabel: 'VIP тренажерка',
        spritePath: kMomAvatarPath,
        days: [0],
      ),
      SchedulePoint(
        hourStart: 18,
        hourEnd: 19,
        // Середа: VIP тренажерка (рандом hall/spa/sauna/massage у NPCService).
        location: LocationsData.cityVipGym,
        actionLabel: 'VIP тренажерка',
        spritePath: kMomAvatarPath,
        days: [2],
      ),
      SchedulePoint(
        hourStart: 20,
        hourEnd: 20,
        location: 'hall',
        actionLabel: 'Відпочиває',
        // Ввечері в залі — без відео, статичний кадр.
        spritePath: 'lib/assets/npcs/mom/mom_work_place.jpg',
        days: [0, 1, 2, 3, 4],
      ),
      SchedulePoint(
        hourStart: 21,
        hourEnd: 21,
        location: 'kitchen',
        actionLabel: 'Готує вечерю',
        // Фон-відео задає HomeView — momKitchenEveningSeeded (ролики кухні, не mom_room).
        spritePath: '',
        days: [0, 1, 2, 3, 4],
      ),
      SchedulePoint(
        hourStart: 22,
        hourEnd: 22,
        location: 'mom_room',
        actionLabel: 'Відпочиває',
        // Відео обирає HomeView за добовим seed (3 варіанти).
        spritePath: '',
        days: [0, 1, 2, 3, 4],
      ),

      ///#######################################################################
      SchedulePoint(
        hourStart: 9,
        hourEnd: 9,
        location: 'bathroom',
        actionLabel: 'Миється',
        spritePath: momShowerMorningVideos(),
        days: [5, 6],
      ),
      SchedulePoint(
        hourStart: 10,
        hourEnd: 11,
        location: 'kitchen',
        spritePath: kMomAvatarPath,
        days: [5, 6],
        actionLabel: '',
      ),
      SchedulePoint(
        hourStart: 12,
        hourEnd: 14,
        // Маркер: фактична кімната обирається через NpcCityRoamingService.
        location: LocationsData.cityOverview,
        actionLabel: 'Гуляє по місту',
        spritePath: '',
        days: [5, 6],
      ),
      SchedulePoint(
        hourStart: 15,
        hourEnd: 17,
        // Субота: VIP тренажерка, фактична кімната обирається в NPCService
        // з [hall, spa, sauna, massage].
        location: LocationsData.cityVipGym,
        actionLabel: 'VIP тренажерка',
        spritePath: kMomAvatarPath,
        days: [5],
      ),
      SchedulePoint(
        hourStart: 18,
        hourEnd: 20,
        location: LocationsData.poorVillageGiftShopOwnerKitchen,
        actionLabel: 'У Cherie на кухні',
        spritePath: kMomAvatarPath,
        days: [5],
      ),
      SchedulePoint(
        hourStart: 15,
        hourEnd: 17,
        location: LocationsData.yard,
        actionLabel: 'Відпочиває у басейна',
        spritePath: kMomAvatarPath,
        days: [6],
      ),
      SchedulePoint(
        hourStart: 18,
        hourEnd: 20,
        location: LocationsData.cityMallRestaurantHall,
        actionLabel: 'У ресторані (зал)',
        spritePath: kMomAvatarPath,
        days: [6],
      ),
      SchedulePoint(
        hourStart: 21,
        hourEnd: 22,
        location: 'hall',
        actionLabel: 'Дивиться ТВ',
        spritePath: 'lib/assets/npcs/mom/mom_work_place.jpg',
        days: [5, 6],
      ),
      ///#######################################################################
      SchedulePoint(
        hourStart: 23,
        hourEnd: 6,
        location: 'mom_room',
        actionLabel: 'sleep',
        // Те саме, що о 22: три sleep-відео — динамічно в HomeView.
        spritePath: '',
      ),
    ],
  );
}
