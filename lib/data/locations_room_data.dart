import '../models/room_models.dart';
import '../services/locations_loader.dart';
import '../services/service_locator.dart';
import '../services/locale_controller.dart';
import 'poor_district/poor_district_house_1.dart';
import 'poor_district/poor_district_house_2.dart';

class LocationsData {
  // --- Home: English id constants ---
  static const String corridor = 'corridor';
  static const String kitchen = 'kitchen';
  static const String roomGg = 'room_gg';
  static const String bathroom = 'bathroom';
  static const String momRoom = 'mom_room';
  static const String elsaRoom = 'elsa_room';
  static const String piperRoom = 'piper_room';
  static const String hall = 'hall';
  static const String yard = 'yard';
  static const String basement = 'basement';

  static Map<String, RoomData> get homeRooms => LocationsLoader.homeRooms;
  static List<String> get homeRoomIds => LocationsLoader.homeRoomIds;

  // --- College: English id constants ---
  static const String collegeHall = 'college_hall';
  static const String auditorium1 = 'auditorium_1';
  static const String auditorium2 = 'auditorium_2';
  static const String auditorium3 = 'auditorium_3';
  /// Коледжний коридор (у JSON — `college_corridor`; раніше помилково було `library`).
  static const String collegeCorridor = 'college_corridor';
  static const String directorOffice = 'director_office';
  static const String canteen = 'canteen';
  static const String gym = 'gym';
  static const String collegeYard = 'college_yard';
  static const String toilet = 'toilet';

  static Map<String, RoomData> get collegeRooms => LocationsLoader.collegeRooms;
  static List<String> get collegeRoomIds => LocationsLoader.collegeRoomIds;

  // --- Street: English id constants (4 будинки) ---
  static const String street = 'street';
  static const String friendHouse = 'friend_house';
  static const String auntHouse = 'aunt_house';
  static const String neighborHouse = 'neighbor_house';
  static const String classmateHouse = 'classmate_house';

  // Ключі кімнат будинку кориша (сітка без коридору-входу)
  static const String friendCorridor = 'friend_corridor';
  static const String friendKitchen = 'friend_kitchen';
  static const String friendRoom = 'friend_room';
  static const String friendBathroom = 'friend_bathroom';
  static const String friendParentsRoom = 'friend_parents_room';
  static const String friendSisterRoom = 'friend_sister_room';
  static const String friendHall = 'friend_hall';
  static const String friendLounge = 'friend_lounge';
  static const String friendSauna = 'friend_sauna';
  static const String friendPool = 'friend_pool';

  /// Синтетична «локація» для дій біля дверей (обхід нічного обрізання [NPCModel.getAvailableActions] о 22:00).
  static const String friendHouseDoorSummon = 'friend_house_door_summon';

  /// Чи [roomId] — кімната всередині будинку кориша на вул. Шевченка.
  static bool isFriendHouseInteriorRoom(String? roomId) {
    if (roomId == null) return false;
    final map = streetHouseRooms[friendHouse];
    return map != null && map.containsKey(roomId);
  }

  /// Маркер розкладу: Sem будні 18–20 — вдома, випадкова кімната (без Саші та батьків).
  /// Не кімната в JSON; фактичний id задає [NPCService.getCurrentLocationId].
  static const String friendHomeSemEveningRoam = 'friend_home_sem_evening_roam';

  /// Маркер: Danielle вихідні 12–14 — лише парк ([cityParkRoomIds]).
  static const String danielleWeekendParkRoam = 'danielle_weekend_park_roam';

  /// Маркер: Danielle вихідні 15–17 без VIP — вдома, випадкова з кухня/зал/ванна/кімната батьків.
  static const String friendHomeDanielleWeekendNoVipRoam =
      'friend_home_danielle_weekend_no_vip_roam';

  /// Маркер: Cherie будні 19–22 — вдома, випадкова кімната (без кімнат 2 і 3).
  static const String cherieWeekdayEveningHomeRoam =
      'cherie_weekday_evening_home_roam';

  /// Маркер: Alexis (тітка) — вдома, випадкова кімната будинку на вул. Шевченка.
  static const String auntHomeAlexisRoam = 'aunt_home_alexis_roam';

  /// Маркер: Lexi — вдома, випадкова кімната будинку однокласниці.
  static const String classmateHomeLexiRoam = 'classmate_home_lexi_roam';

  /// Маркер: Flaxy — вдома, випадкова кімната будинку тітки.
  static const String auntHomeFlaxyRoam = 'aunt_home_flaxy_roam';

  /// Маркер: Alyssa — вдома, випадкова кімната будинку однокласниці.
  static const String classmateHomeAlyssaRoam = 'classmate_home_alyssa_roam';

  /// Маркер: Candee — вдома, випадкова кімната будинку однокласниці.
  static const String classmateHomeCandeeRoam = 'classmate_home_candee_roam';

  /// Маркер: Katrin — вдома, випадкова кімната кв. 2 (Бандери 1).
  static const String poorDistrictH1Apt2KatrinRoam =
      'poor_district_h1_apt2_katrin_roam';

  /// Маркер: Kyler — вдома, випадкова кімната кв. 1 (Бандери 2).
  static const String poorDistrictH2Apt1KylerRoam =
      'poor_district_h2_apt1_kyler_roam';

  /// Маркер: Riley — вдома, випадкова кімната кв. 2 (елітний ЖК).
  static const String cityEliteApt2RileyRoam = 'city_elite_apt2_riley_roam';

  /// Чи [roomId] — кімната всередині будинку тітки на вул. Шевченка.
  static bool isAuntHouseInteriorRoom(String? roomId) {
    if (roomId == null) return false;
    final map = streetHouseRooms[auntHouse];
    return map != null && map.containsKey(roomId);
  }

  // Ключі кімнат будинку тітки (9 кімнат)
  static const String auntCorridor = 'aunt_corridor';
  static const String auntKitchen = 'aunt_kitchen';
  static const String auntRoom = 'aunt_room';
  static const String auntBathroom = 'aunt_bathroom';
  static const String auntGuestRoom = 'aunt_guest_room';
  static const String auntNephewRoom = 'aunt_nephew_room';
  static const String auntNieceRoom = 'aunt_niece_room';
  static const String auntHall = 'aunt_hall';
  static const String auntYard = 'aunt_yard';
  static const String auntBasement = 'aunt_basement';

  // Ключі кімнат сусідського будинку (9 кімнат)
  static const String neighborCorridor = 'neighbor_corridor';
  static const String neighborKitchen = 'neighbor_kitchen';
  static const String neighborRoom = 'neighbor_room';
  static const String neighborBathroom = 'neighbor_bathroom';
  static const String neighborParentsRoom = 'neighbor_parents_room';
  static const String neighborChild1 = 'neighbor_child_1';
  static const String neighborChild2 = 'neighbor_child_2';
  static const String neighborHall = 'neighbor_hall';
  static const String neighborYard = 'neighbor_yard';
  static const String neighborBasement = 'neighbor_basement';

  // Ключі кімнат будинку однокласниці (9 кімнат)
  static const String classmateCorridor = 'classmate_corridor';
  static const String classmateKitchen = 'classmate_kitchen';
  static const String classmateRoom = 'classmate_room';
  static const String classmateBathroom = 'classmate_bathroom';
  static const String classmateParentsRoom = 'classmate_parents_room';
  static const String classmateBrotherRoom = 'classmate_brother_room';
  static const String classmateSisterRoom = 'classmate_sister_room';
  static const String classmateHall = 'classmate_hall';
  static const String classmateYard = 'classmate_yard';
  static const String classmateBasement = 'classmate_basement';

  /// Чи [roomId] — кімната всередині будинку однокласниці на вул. Шевченка.
  static bool isClassmateHouseInteriorRoom(String? roomId) {
    if (roomId == null) return false;
    final map = streetHouseRooms[classmateHouse];
    return map != null && map.containsKey(roomId);
  }

  static Map<String, RoomData> get streetRooms => LocationsLoader.streetRooms;
  static List<String> get streetRoomIds => LocationsLoader.streetRoomIds;
  /// Будинки на вулиці: у кожного свої ключі кімнат (friend_*, aunt_*, neighbor_*, classmate_*).
  static Map<String, Map<String, RoomData>> get streetHouseRooms => LocationsLoader.streetHouseRooms;

  /// Список id кімнат для сітки будинку (коридор не показується як слот — це опціональна вхідна локація).
  static List<String> getRoomIdsForStreetHouse(String? houseId) =>
      LocationsLoader.getRoomIdsForStreetHouse(houseId);

  /// Вхідна локація будинку (коридор) — не слот, лише стан при заході та при «назад».
  static String? getFirstRoomIdForStreetHouse(String? houseId) =>
      LocationsLoader.getFirstRoomIdForStreetHouse(houseId);

  /// Кімнати будинку на вулиці.
  static Map<String, RoomData>? getRoomsForStreetHouse(String? houseId) {
    if (houseId == null) return null;
    return streetHouseRooms[houseId];
  }

  // --- City (місто): 6 слотів ---
  static const String cityOverview = 'city';
  static const String cityBusinessCenter = 'city_business_center';
  /// Логістична компанія — робоче місце Людмили (секретарки).
  static const String cityBcLogistics = 'city_bc_logistics';
  /// Кабінет мами в логістичній компанії (окрема локація для розкладу мами).
  static const String cityBcLogisticsMomOffice = 'city_bc_logistics_mom_office';
  /// Офіс шефа в логістичній компанії (підкімната [cityLogisticsRoomIds]).
  static const String cityBcLogisticsBossOffice = 'city_bc_logistics_boss_office';
  /// Gleam Team (клінінг) — лобі в БЦ; підкімнати в [cityGleamTeamRoomIds].
  static const String cityBcGleamTeam = 'city_bc_gleam_team';
  static const String cityBcGleamTeamProjects = 'city_bc_gleam_team_projects';
  static const String cityBcGleamTeamCabinet = 'city_bc_gleam_team_cabinet';
  static const String cityBcCallCenter = 'city_bc_call_center';
  static const String cityBcCallCenterOperatorsHall = 'city_bc_call_center_operators_hall';
  static const String cityBcCallCenterBossOffice = 'city_bc_call_center_boss_office';
  static const String cityBcRockefellerOffice = 'city_bc_rockefeller_office';
  /// Логічна кімната розкладу: внутрішній офіс боса (гравець у холі компанії — `cityBcRockefellerOffice`).
  static const String cityBcRockefellerCabinet = 'city_bc_rockefeller_cabinet';
  static const String cityMall = 'city_mall';
  static const String cityCarDealership = 'city_car_dealership';
  static const String cityCarDealershipShowroom = 'city_car_dealership_showroom';
  static const String cityCarDealershipWorkshop = 'city_car_dealership_workshop';
  static const String cityPark = 'city_park';
  static const String cityParkCafe = 'city_park_cafe';
  static const String cityParkCoffee = 'city_park_coffee';
  static List<String> get cityParkRoomIds => LocationsLoader.cityParkRoomIds;
  /// ID для прихованої камери в офісі мами (ноутбук + встановлення камери).
  static const String momOfficeCamera = 'mom_office';
  static const String cityEliteResidential = 'city_elite_residential';
  static const String cityVipGym = 'city_vip_gym';
  static const String cityVipGymReception = 'city_vip_gym_reception';
  static const String cityVipGymHall = 'city_vip_gym_hall';
  static const String cityVipGymWrestling = 'city_vip_gym_wrestling';
  static const String cityVipGymSpa = 'city_vip_gym_spa';
  static const String cityVipGymSauna = 'city_vip_gym_sauna';
  static const String cityVipGymMassage = 'city_vip_gym_massage';

  static List<String> get cityVipGymRoomIds => LocationsLoader.cityVipGymRoomIds;

  static List<String> get cityCarDealershipRoomIds => LocationsLoader.cityCarDealershipRoomIds;

  static List<String> get cityGleamTeamRoomIds => LocationsLoader.cityGleamTeamRoomIds;

  static List<String> get cityLogisticsRoomIds => LocationsLoader.cityLogisticsRoomIds;

  // --- Бідний район ---
  static const String poorDistrictOverview = 'poor_district_overview';
  static const String poorDistrictGym = 'poor_district_gym';
  static const String poorDistrictShop = 'poor_district_shop';
  static const String poorDistrictStripBar = 'poor_district_strip_bar';
  static const String poorDistrictStripBarVip = 'poor_district_strip_bar_vip';
  static const String poorDistrictStripBarToilet = 'poor_district_strip_bar_toilet';
  static const String poorDistrictDarkAlley = 'poor_district_dark_alley';
  static const String poorDistrictResidential = 'poor_district_residential';
  static const String poorDistrictHotel = 'poor_district_hotel';

  /// Спальні будинки: огляд 2 будинків (сітка), потім квартири, потім кімнати.
  static const String poorDistrictResidentialOverview = 'poor_district_residential_overview';

  static const String poorDistrictHouse1 = PoorDistrictHouse1.id;
  static const String poorDistrictHouse2 = PoorDistrictHouse2.id;
  /// Спальня кв. 2, Бандери 2 (Zazie + Geisha).
  static const String poorDistrictH2Apt2Bedroom = PoorDistrictHouse2.rA2_4;

  static const List<String> poorDistrictResidentialHouseIds = [
    poorDistrictHouse1,
    poorDistrictHouse2,
  ];

  static List<String> get poorDistrictStripBarRoomIds =>
      LocationsLoader.poorDistrictStripBarRoomIds;

  static List<String> getPoorDistrictApartmentIds(String houseId) {
    if (houseId == poorDistrictHouse1) return List.from(PoorDistrictHouse1.apartmentIds);
    if (houseId == poorDistrictHouse2) return List.from(PoorDistrictHouse2.apartmentIds);
    return [];
  }

  static List<String> getPoorDistrictRoomIdsForApartment(String apartmentId) {
    final fromH1 = PoorDistrictHouse1.getRoomIdsForApartment(apartmentId);
    if (fromH1.isNotEmpty) return fromH1;
    return PoorDistrictHouse2.getRoomIdsForApartment(apartmentId);
  }

  /// Кімната на один рівень вище (для кнопки «Назад»): кімната->квартира->будинок->огляд->район.
  static String? getPoorDistrictBackRoom(String roomId) {
    if (roomId == poorDistrictResidentialOverview) return poorDistrictOverview;
    if (roomId == poorDistrictStripBar) return poorDistrictOverview;
    if (poorDistrictStripBarRoomIds.contains(roomId)) return poorDistrictStripBar;
    if (roomId == poorDistrictHouse1 || roomId == poorDistrictHouse2) return poorDistrictResidentialOverview;
    if (PoorDistrictHouse1.apartmentIds.contains(roomId)) return poorDistrictHouse1;
    if (PoorDistrictHouse2.apartmentIds.contains(roomId)) return poorDistrictHouse2;
    for (final aptId in PoorDistrictHouse1.apartmentIds) {
      if (PoorDistrictHouse1.getRoomIdsForApartment(aptId).contains(roomId)) return aptId;
    }
    for (final aptId in PoorDistrictHouse2.apartmentIds) {
      if (PoorDistrictHouse2.getRoomIdsForApartment(aptId).contains(roomId)) return aptId;
    }
    return null;
  }

  static bool isPoorDistrictResidentialGrid(String roomId) {
    return roomId == poorDistrictResidentialOverview ||
        roomId == poorDistrictHouse1 ||
        roomId == poorDistrictHouse2 ||
        PoorDistrictHouse1.apartmentIds.contains(roomId) ||
        PoorDistrictHouse2.apartmentIds.contains(roomId);
  }

  static List<String> get poorDistrictRoomIds => LocationsLoader.poorDistrictRoomIds;

  // --- Мажорщина (зона POOR_VILLAGE, id poor_village_* у даних) ---
  static const String poorVillageOverview = 'poor_village_overview';
  static const String poorVillageHouseHeadTeacher = 'poor_village_house_head_teacher';
  static const String poorVillageHouseKaty = 'poor_village_house_katy';
  static const String poorVillageKatyRoom1 = 'poor_village_katy_room_1';
  static const String poorVillageKatyRoom2 = 'poor_village_katy_room_2';
  static const String poorVillageHouseEnglishwoman = 'poor_village_house_englishwoman';
  static const String poorVillageHouseLogisticsBoss = 'poor_village_house_logistics_boss';
  static const String poorVillageHouseGiftShopOwner = 'poor_village_house_gift_shop_owner';
  /// Будинок Cherie (Мажорщина): кімнати для проживання.
  static const String poorVillageGiftShopOwnerRoom1 = 'poor_village_gift_shop_owner_room_1';
  static const String poorVillageGiftShopOwnerRoom2 = 'poor_village_gift_shop_owner_room_2';
  static const String poorVillageGiftShopOwnerRoom3 = 'poor_village_gift_shop_owner_room_3';
  static const String poorVillageGiftShopOwnerKitchen = 'poor_village_gift_shop_owner_kitchen';
  static const String poorVillageGiftShopOwnerBathroom =
      'poor_village_gift_shop_owner_bathroom';
  static const String poorVillageGiftShopOwnerHall = 'poor_village_gift_shop_owner_hall';
  static const String poorVillageHouseCallCenterBoss = 'poor_village_house_call_center_boss';
  /// Спальня в домі декана/завуча (Мажорщина).
  static const String poorVillageHeadTeacherBedroom = 'poor_village_head_teacher_bedroom';
  /// Кімната Naomi (донька декана) у будинку декана.
  static const String poorVillageHeadTeacherRoom = 'poor_village_head_teacher_room';
  /// Кімнати в домі начальника логістичної компанії (Мажорщина).
  static const String poorVillageLogisticsBossRoom2 = 'poor_village_logistics_boss_room_2';
  static const String poorVillageLogisticsBossRoom3 = 'poor_village_logistics_boss_room_3';
  /// Кімнати в домі шефа колцентру (Мажорщина).
  static const String poorVillageCallCenterBossRoom1 = 'poor_village_call_center_boss_room_1';
  static const String poorVillageCallCenterBossRoom2 = 'poor_village_call_center_boss_room_2';
  static const String poorVillageCallCenterBossRoom3 = 'poor_village_call_center_boss_room_3';
  /// Зал у домі Amia (колишній «дім англічанки»).
  static const String poorVillageEnglishwomanHall = 'poor_village_englishwoman_hall';
  static const String poorVillageEnglishwomanRoom1 = 'poor_village_englishwoman_room_1';

  static List<String> get poorVillageRoomIds => LocationsLoader.poorVillageRoomIds;

  static const Map<String, List<String>> _poorVillageRoomsForHouse = {
    poorVillageHouseHeadTeacher: [
      'poor_village_head_teacher_kitchen',
      'poor_village_head_teacher_bathroom',
      'poor_village_head_teacher_hall',
      'poor_village_head_teacher_bedroom',
      'poor_village_head_teacher_yard',
      'poor_village_head_teacher_room',
    ],
    poorVillageHouseKaty: [
      'poor_village_katy_kitchen',
      'poor_village_katy_bathroom',
      'poor_village_katy_hall',
      'poor_village_katy_room_1',
      'poor_village_katy_room_2',
      'poor_village_katy_room_3',
    ],
    poorVillageHouseEnglishwoman: [
      'poor_village_englishwoman_kitchen',
      'poor_village_englishwoman_bathroom',
      'poor_village_englishwoman_hall',
      'poor_village_englishwoman_room_1',
      'poor_village_englishwoman_room_2',
      'poor_village_englishwoman_room_3',
    ],
    poorVillageHouseLogisticsBoss: [
      'poor_village_logistics_boss_kitchen',
      'poor_village_logistics_boss_bathroom',
      'poor_village_logistics_boss_hall',
      'poor_village_logistics_boss_room_1',
      'poor_village_logistics_boss_room_2',
      'poor_village_logistics_boss_room_3',
    ],
    poorVillageHouseGiftShopOwner: [
      'poor_village_gift_shop_owner_kitchen',
      'poor_village_gift_shop_owner_bathroom',
      'poor_village_gift_shop_owner_hall',
      'poor_village_gift_shop_owner_room_1',
      'poor_village_gift_shop_owner_room_2',
      'poor_village_gift_shop_owner_room_3',
    ],
    poorVillageHouseCallCenterBoss: [
      'poor_village_call_center_boss_kitchen',
      'poor_village_call_center_boss_bathroom',
      'poor_village_call_center_boss_hall',
      'poor_village_call_center_boss_room_1',
      'poor_village_call_center_boss_room_2',
      'poor_village_call_center_boss_room_3',
    ],
  };

  static List<String> getPoorVillageRoomIdsForHouse(String houseId) {
    return List<String>.from(_poorVillageRoomsForHouse[houseId] ?? const []);
  }

  static String? getPoorVillageBackRoom(String roomId) {
    if (roomId == poorVillageOverview) return null;
    if (_poorVillageRoomsForHouse.containsKey(roomId)) return poorVillageOverview;
    for (final entry in _poorVillageRoomsForHouse.entries) {
      if (entry.value.contains(roomId)) return entry.key;
    }
    return poorVillageOverview;
  }

  // --- На море (за місто) ---
  static const String outOfTownOverview = 'out_of_town_overview';
  static const String outOfTownPromenade = 'out_of_town_promenade';
  static const String outOfTownBeach = 'out_of_town_beach';
  static const String outOfTownClub = 'out_of_town_club';
  static const String outOfTownClubBar = 'out_of_town_club_bar';
  static const String outOfTownClubToilet = 'out_of_town_club_toilet';
  static const String outOfTownPier = 'out_of_town_pier';

  static List<String> get outOfTownRoomIds => LocationsLoader.outOfTownRoomIds;
  static List<String> get outOfTownClubRoomIds => LocationsLoader.outOfTownClubRoomIds;

  static List<String> get cityBusinessCenterRoomIds => LocationsLoader.cityBusinessCenterRoomIds;

  static const String cityMallShop = 'city_mall_shop';
  static const String cityMallPharmacy = 'city_mall_pharmacy';
  static const String cityMallGiftShop = 'city_mall_gift_shop';
  /// Підкімнати магазину подарунків у ТРЦ (з головного залу).
  static const String cityMallGiftShopOffice = 'city_mall_gift_shop_office';
  static const String cityMallGiftShopWarehouse = 'city_mall_gift_shop_warehouse';
  /// Фон залу магазину подарунків у ТРЦ — має збігатися з `city_mall_gift_shop.imagePath` у `assets/data/location.json`.
  static const String cityMallGiftShopImagePath = 'lib/assets/location/trc/gift_shop.jpg';

  static const String _cityMallDefaultInteriorImagePath =
      'lib/assets/location/trc/shop.jpg';

  /// Картинка інтер'єру магазину ТРЦ з `cityRooms` / `assets/data/location.json`.
  static String cityMallRoomInteriorBackgroundPath(String mallRoomId) {
    final room = cityRooms[mallRoomId];
    if (room == null) return _cityMallDefaultInteriorImagePath;
    final p = room.imagePath.trim();
    if (p.isNotEmpty) return p;
    return _cityMallDefaultInteriorImagePath;
  }

  static const String cityMallSexShop = 'city_mall_sex_shop';
  static const String cityMallElectronics = 'city_mall_electronics';
  static const String cityMallCinema = 'city_mall_cinema';
  /// Ресторан у ТРЦ (2 підлокації всередині).
  static const String cityMallRestaurantHall = 'city_mall_restaurant_hall';
  static const String cityMallRestaurantVip = 'city_mall_restaurant_vip';

  static List<String> get cityMallRoomIds => LocationsLoader.cityMallRoomIds;

  /// Старі id з сейвів до рефакторингу «flower shop» → gift shop.
  static const Map<String, String> _legacyRoomIds = {
    'city_mall_flower_shop': cityMallGiftShop,
    'city_mall_flower_shop_office': cityMallGiftShopOffice,
    'city_mall_flower_shop_warehouse': cityMallGiftShopWarehouse,
    'poor_village_house_flower_owner': poorVillageHouseGiftShopOwner,
    'poor_village_flower_owner_kitchen': 'poor_village_gift_shop_owner_kitchen',
    'poor_village_flower_owner_bathroom': 'poor_village_gift_shop_owner_bathroom',
    'poor_village_flower_owner_hall': 'poor_village_gift_shop_owner_hall',
    'poor_village_flower_owner_room_1': 'poor_village_gift_shop_owner_room_1',
    'poor_village_flower_owner_room_2': 'poor_village_gift_shop_owner_room_2',
    'poor_village_flower_owner_room_3': 'poor_village_gift_shop_owner_room_3',
  };

  static String migrateLegacyRoomId(String roomId) =>
      _legacyRoomIds[roomId] ?? roomId;

  static bool isMallAreaRoom(String roomId) =>
      roomId == cityMall || roomId.startsWith('city_mall_');

  static const String cityEliteApartment1 = 'city_elite_apt_1';
  static const String cityEliteApartment1Bedroom = 'city_elite_apt_1_bedroom';
  static const String cityEliteApartment2 = 'city_elite_apt_2';
  static const String cityEliteApartment2Bedroom = 'city_elite_apt_2_bedroom';
  static const String cityEliteApartment3 = 'city_elite_apt_3';
  static const String cityEliteApartment4 = 'city_elite_apt_4';
  static const String cityEliteApartment5 = 'city_elite_apt_5';
  static const String cityEliteApartment6 = 'city_elite_apt_6';
  /// Кімната в елітному ЖК (квартира 6).
  static const String cityEliteApartment6Room = 'city_elite_apt_6_room';

  static List<String> get cityEliteResidentialRoomIds => LocationsLoader.cityEliteResidentialRoomIds;

  /// Кімнати всередині квартири елітного ЖК (кухня, ванна, зал, спальня, кімната + шоста залежно від квартири).
  static List<String> cityEliteInnerRoomIdsForApartment(String apartmentId) {
    if (!cityEliteResidentialRoomIds.contains(apartmentId)) return const [];
    late final String sixthId;
    if (apartmentId == cityEliteApartment1 ||
        apartmentId == cityEliteApartment2 ||
        apartmentId == cityEliteApartment3) {
      sixthId = '${apartmentId}_terrace';
    } else if (apartmentId == cityEliteApartment4) {
      sixthId = '${apartmentId}_sauna';
    } else if (apartmentId == cityEliteApartment5) {
      sixthId = '${apartmentId}_pool';
    } else if (apartmentId == cityEliteApartment6) {
      sixthId = '${apartmentId}_office';
    } else {
      return const [];
    }
    return [
      '${apartmentId}_kitchen',
      '${apartmentId}_bathroom',
      '${apartmentId}_hall',
      '${apartmentId}_bedroom',
      '${apartmentId}_room',
      sixthId,
    ];
  }

  /// `city_elite_apt_N` для внутрішньої кімнати, інакше `null`.
  static String? getCityEliteApartmentIdForInnerRoom(String roomId) {
    for (final apt in cityEliteResidentialRoomIds) {
      if (roomId.startsWith('${apt}_')) return apt;
    }
    return null;
  }

  /// Кімнати міста (не магазини з сіткою товарів), де NPC показуємо оверлеєм знизу на фоні кімнати —
  /// узгоджено з роумінгом [NpcCityRoamingService] та внутрішніми кімнатами БЦ / ТРЦ / ЖК / VIP.
  static bool isCityRoomNpcBottomOverlayScene(String roomId) {
    if (cityParkRoomIds.contains(roomId)) return true;
    if (roomId == cityCarDealershipShowroom || roomId == cityCarDealershipWorkshop) {
      return true;
    }
    if (cityVipGymRoomIds.contains(roomId)) return true;
    if (roomId == cityMallRestaurantHall || roomId == cityMallRestaurantVip) {
      return true;
    }
    if (getCityEliteApartmentIdForInnerRoom(roomId) != null) return true;
    if (cityGleamTeamRoomIds.contains(roomId)) return true;
    if (cityLogisticsRoomIds.contains(roomId)) return true;
    if (roomId == cityBcCallCenterOperatorsHall || roomId == cityBcCallCenterBossOffice) {
      return true;
    }
    if (roomId == cityBcLogisticsMomOffice) return true;
    if (roomId == cityMallGiftShopOffice || roomId == cityMallGiftShopWarehouse) {
      return true;
    }
    return false;
  }

  static Map<String, RoomData> get cityRooms => LocationsLoader.cityRooms;

  static Map<String, RoomData> get poorDistrictRooms => LocationsLoader.poorDistrictRooms;

  static Map<String, RoomData> get poorVillageRooms => LocationsLoader.poorVillageRooms;

  static Map<String, RoomData> get outOfTownRooms => LocationsLoader.outOfTownRooms;

  static List<String> get cityRoomIds => LocationsLoader.cityRoomIds;

  static String _localizedRoomTitle(RoomData? r, String fallbackId) {
    if (r == null) return fallbackId;
    if (sl.isRegistered<LocaleController>() &&
        sl<LocaleController>().locale == localeEn) {
      final en = r.displayNameEn;
      if (en != null && en.isNotEmpty) return en;
    }
    return r.displayName;
  }

  /// Назва кімнати для відображення в слотах та заголовку.
  /// Якщо [streetHouseId] задано, пошук у кімнатах цього будинку (friend_kitchen тощо).
  static String getRoomDisplayName(
    String roomId, {
    bool isCollege = false,
    bool isStreet = false,
    bool isCity = false,
    bool isPoorDistrict = false,
    bool isPoorVillage = false,
    bool isOutOfTown = false,
    String? streetHouseId,
  }) {
    if (isCollege) return _localizedRoomTitle(collegeRooms[roomId], roomId);
    if (streetHouseId != null) {
      final r = streetHouseRooms[streetHouseId]?[roomId];
      if (r != null) return _localizedRoomTitle(r, roomId);
    }
    if (isStreet) return _localizedRoomTitle(streetRooms[roomId], roomId);
    if (isCity) return _localizedRoomTitle(cityRooms[roomId], roomId);
    if (isPoorDistrict) return _localizedRoomTitle(poorDistrictRooms[roomId], roomId);
    if (isPoorVillage) return _localizedRoomTitle(poorVillageRooms[roomId], roomId);
    if (isOutOfTown) return _localizedRoomTitle(outOfTownRooms[roomId], roomId);
    final fromOffice = officeRooms[roomId];
    if (fromOffice != null) return _localizedRoomTitle(fromOffice, roomId);
    return _localizedRoomTitle(homeRooms[roomId], roomId);
  }

  /// Назва локації за roomId для будь-якої зони (телефон, логи тощо).
  static String getLocationDisplayName(String roomId) {
    final fromHome = homeRooms[roomId];
    if (fromHome != null) return _localizedRoomTitle(fromHome, roomId);
    final fromCollege = collegeRooms[roomId];
    if (fromCollege != null) return _localizedRoomTitle(fromCollege, roomId);
    final fromCity = cityRooms[roomId];
    if (fromCity != null) return _localizedRoomTitle(fromCity, roomId);
    final fromPoorDistrict = poorDistrictRooms[roomId];
    if (fromPoorDistrict != null) return _localizedRoomTitle(fromPoorDistrict, roomId);
    final fromPoorVillage = poorVillageRooms[roomId];
    if (fromPoorVillage != null) return _localizedRoomTitle(fromPoorVillage, roomId);
    final fromOutOfTown = outOfTownRooms[roomId];
    if (fromOutOfTown != null) return _localizedRoomTitle(fromOutOfTown, roomId);
    final fromStreet = streetRooms[roomId];
    if (fromStreet != null) return _localizedRoomTitle(fromStreet, roomId);
    for (final houseRooms in streetHouseRooms.values) {
      final r = houseRooms[roomId];
      if (r != null) return _localizedRoomTitle(r, roomId);
    }
    final fromOffice = officeRooms[roomId];
    if (fromOffice != null) return _localizedRoomTitle(fromOffice, roomId);
    return roomId;
  }

  /// Загальна локація для телефону: Дім, Коледж, ТРЦ тощо (без конкретної кімнати).
  static String getGeneralLocationName(String roomId) {
    String tr(String key, String uk) {
      if (!sl.isRegistered<LocaleController>()) return uk;
      final s = sl<LocaleController>().t(key);
      return s != key ? s : uk;
    }

    if (homeRooms.containsKey(roomId)) return tr('loc_area_home', 'Дім');
    if (collegeRooms.containsKey(roomId)) return tr('loc_area_college', 'Коледж');
    if (streetRooms.containsKey(roomId)) return tr('loc_area_street', 'Вулиця');
    for (final houseRooms in streetHouseRooms.values) {
      if (houseRooms.containsKey(roomId)) return tr('loc_area_street', 'Вулиця');
    }
    if (roomId == cityOverview) return tr('loc_area_city', 'Місто');
    if (roomId == cityBusinessCenter ||
        cityBusinessCenterRoomIds.contains(roomId) ||
        cityGleamTeamRoomIds.contains(roomId) ||
        cityLogisticsRoomIds.contains(roomId) ||
        roomId == cityBcLogisticsMomOffice ||
        roomId == cityBcCallCenterOperatorsHall ||
        roomId == cityBcCallCenterBossOffice ||
        roomId == cityBcRockefellerCabinet) {
      return tr('loc_area_business_center', 'Бізнес-центр');
    }
    if (isMallAreaRoom(roomId) || cityMallRoomIds.contains(roomId)) {
      return tr('loc_area_mall', 'ТРЦ');
    }
    if (roomId == cityPark || cityParkRoomIds.contains(roomId)) {
      return tr('loc_area_park', 'Парк');
    }
    if (roomId == cityCarDealership || cityCarDealershipRoomIds.contains(roomId)) {
      return tr('loc_area_car_dealership', 'Автосалон');
    }
    if (roomId == cityEliteResidential ||
        cityEliteResidentialRoomIds.contains(roomId) ||
        getCityEliteApartmentIdForInnerRoom(roomId) != null) {
      return tr('loc_area_elite', 'Елітний ЖК');
    }
    if (roomId == cityVipGym || cityVipGymRoomIds.contains(roomId)) {
      return tr('loc_area_vip_gym', 'VIP зал');
    }
    if (cityRooms.containsKey(roomId)) return tr('loc_area_city', 'Місто');
    if (poorDistrictRooms.containsKey(roomId)) {
      return tr('loc_area_poor_district', 'Бідний р-н');
    }
    if (poorVillageRooms.containsKey(roomId)) {
      return tr('loc_area_poor_village', 'Мажорщина');
    }
    if (outOfTownRooms.containsKey(roomId)) {
      return tr('loc_area_out_of_town', 'На море');
    }
    if (officeRooms.containsKey(roomId)) return tr('loc_area_office', 'Офіс');
    return roomId;
  }

  static Map<String, RoomData> get officeRooms => LocationsLoader.officeRooms;
}
