import '../models/room_models.dart';

class LocationsData {
  // --- Home: English id constants ---
  static const String corridor = 'corridor';
  static const String kitchen = 'kitchen';
  static const String roomGg = 'room_gg';
  static const String bathroom = 'bathroom';
  static const String momRoom = 'mom_room';
  static const String kiraRoom = 'kira_room';
  static const String ritaRoom = 'rita_room';
  static const String hall = 'hall';
  static const String yard = 'yard';
  static const String basement = 'basement';

  static const Map<String, RoomData> homeRooms = {
    'corridor': RoomData(
      displayName: "Коридор",
      imagePath: "lib/assets/home_gg/rooms/default.jpg",
      description: "Коридор будинку.",
      isLocked: false,
    ),
    'kitchen': RoomData(
      displayName: "Кухня",
      imagePath: "lib/assets/home_gg/rooms/kitchen.jpg",
      description: "На кухні нікого немає",
      isLocked: false,
    ),
    'room_gg': RoomData(
      displayName: "Кімната гг",
      imagePath: "lib/assets/home_gg/rooms/room_gg.jpg",
      description: "Твоя кімната. Тут панує творчий безлад.",
      isLocked: false,
    ),
    'bathroom': RoomData(
      displayName: "Ванна",
      imagePath: "lib/assets/home_gg/rooms/bathroom.jpg",
      description: "У ванній пахне милом, тут пусто.",
      isLocked: false,
    ),
    'mom_room': RoomData(
      displayName: "Кімната мами",
      imagePath: "lib/assets/home_gg/rooms/mom_room.jpg",
      description: "Кімната мами.",
      isLocked: false,
    ),
    'kira_room': RoomData(
      displayName: "Кімната Кіри",
      imagePath: "lib/assets/home_gg/rooms/kira_room.jpg",
      description: "Кімната Кіри, тут нікого немає.",
      isLocked: false,
    ),
    'rita_room': RoomData(
      displayName: "Кімната Ріти",
      imagePath: "lib/assets/home_gg/rooms/rita_room.jpg",
      description: "Кімната Ріти, тут нікого немає.",
      isLocked: false,
    ),
    'hall': RoomData(
      displayName: "Зал",
      imagePath: "lib/assets/home_gg/rooms/relax_room.jpg",
      description: "Зал.",
      isLocked: false,
    ),
    'yard': RoomData(
      displayName: "Подвірʼя",
      imagePath: "lib/assets/home_gg/rooms/yard.webp",
      description: "Подвірʼя.",
      isLocked: false,
    ),
    'basement': RoomData(
      displayName: "Підвал",
      imagePath: "lib/assets/home_gg/rooms/closed_door.jpg",
      description: "Підвал зараз закритий, ключі у мами.",
      isLocked: true,
    ),
  };

  static const List<String> homeRoomIds = [
    roomGg,
    kitchen,
    bathroom,
    momRoom,
    kiraRoom,
    ritaRoom,
    hall,
    yard,
    basement,
  ];

  // --- College: English id constants ---
  static const String collegeHall = 'college_hall';
  static const String auditorium1 = 'auditorium_1';
  static const String auditorium2 = 'auditorium_2';
  static const String auditorium3 = 'auditorium_3';
  static const String library = 'library';
  static const String directorOffice = 'director_office';
  static const String canteen = 'canteen';
  static const String gym = 'gym';
  static const String collegeYard = 'college_yard';
  static const String toilet = 'toilet';

  static const Map<String, RoomData> collegeRooms = {
    'college_hall': RoomData(
      displayName: "Хол",
      imagePath: "lib/assets/home_gg/rooms/default.jpg",
      description: "Головний хол коледжу.",
      isLocked: false,
    ),
    'auditorium_1': RoomData(
      displayName: "Англійська",
      imagePath: "lib/assets/college/rooms/audit_1.jpg",
      description: "Лекційна аудиторія.",
      isLocked: false,
    ),
    'auditorium_2': RoomData(
      displayName: "Математика",
      imagePath: "lib/assets/college/rooms/audit_2.jpeg",
      description: "Лекційна аудиторія.",
      isLocked: false,
    ),
    'auditorium_3': RoomData(
      displayName: "Історія",
      imagePath: "lib/assets/college/rooms/audit_3.jpg",
      description: "Лекційна аудиторія.",
      isLocked: false,
    ),
    'library': RoomData(
      displayName: "Бібліотека",
      imagePath: "lib/assets/college/rooms/lib.jpg",
      description: "Коледжна бібліотека.",
      isLocked: false,
    ),
    'director_office': RoomData(
      displayName: "Кабінет директора",
      imagePath: "lib/assets/college/rooms/office.jpg",
      description: "Кабінет директора коледжу.",
      isLocked: false,
    ),
    'canteen': RoomData(
      displayName: "Столова",
      imagePath: "lib/assets/college/rooms/dining_room.jpg",
      description: "Коледжна столова.",
      isLocked: false,
    ),
    'gym': RoomData(
      displayName: "Спортзал",
      imagePath: "lib/assets/college/rooms/gym_room.jpg",
      description: "Спортивний зал.",
      isLocked: false,
    ),
    'college_yard': RoomData(
      displayName: "Двір коледжу",
      imagePath: "lib/assets/college/rooms/stadion.jpg",
      description: "Подвірʼя коледжу.",
      isLocked: false,
    ),
    'toilet': RoomData(
      displayName: "Туалет",
      imagePath: "lib/assets/college/rooms/tualet.jpg",
      description: "Гардеробна.",
      isLocked: false,
    ),
  };

  static const List<String> collegeRoomIds = [
    auditorium1,
    auditorium2,
    auditorium3,
    library,
    directorOffice,
    canteen,
    gym,
    collegeYard,
    toilet,
  ];

  // --- Street: English id constants (4 будинки) ---
  static const String street = 'street';
  static const String friendHouse = 'friend_house';
  static const String auntHouse = 'aunt_house';
  static const String neighborHouse = 'neighbor_house';
  static const String classmateHouse = 'classmate_house';

  // Ключі кімнат будинку кориша (6 кімнат)
  static const String friendCorridor = 'friend_corridor';
  static const String friendKitchen = 'friend_kitchen';
  static const String friendRoom = 'friend_room';
  static const String friendBathroom = 'friend_bathroom';
  static const String friendParentsRoom = 'friend_parents_room';
  static const String friendSisterRoom = 'friend_sister_room';
  static const String friendHall = 'friend_hall';

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

  static const Map<String, RoomData> streetRooms = {
    'street': RoomData(
      displayName: "Вулиця",
      imagePath: "lib/assets/home_gg/rooms/default.jpg",
      description: "Вулиця.",
      isLocked: false,
    ),
    'friend_house': RoomData(
      displayName: "Дім кориша",
      imagePath: "lib/assets/houses/friend_home.jpg",
      description: "Будинок кориша.",
      isLocked: false,
    ),
    'aunt_house': RoomData(
      displayName: "Дім тітки",
      imagePath: "lib/assets/houses/aunt_home.jpg",
      description: "Будинок тітки.",
      isLocked: false,
    ),
    'neighbor_house': RoomData(
      displayName: "Сусідський дім",
      imagePath: "lib/assets/houses/neighbor.jpg",
      description: "Будинок сусідів.",
      isLocked: false,
    ),
    'classmate_house': RoomData(
      displayName: "Дім однокласниці",
      imagePath: "lib/assets/houses/classmate_home.jpg",
      description: "Будинок однокласниці.",
      isLocked: false,
    ),
  };

  static const List<String> streetRoomIds = [
    friendHouse,
    auntHouse,
    neighborHouse,
    classmateHouse,
  ];

  /// Будинки на вулиці: у кожного свої ключі кімнат (friend_*, aunt_*, neighbor_*, classmate_*).
  static const Map<String, Map<String, RoomData>> streetHouseRooms = {

    ///---------------------Будинок кориша----------------------------------------
    friendHouse: {
      friendCorridor: RoomData(
        displayName: "Коридор",
        imagePath: "lib/assets/houses/friend_home.jpg",
        description: "Коридор будинку кориша.",
        isLocked: false,
      ),
      friendKitchen: RoomData(
        displayName: "Кухня",
        imagePath: "lib/assets/houses/friend_home.jpg",
        description: "Кухня в будинку кориша.",
        isLocked: false,
      ),
      friendRoom: RoomData(
        displayName: "Кімната кориша",
        imagePath: "lib/assets/houses/friend_home.jpg",
        description: "Кімната твого друга.",
        isLocked: false,
      ),
      friendBathroom: RoomData(
        displayName: "Ванна",
        imagePath: "lib/assets/houses/friend_home.jpg",
        description: "Ванна.",
        isLocked: false,
      ),
      friendParentsRoom: RoomData(
        displayName: "Кімната батьків",
        imagePath: "lib/assets/houses/friend_home.jpg",
        description: "Кімната батьків.",
        isLocked: false,
      ),
      friendSisterRoom: RoomData(
        displayName: "Кімната сестри",
        imagePath: "lib/assets/houses/friend_home.jpg",
        description: "Кімната сестри.",
        isLocked: false,
      ),
      friendHall: RoomData(
        displayName: "Зал",
        imagePath: "lib/assets/houses/friend_home.jpg",
        description: "Зал.",
        isLocked: false,
      ),
    },
    ///---------------------Будинок тітки----------------------------------------
    auntHouse: {
      auntCorridor: RoomData(
        displayName: "Коридор",
        imagePath: "lib/assets/houses/aunt_home.jpg",
        description: "Коридор будинку тітки.",
        isLocked: false,
      ),
      auntKitchen: RoomData(
        displayName: "Кухня",
        imagePath: "lib/assets/houses/aunt_home.jpg",
        description: "Кухня в будинку тітки.",
        isLocked: false,
      ),
      auntRoom: RoomData(
        displayName: "Кімната тітки",
        imagePath: "lib/assets/houses/aunt_home.jpg",
        description: "Кімната тітки.",
        isLocked: false,
      ),
      auntBathroom: RoomData(
        displayName: "Ванна",
        imagePath: "lib/assets/houses/aunt_home.jpg",
        description: "Ванна.",
        isLocked: false,
      ),
      auntGuestRoom: RoomData(
        displayName: "Гостьова",
        imagePath: "lib/assets/houses/aunt_home.jpg",
        description: "Гостьова кімната.",
        isLocked: false,
      ),
      auntNieceRoom: RoomData(
        displayName: "Кімната племінниці",
        imagePath: "lib/assets/houses/aunt_home.jpg",
        description: "Кімната племінниці.",
        isLocked: false,
      ),
      auntHall: RoomData(
        displayName: "Зал",
        imagePath: "lib/assets/houses/aunt_home.jpg",
        description: "Зал.",
        isLocked: false,
      ),
    },
    ///---------------------Будинок сусідки----------------------------------------
    neighborHouse: {
      neighborCorridor: RoomData(
        displayName: "Коридор",
        imagePath: "lib/assets/houses/neighbor.jpg",
        description: "Коридор сусідського будинку.",
        isLocked: false,
      ),
      neighborKitchen: RoomData(
        displayName: "Кухня",
        imagePath: "lib/assets/houses/neighbor.jpg",
        description: "Кухня у сусідів.",
        isLocked: false,
      ),
      neighborBathroom: RoomData(
        displayName: "Ванна",
        imagePath: "lib/assets/houses/neighbor.jpg",
        description: "Ванна.",
        isLocked: false,
      ),
      neighborParentsRoom: RoomData(
        displayName: "Кімната батьків",
        imagePath: "lib/assets/houses/neighbor.jpg",
        description: "Кімната батьків.",
        isLocked: false,
      ),
      neighborChild1: RoomData(
        displayName: "Дитяча 1",
        imagePath: "lib/assets/houses/neighbor.jpg",
        description: "Дитяча кімната.",
        isLocked: false,
      ),
      neighborChild2: RoomData(
        displayName: "Дитяча 2",
        imagePath: "lib/assets/houses/neighbor.jpg",
        description: "Дитяча кімната.",
        isLocked: false,
      ),
      neighborHall: RoomData(
        displayName: "Зал",
        imagePath: "lib/assets/houses/neighbor.jpg",
        description: "Зал.",
        isLocked: false,
      ),
    },
    ///---------------------Будинок однокласниці----------------------------------------
    classmateHouse: {
      classmateCorridor: RoomData(
        displayName: "Коридор",
        imagePath: "lib/assets/houses/classmate_home.jpg",
        description: "Коридор будинку однокласниці.",
        isLocked: false,
      ),
      classmateKitchen: RoomData(
        displayName: "Кухня",
        imagePath: "lib/assets/houses/classmate_home.jpg",
        description: "Кухня.",
        isLocked: false,
      ),
      classmateRoom: RoomData(
        displayName: "Кімната однокласниці",
        imagePath: "lib/assets/houses/classmate_home.jpg",
        description: "Кімната однокласниці.",
        isLocked: false,
      ),
      classmateBathroom: RoomData(
        displayName: "Ванна",
        imagePath: "lib/assets/houses/classmate_home.jpg",
        description: "Ванна.",
        isLocked: false,
      ),
      classmateParentsRoom: RoomData(
        displayName: "Кімната батьків",
        imagePath: "lib/assets/houses/classmate_home.jpg",
        description: "Кімната батьків.",
        isLocked: false,
      ),
      classmateSisterRoom: RoomData(
        displayName: "Кімната сестри",
        imagePath: "lib/assets/houses/classmate_home.jpg",
        description: "Кімната сестри.",
        isLocked: false,
      ),
      classmateHall: RoomData(
        displayName: "Зал",
        imagePath: "lib/assets/houses/classmate_home.jpg",
        description: "Зал.",
        isLocked: false,
      ),
    },
  };

  /// Список id кімнат для сітки будинку (коридор не показується як слот — це опціональна вхідна локація).
  static List<String> getRoomIdsForStreetHouse(String? houseId) {
    if (houseId == friendHouse) {
      return [
        friendKitchen,
        friendRoom,
        friendBathroom,
        friendParentsRoom,
        friendSisterRoom,
        friendHall,
      ];
    }
    if (houseId == auntHouse) {
      return [
        auntKitchen,
        auntRoom,
        auntBathroom,
        auntGuestRoom,
        auntNieceRoom,
        auntHall,
      ];
    }
    if (houseId == neighborHouse) {
      return [
        neighborKitchen,
        neighborBathroom,
        neighborParentsRoom,
        neighborChild1,
        neighborChild2,
        neighborHall,
      ];
    }
    if (houseId == classmateHouse) {
      return [
        classmateKitchen,
        classmateRoom,
        classmateBathroom,
        classmateParentsRoom,
        classmateSisterRoom,
        classmateHall,
      ];
    }
    return [];
  }

  /// Вхідна локація будинку (коридор) — не слот, лише стан при заході та при «назад».
  static String? getFirstRoomIdForStreetHouse(String? houseId) {
    if (houseId == friendHouse) return friendCorridor;
    if (houseId == auntHouse) return auntCorridor;
    if (houseId == neighborHouse) return neighborCorridor;
    if (houseId == classmateHouse) return classmateCorridor;
    return null;
  }

  /// Кімнати будинку на вулиці.
  static Map<String, RoomData>? getRoomsForStreetHouse(String? houseId) {
    if (houseId == null) return null;
    return streetHouseRooms[houseId];
  }

  // --- City (місто): 6 слотів ---
  static const String cityOverview = 'city';
  static const String cityBusinessCenter = 'city_business_center';
  static const String cityBcLogistics = 'city_bc_logistics';
  static const String cityBcConstruction = 'city_bc_construction';
  static const String cityBcCallCenter = 'city_bc_call_center';
  static const String cityBcRockefellerOffice = 'city_bc_rockefeller_office';
  static const String cityMall = 'city_mall';
  static const String cityCarDealership = 'city_car_dealership';
  static const String cityPark = 'city_park';
  static const String cityEliteResidential = 'city_elite_residential';
  static const String cityVipGym = 'city_vip_gym';
  static const String cityVipGymReception = 'city_vip_gym_reception';
  static const String cityVipGymHall = 'city_vip_gym_hall';
  static const String cityVipGymWrestling = 'city_vip_gym_wrestling';
  static const String cityVipGymSpa = 'city_vip_gym_spa';
  static const String cityVipGymSauna = 'city_vip_gym_sauna';
  static const String cityVipGymMassage = 'city_vip_gym_massage';

  static const List<String> cityVipGymRoomIds = [
    cityVipGymReception,
    cityVipGymHall,
    cityVipGymWrestling,
    cityVipGymSpa,
    cityVipGymSauna,
    cityVipGymMassage,
  ];

  // --- Бідний район ---
  static const String poorDistrictOverview = 'poor_district_overview';
  static const String poorDistrictGym = 'poor_district_gym';
  static const String poorDistrictShop = 'poor_district_shop';
  static const String poorDistrictStripBar = 'poor_district_strip_bar';
  static const String poorDistrictDarkAlley = 'poor_district_dark_alley';
  static const String poorDistrictResidential = 'poor_district_residential';
  static const String poorDistrictHotel = 'poor_district_hotel';

  static const List<String> poorDistrictRoomIds = [
    poorDistrictGym,
    poorDistrictShop,
    poorDistrictStripBar,
    poorDistrictDarkAlley,
    poorDistrictResidential,
    poorDistrictHotel,
  ];

  // --- Село бідних людей ---
  static const String poorVillageOverview = 'poor_village_overview';
  static const String poorVillageHouseHeadTeacher = 'poor_village_house_head_teacher';
  static const String poorVillageHouseKaty = 'poor_village_house_katy';
  static const String poorVillageHouseEnglishwoman = 'poor_village_house_englishwoman';
  static const String poorVillageHouseLogisticsBoss = 'poor_village_house_logistics_boss';
  static const String poorVillageHouseFlowerOwner = 'poor_village_house_flower_owner';
  static const String poorVillageHouseCallCenterBoss = 'poor_village_house_call_center_boss';

  static const List<String> poorVillageRoomIds = [
    poorVillageHouseHeadTeacher,
    poorVillageHouseKaty,
    poorVillageHouseEnglishwoman,
    poorVillageHouseLogisticsBoss,
    poorVillageHouseFlowerOwner,
    poorVillageHouseCallCenterBoss,
  ];

  // --- На море (за місто) ---
  static const String outOfTownOverview = 'out_of_town_overview';
  static const String outOfTownPromenade = 'out_of_town_promenade';
  static const String outOfTownBeach = 'out_of_town_beach';
  static const String outOfTownClub = 'out_of_town_club';
  static const String outOfTownPier = 'out_of_town_pier';

  static const List<String> outOfTownRoomIds = [
    outOfTownPromenade,
    outOfTownBeach,
    outOfTownClub,
    outOfTownPier,
  ];

  static const List<String> cityBusinessCenterRoomIds = [
    cityBcLogistics,
    cityBcConstruction,
    cityBcCallCenter,
    cityBcRockefellerOffice,
  ];

  static const String cityMallShop = 'city_mall_shop';
  static const String cityMallPharmacy = 'city_mall_pharmacy';
  static const String cityMallFlowerShop = 'city_mall_flower_shop';
  static const String cityMallSexShop = 'city_mall_sex_shop';
  static const String cityMallElectronics = 'city_mall_electronics';
  static const String cityMallCinema = 'city_mall_cinema';

  static const List<String> cityMallRoomIds = [
    cityMallShop,
    cityMallPharmacy,
    cityMallFlowerShop,
    cityMallSexShop,
    cityMallElectronics,
    cityMallCinema,
  ];

  static const String cityEliteApartment1 = 'city_elite_apt_1';
  static const String cityEliteApartment2 = 'city_elite_apt_2';
  static const String cityEliteApartment3 = 'city_elite_apt_3';
  static const String cityEliteApartment4 = 'city_elite_apt_4';
  static const String cityEliteApartment5 = 'city_elite_apt_5';
  static const String cityEliteApartment6 = 'city_elite_apt_6';

  static const List<String> cityEliteResidentialRoomIds = [
    cityEliteApartment1,
    cityEliteApartment2,
    cityEliteApartment3,
    cityEliteApartment4,
    cityEliteApartment5,
    cityEliteApartment6,
  ];

  static const Map<String, RoomData> cityRooms = {
    cityOverview: RoomData(
      displayName: "Місто",
      imagePath: "lib/assets/home_gg/rooms/default.jpg",
      description: "Центр міста.",
      isLocked: false,
    ),
    cityBusinessCenter: RoomData(
      displayName: "Бізнес-центр",
      imagePath: "lib/assets/houses/biznes_centr.jpg",
      description: "Бізнес-центр.",
      isLocked: false,
    ),
    cityBcLogistics: RoomData(
      displayName: "ЛОГІСТИЧНА КОМПАНІЯ",
      imagePath: "lib/assets/houses/company/logistic.png",
      description: "Логістична компанія.",
      isLocked: false,
    ),
    cityBcConstruction: RoomData(
      displayName: "БУДІВЕЛЬНА КОМПАНІЯ",
      imagePath: "lib/assets/houses/company/bud_sam.png",
      description: "Будівельна компанія.",
      isLocked: false,
    ),
    cityBcCallCenter: RoomData(
      displayName: "КОЛЛ-ЦЕНТР",
      imagePath: "lib/assets/houses/company/coll-centr.png",
      description: "Колл-центр.",
      isLocked: false,
    ),
    cityBcRockefellerOffice: RoomData(
      displayName: "ОФІС РОКФЕЛЕРА",
      imagePath: "lib/assets/houses/company/rockfeller.png",
      description: "Офіс Рокфелера.",
      isLocked: false,
    ),
    cityMall: RoomData(
      displayName: "ТРЦ",
      imagePath: "lib/assets/houses/trc.jpg",
      description: "Торгово-розважальний центр.",
      isLocked: false,
    ),
    cityMallShop: RoomData(
      displayName: "МАГАЗИН",
      imagePath: "lib/assets/houses/trc.jpg",
      description: "Магазин.",
      isLocked: false,
    ),
    cityMallPharmacy: RoomData(
      displayName: "АПТЕКА",
      imagePath: "lib/assets/houses/trc.jpg",
      description: "Аптека.",
      isLocked: false,
    ),
    cityMallFlowerShop: RoomData(
      displayName: "КВІТКОВИЙ МАГАЗИН",
      imagePath: "lib/assets/houses/trc.jpg",
      description: "Квітковий магазин.",
      isLocked: false,
    ),
    cityMallSexShop: RoomData(
      displayName: "СЕКС-ШОП",
      imagePath: "lib/assets/houses/trc.jpg",
      description: "Секс-шоп.",
      isLocked: false,
    ),
    cityMallElectronics: RoomData(
      displayName: "МАГАЗИН ЕЛЕКТРОНІКИ",
      imagePath: "lib/assets/houses/trc.jpg",
      description: "Магазин електроніки.",
      isLocked: false,
    ),
    cityMallCinema: RoomData(
      displayName: "КІНОТЕАТР",
      imagePath: "lib/assets/houses/trc.jpg",
      description: "Кінотеатр.",
      isLocked: false,
    ),
    cityCarDealership: RoomData(
      displayName: "Автосалон",
      imagePath: "lib/assets/houses/auto_centr.jpeg",
      description: "Автосалон.",
      isLocked: false,
    ),
    cityPark: RoomData(
      displayName: "Парк",
      imagePath: "lib/assets/houses/park.jpg",
      description: "Міський парк.",
      isLocked: false,
    ),
    cityEliteResidential: RoomData(
      displayName: "Єлітний ЖК",
      imagePath: "lib/assets/houses/elit_gk.jpg",
      description: "Єлітний житловий комплекс.",
      isLocked: false,
    ),
    cityEliteApartment1: RoomData(
      displayName: "Квартира 1",
      imagePath: "lib/assets/houses/elit_gk.jpg",
      description: "Квартира 1.",
      isLocked: false,
    ),
    cityEliteApartment2: RoomData(
      displayName: "Квартира 2",
      imagePath: "lib/assets/houses/elit_gk.jpg",
      description: "Квартира 2.",
      isLocked: false,
    ),
    cityEliteApartment3: RoomData(
      displayName: "Квартира 3",
      imagePath: "lib/assets/houses/elit_gk.jpg",
      description: "Квартира 3.",
      isLocked: false,
    ),
    cityEliteApartment4: RoomData(
      displayName: "Квартира 4",
      imagePath: "lib/assets/houses/elit_gk.jpg",
      description: "Квартира 4.",
      isLocked: false,
    ),
    cityEliteApartment5: RoomData(
      displayName: "Квартира 5",
      imagePath: "lib/assets/houses/elit_gk.jpg",
      description: "Квартира 5.",
      isLocked: false,
    ),
    cityEliteApartment6: RoomData(
      displayName: "Квартира 6",
      imagePath: "lib/assets/houses/elit_gk.jpg",
      description: "Квартира 6.",
      isLocked: false,
    ),
    cityVipGym: RoomData(
      displayName: "VIP тренажерний зал",
      imagePath: "lib/assets/houses/gym.jpg",
      description: "VIP тренажерний зал.",
      isLocked: false,
    ),
    cityVipGymReception: RoomData(
      displayName: "Рецепція",
      imagePath: "lib/assets/houses/gym.jpg",
      description: "Рецепція VIP тренажерного залу.",
      isLocked: false,
    ),
    cityVipGymHall: RoomData(
      displayName: "Зал",
      imagePath: "lib/assets/houses/gym.jpg",
      description: "Зал.",
      isLocked: false,
    ),
    cityVipGymWrestling: RoomData(
      displayName: "Секція боротьби",
      imagePath: "lib/assets/houses/gym.jpg",
      description: "Секція боротьби.",
      isLocked: false,
    ),
    cityVipGymSpa: RoomData(
      displayName: "Спа",
      imagePath: "lib/assets/houses/gym.jpg",
      description: "Спа.",
      isLocked: false,
    ),
    cityVipGymSauna: RoomData(
      displayName: "Сауна",
      imagePath: "lib/assets/houses/gym.jpg",
      description: "Сауна.",
      isLocked: false,
    ),
    cityVipGymMassage: RoomData(
      displayName: "Массажний кабінет",
      imagePath: "lib/assets/houses/gym.jpg",
      description: "Массажний кабінет.",
      isLocked: false,
    ),
  };

  static const Map<String, RoomData> poorDistrictRooms = {
    poorDistrictOverview: RoomData(
      displayName: "Бідний р-н",
      imagePath: "lib/assets/home_gg/rooms/default.jpg",
      description: "Бідний район.",
      isLocked: false,
    ),
    poorDistrictGym: RoomData(
      displayName: "Качалка",
      imagePath: "lib/assets/houses/old_gym.jpg",
      description: "Качалка.",
      isLocked: false,
    ),
    poorDistrictShop: RoomData(
      displayName: "Магазин",
      imagePath: "lib/assets/houses/store.jpg",
      description: "Магазин.",
      isLocked: false,
    ),
    poorDistrictStripBar: RoomData(
      displayName: "Стріп бар",
      imagePath: "lib/assets/houses/strip_bar.jpg",
      description: "Стріп бар.",
      isLocked: false,
    ),
    poorDistrictDarkAlley: RoomData(
      displayName: "Темний провулок",
      imagePath: "lib/assets/houses/dark_alley.jpg",
      description: "Темний провулок.",
      isLocked: false,
    ),
    poorDistrictResidential: RoomData(
      displayName: "Спальні будинки",
      imagePath: "lib/assets/houses/hrushchevki-spb.jpg",
      description: "Спальні будинки.",
      isLocked: false,
    ),
    poorDistrictHotel: RoomData(
      displayName: "Готель",
      imagePath: "lib/assets/houses/hotel.jpg",
      description: "Готель.",
      isLocked: false,
    ),
  };

  static const Map<String, RoomData> poorVillageRooms = {
    poorVillageOverview: RoomData(
      displayName: "Село бідних людей",
      imagePath: "lib/assets/home_gg/rooms/default.jpg",
      description: "Село бідних людей.",
      isLocked: false,
    ),
    poorVillageHouseHeadTeacher: RoomData(
      displayName: "ДІМ ЗАВУЧА",
      imagePath: "lib/assets/houses/zavuch.webp",
      description: "Дім завуча.",
      isLocked: false,
    ),
    poorVillageHouseKaty: RoomData(
      displayName: "ДІМ КАТІ",
      imagePath: "lib/assets/houses/home_katia.jpg",
      description: "Дім Каті.",
      isLocked: false,
    ),
    poorVillageHouseEnglishwoman: RoomData(
      displayName: "ДІМ АНГЛІЧАНКИ",
      imagePath: "lib/assets/houses/english_teach.jpg",
      description: "Дім англічанки.",
      isLocked: false,
    ),
    poorVillageHouseLogisticsBoss: RoomData(
      displayName: "ДІМ НАЧАЛЬНИКА ЛОГІСТИЧНОЇ КОМПАНІЇ",
      imagePath: "lib/assets/houses/chef_logist.webp",
      description: "Дім начальника логістичної компанії.",
      isLocked: false,
    ),
    poorVillageHouseFlowerOwner: RoomData(
      displayName: "ДІМ ВЛАСНИЦІ КВІТКОВОГО МАГАЗИНУ",
      imagePath: "lib/assets/houses/flowers_chef.jpeg",
      description: "Дім власниці квіткового магазину.",
      isLocked: false,
    ),
    poorVillageHouseCallCenterBoss: RoomData(
      displayName: "ДІМ ШЕФА КОЛЛ-ЦЕНТРУ",
      imagePath: "lib/assets/houses/loft5.jpg",
      description: "Дім шефа колл-центру.",
      isLocked: false,
    ),
  };

  static const Map<String, RoomData> outOfTownRooms = {
    outOfTownOverview: RoomData(
      displayName: "На море",
      imagePath: "lib/assets/home_gg/rooms/default.jpg",
      description: "На море.",
      isLocked: false,
    ),
    outOfTownPromenade: RoomData(
      displayName: "Набережна",
      imagePath: "lib/assets/houses/naberezhna-alikante.jpeg",
      description: "Набережна.",
      isLocked: false,
    ),
    outOfTownBeach: RoomData(
      displayName: "Пляж",
      imagePath: "lib/assets/houses/plyagh.jpg",
      description: "Пляж.",
      isLocked: false,
    ),
    outOfTownClub: RoomData(
      displayName: "Клуб",
      imagePath: "lib/assets/houses/club.jpg",
      description: "Клуб.",
      isLocked: false,
    ),
    outOfTownPier: RoomData(
      displayName: "Пристань",
      imagePath: "lib/assets/houses/titulnaja.jpg",
      description: "Пристань.",
      isLocked: false,
    ),
  };

  static const List<String> cityRoomIds = [
    cityBusinessCenter,
    cityMall,
    cityCarDealership,
    cityPark,
    cityEliteResidential,
    cityVipGym,
  ];

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
    if (isCollege) return collegeRooms[roomId]?.displayName ?? roomId;
    if (streetHouseId != null) {
      final name = streetHouseRooms[streetHouseId]?[roomId]?.displayName;
      if (name != null) return name;
    }
    if (isStreet) return streetRooms[roomId]?.displayName ?? roomId;
    if (isCity) return cityRooms[roomId]?.displayName ?? roomId;
    if (isPoorDistrict) return poorDistrictRooms[roomId]?.displayName ?? roomId;
    if (isPoorVillage) return poorVillageRooms[roomId]?.displayName ?? roomId;
    if (isOutOfTown) return outOfTownRooms[roomId]?.displayName ?? roomId;
    return homeRooms[roomId]?.displayName ?? roomId;
  }

  /// Назва локації за roomId для будь-якої зони (телефон, логи тощо).
  static String getLocationDisplayName(String roomId) {
    final fromHome = homeRooms[roomId]?.displayName;
    if (fromHome != null) return fromHome;
    final fromCollege = collegeRooms[roomId]?.displayName;
    if (fromCollege != null) return fromCollege;
    final fromCity = cityRooms[roomId]?.displayName;
    if (fromCity != null) return fromCity;
    final fromPoorDistrict = poorDistrictRooms[roomId]?.displayName;
    if (fromPoorDistrict != null) return fromPoorDistrict;
    final fromPoorVillage = poorVillageRooms[roomId]?.displayName;
    if (fromPoorVillage != null) return fromPoorVillage;
    final fromOutOfTown = outOfTownRooms[roomId]?.displayName;
    if (fromOutOfTown != null) return fromOutOfTown;
    final fromStreet = streetRooms[roomId]?.displayName;
    if (fromStreet != null) return fromStreet;
    for (final houseRooms in streetHouseRooms.values) {
      final name = houseRooms[roomId]?.displayName;
      if (name != null) return name;
    }
    final fromOffice = officeRooms[roomId]?.displayName;
    if (fromOffice != null) return fromOffice;
    return roomId;
  }

  /// Загальна локація для телефону: Дім, Коледж, ТРЦ тощо (без конкретної кімнати).
  static String getGeneralLocationName(String roomId) {
    if (homeRooms.containsKey(roomId)) return 'Дім';
    if (collegeRooms.containsKey(roomId)) return 'Коледж';
    if (streetRooms.containsKey(roomId)) return 'Вулиця';
    for (final houseRooms in streetHouseRooms.values) {
      if (houseRooms.containsKey(roomId)) return 'Вулиця';
    }
    if (roomId == cityOverview) return 'Місто';
    if (roomId == cityBusinessCenter || cityBusinessCenterRoomIds.contains(roomId)) return 'Бізнес-центр';
    if (roomId == cityMall || cityMallRoomIds.contains(roomId)) return 'ТРЦ';
    if (roomId == cityPark) return 'Парк';
    if (roomId == cityCarDealership) return 'Автосалон';
    if (roomId == cityEliteResidential || cityEliteResidentialRoomIds.contains(roomId)) return 'Єлітний ЖК';
    if (roomId == cityVipGym || cityVipGymRoomIds.contains(roomId)) return 'VIP зал';
    if (cityRooms.containsKey(roomId)) return 'Місто';
    if (poorDistrictRooms.containsKey(roomId)) return 'Бідний р-н';
    if (poorVillageRooms.containsKey(roomId)) return 'Село';
    if (outOfTownRooms.containsKey(roomId)) return 'На море';
    if (officeRooms.containsKey(roomId)) return 'Офіс';
    return roomId;
  }

  static const Map<String, RoomData> officeRooms = {
    "office": RoomData(
      displayName: "Офіс",
      imagePath: "assets/rooms/office.jpg",
      description: "Робочий простір.",
      isLocked: false,
    ),
  };
}
