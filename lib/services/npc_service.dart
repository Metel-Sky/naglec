import 'dart:math';

import '../data/college_schedule.dart';
import '../data/locations_room_data.dart';
import '../models/npc_model.dart';
import '../npcs/all_npcs.dart';
import 'cherie_quest002_location_pin.dart';
import 'cherie_quest004_location_pin.dart';
import 'cherie_quest005_location_pin.dart';
import 'cherie_quest006_location_pin.dart';
import 'cherie_massage_fun_location_pin.dart';
import 'mom_quest001_location_pin.dart';
import 'game_time_controller.dart';
import 'game_world_state.dart';
import 'inventory_controller.dart';
import 'npc_city_roaming_service.dart';
import 'service_locator.dart';

class NPCService {
  final List<NPCModel> allNPCs = createAllNpcs();

  static const String _momGymCardItemId = 'ab_fitness';
  static const String _momNpcId = 'mom';

  static bool _momHasGymCard() {
    try {
      final inventory = sl<InventoryController>();
      if (inventory.count(_momGymCardItemId) <= 0) return false;

      final world = sl<GameWorldState>();
      final purchasedIso = world.vipGymCardPurchasedAtIso;
      if (purchasedIso == null || purchasedIso.isEmpty) {
        // Підтримка старих сейвів без збереженої дати покупки.
        return true;
      }
      final purchasedAt = DateTime.tryParse(purchasedIso);
      if (purchasedAt == null) return true;
      final now = sl<GameTimeController>().dateTime;
      return now.difference(purchasedAt).inDays <= 30;
    } catch (_) {
      return false;
    }
  }

  static int _effectiveDayForNpc(NPCModel npc, int day) {
    return day;
  }

  /// Лошок, Ден і Sem у будні 12:30–12:59 — туалет коледжу (не коридор / не роумінг перерви).
  static bool _weekdayCollegeToilet1230SemDenLoshok(
    String npcId,
    int effectiveDay,
    int hour,
    int minute,
  ) {
    if (npcId != _semNpcId && npcId != 'den' && npcId != 'loshok') {
      return false;
    }
    if (!collegeWeekdayIndices.contains(effectiveDay)) return false;
    if (hour != 12) return false;
    return minute >= 30 && minute <= 59;
  }

  /// Мама без дійсного абонемента VIP не ходить у VIP-зал за розкладом — тоді спрацьовує роумінг містом.
  static bool _skipMomVipWithoutCard(NPCModel npc, SchedulePoint point) {
    return npc.id == _momNpcId &&
        !_momHasGymCard() &&
        point.location == LocationsData.cityVipGym;
  }

  static bool _skipSashaVipWithoutCard(NPCModel npc, SchedulePoint point) {
    return npc.id == _sashaNpcId &&
        !_momHasGymCard() &&
        point.location == LocationsData.cityVipGym;
  }

  static const String _danielleNpcId = 'danielle';

  static bool _skipDanielleVipWithoutCard(NPCModel npc, SchedulePoint point) {
    return npc.id == _danielleNpcId &&
        !_momHasGymCard() &&
        point.location == LocationsData.cityVipGym;
  }

  static const String _elsaNpcId = 'elsa';
  static const String _sashaNpcId = 'sasha';
  static const String _semNpcId = 'sem';
  static const String _cherieNpcId = 'cherie';

  /// Будні 18–20: без кімнати Саші ([friendSisterRoom]) і батьків ([friendParentsRoom]).
  /// О 19:00 без залу — там окрема сцена з Сашею.
  static const List<String> _semWeekdayEveningHomeRoomIds = [
    LocationsData.friendCorridor,
    LocationsData.friendKitchen,
    LocationsData.friendHall,
    LocationsData.friendLounge,
    LocationsData.friendBathroom,
    LocationsData.friendRoom,
    LocationsData.friendSauna,
    LocationsData.friendPool,
  ];

  static String _semWeekdayEveningHomeRoom(int weekdayIndex, int hour) {
    final ids = hour == 19
        ? [
            for (final id in _semWeekdayEveningHomeRoomIds)
              if (id != LocationsData.friendHall) id,
          ]
        : _semWeekdayEveningHomeRoomIds;
    final seed =
        (weekdayIndex * 24 + hour) * 31 + 'sem_home_evening'.hashCode;
    final i = Random(seed).nextInt(ids.length);
    return ids[i];
  }

  /// Нд 22:00–23:59 та пн 0:00–3:59 — клуб «на морі» (хол / бар / туалет), детерміновано.
  /// Інакше в циклі розкладу «нічний» сон 23–6 (hourStart 23) перебив би слот клубу 0–3.
  static String? _sashaSundayClubNightLocation(int day, int hour) {
    final sunEvening = day == 6 && hour >= 22 && hour <= 23;
    final monAfter = day == 0 && hour >= 0 && hour <= 3;
    if (!sunEvening && !monAfter) return null;
    const pool = <String>[
      LocationsData.outOfTownClub,
      LocationsData.outOfTownClubBar,
      LocationsData.outOfTownClubToilet,
    ];
    final seed = (day * 24 + hour) * 31 + 'sasha_club_night'.hashCode;
    return pool[Random(seed).nextInt(pool.length)];
  }

  /// Сб 22–23 та нд 0–3 — клуб «на морі» (хол / бар / туалет), детерміновано.
  static String? _elsaClubNightLocation(int day, int hour) {
    final satNight = day == 5 && hour >= 22 && hour <= 23;
    final sunEarly = day == 6 && hour >= 0 && hour <= 3;
    if (!satNight && !sunEarly) return null;
    const pool = <String>[
      LocationsData.outOfTownClub,
      LocationsData.outOfTownClubBar,
      LocationsData.outOfTownClubToilet,
    ];
    final seed = (day * 24 + hour) * 31 + 'elsa_club_night'.hashCode;
    return pool[Random(seed).nextInt(pool.length)];
  }

  static String _momWeekendVipGymRoom(int weekdayIndex, int hour) {
    const pool = <String>[
      LocationsData.cityVipGymHall,
      LocationsData.cityVipGymSpa,
      LocationsData.cityVipGymSauna,
      LocationsData.cityVipGymMassage,
    ];
    final seed = (weekdayIndex * 24 + hour) * 31 + 'mom_weekend_vip_gym'.hashCode;
    return pool[Random(seed).nextInt(pool.length)];
  }

  static String _sashaWeekdayVipGymRoom(int weekdayIndex, int hour) {
    const pool = <String>[
      LocationsData.cityVipGymHall,
      LocationsData.cityVipGymSpa,
      LocationsData.cityVipGymSauna,
      LocationsData.cityVipGymMassage,
    ];
    final seed = (weekdayIndex * 24 + hour) * 31 + 'sasha_weekday_vip_gym'.hashCode;
    return pool[Random(seed).nextInt(pool.length)];
  }

  static String _danielleWeekendVipGymRoom(int weekdayIndex, int hour) {
    const pool = <String>[
      LocationsData.cityVipGymHall,
      LocationsData.cityVipGymSpa,
      LocationsData.cityVipGymSauna,
      LocationsData.cityVipGymMassage,
    ];
    final seed =
        (weekdayIndex * 24 + hour) * 31 + 'danielle_weekend_vip_gym'.hashCode;
    return pool[Random(seed).nextInt(pool.length)];
  }

  static const List<String> _danielleWeekendNoVipHomeRoomIds = [
    LocationsData.friendKitchen,
    LocationsData.friendHall,
    LocationsData.friendLounge,
    LocationsData.friendBathroom,
    LocationsData.friendParentsRoom,
    LocationsData.friendSauna,
    LocationsData.friendPool,
  ];

  static String _danielleWeekendNoVipHomeRoom(int weekdayIndex, int hour) {
    final seed =
        (weekdayIndex * 24 + hour) * 31 + 'danielle_home_no_vip'.hashCode;
    final i = Random(seed).nextInt(_danielleWeekendNoVipHomeRoomIds.length);
    return _danielleWeekendNoVipHomeRoomIds[i];
  }

  static String _danielleWeekendParkRoom(int weekdayIndex, int hour) {
    final ids = <String>[LocationsData.cityPark, ...LocationsData.cityParkRoomIds];
    final unique = <String>[];
    for (final id in ids) {
      if (!unique.contains(id)) unique.add(id);
    }
    final pool = unique.isEmpty ? <String>[LocationsData.cityPark] : unique;
    final seed = (weekdayIndex * 24 + hour) * 31 + 'danielle_park'.hashCode;
    return pool[Random(seed).nextInt(pool.length)];
  }

  static String _jessaStripBarRoom(int weekdayIndex, int hour) {
    const pool = <String>[
      LocationsData.poorDistrictStripBarVip,
      LocationsData.poorDistrictStripBarToilet,
    ];
    final seed = (weekdayIndex * 24 + hour) * 31 + 'jessa_strip_bar'.hashCode;
    return pool[Random(seed).nextInt(pool.length)];
  }

  static const List<String> _cherieWeekdayEveningHomeRoomIds = [
    LocationsData.poorVillageGiftShopOwnerKitchen,
    LocationsData.poorVillageGiftShopOwnerBathroom,
    LocationsData.poorVillageGiftShopOwnerHall,
    LocationsData.poorVillageGiftShopOwnerRoom1,
  ];

  static String _cherieWeekdayEveningHomeRoom(int weekdayIndex, int hour) {
    final seed =
        (weekdayIndex * 24 + hour) * 31 + 'cherie_home_evening'.hashCode;
    final i = Random(seed).nextInt(_cherieWeekdayEveningHomeRoomIds.length);
    return _cherieWeekdayEveningHomeRoomIds[i];
  }

  /// ID контактів, які завжди у телефоні (мама, Ліза, Piper).
  static const List<String> defaultContactIds = ['mom', 'elsa', 'piper'];

  /// Де зараз Nicole (завуч) у коледжі.
  /// **Під час пар** — завжди кабінет історії (`auditorium_3`).
  /// **На перервах** (будні 9–18, не години пар) — випадково коридор або кабінет директора (детерміновано від дня + години).
  static String? nicoleCollegeRoamingRoom(int weekdayIndex, int hour) {
    if (!collegeWeekdayIndices.contains(weekdayIndex)) return null;
    if (hour < 9 || hour > 18) return null;
    if (isCollegeLessonHour(hour)) {
      return LocationsData.auditorium3;
    }
    const breakRooms = [
      LocationsData.collegeCorridor,
      LocationsData.directorOffice,
    ];
    final seed =
        (weekdayIndex * 24 + hour) * 31 + 'nicole_college_roam'.hashCode;
    final i = Random(seed).nextInt(breakRooms.length);
    return breakRooms[i];
  }

  static bool _timeMatchesPoint(SchedulePoint p, int hour) {
    if (p.hourStart <= p.hourEnd) {
      return hour >= p.hourStart && hour <= p.hourEnd;
    }
    return hour >= p.hourStart || hour <= p.hourEnd;
  }

  static const String sondoxVar = 'sondox';

  static bool _isSondoxSleepPoint(SchedulePoint p) {
    if (p.hourStart <= p.hourEnd) return false;
    final action = p.actionLabel.toLowerCase();
    return action.contains('sleep') || action.contains('спить');
  }

  static SchedulePoint? _sondoxSleepPoint(NPCModel npc, int hour) {
    if (npc.getVar(sondoxVar) != true) return null;
    for (final point in npc.schedule) {
      if (!_isSondoxSleepPoint(point)) continue;
      final earlyStart = (point.hourStart + 23) % 24;
      if (hour >= earlyStart || hour <= point.hourEnd) {
        return point;
      }
    }
    return null;
  }

  void resetSondoxTriggersAtMorning(DateTime gameNow) {
    if (gameNow.hour < 6 || gameNow.hour >= 10) return;
    for (final npc in allNPCs) {
      if (npc.getVar(sondoxVar) == true) {
        npc.setVar(sondoxVar, false);
      }
    }
  }

  /// Поточна локація NPC за розкладом (год і день тижня).
  /// Час включно: слот 9–9 = 9:00–9:59, слот 10–17 = 10:00–17:59; через північ 22–6 = 22:00–6:59.
  /// При кількох збігах беремо слот з найбільшим hourStart.
  String? getCurrentLocationId(NPCModel npc, int hour, int day) {
    _cleanupExpiredNpcItems();
    final effectiveDay = _effectiveDayForNpc(npc, day);
    if (npc.id == _cherieNpcId) {
      final world = sl<GameWorldState>();
      if (cherieQuest002PinsNpcToGiftShopOwnerHall(npc, world)) {
        return LocationsData.poorVillageGiftShopOwnerHall;
      }
      final cherieQ6Room = cherieQuest006OverrideCherieRoomId(npc, world);
      if (cherieQ6Room != null) return cherieQ6Room;
      final cherieMfRoom = cherieMassageFunEventOverrideCherieRoomId(npc, world);
      if (cherieMfRoom != null) return cherieMfRoom;
      final cherieQ5Room = cherieQuest005OverrideCherieRoomId(npc, world);
      if (cherieQ5Room != null) return cherieQ5Room;
      final cherieQ4Room = cherieQuest004OverrideCherieRoomId(npc, world);
      if (cherieQ4Room != null) return cherieQ4Room;
    }
    if (npc.id == _momNpcId) {
      final world = sl<GameWorldState>();
      final hallPin = momQuest001OverrideMomHall(npc, world, effectiveDay, hour);
      if (hallPin != null) return hallPin;
    }
    final sondoxSleepPoint = _sondoxSleepPoint(npc, hour);
    if (sondoxSleepPoint != null) {
      return sondoxSleepPoint.location;
    }
    if (npc.id == 'rockefeller') {
      const wd = [0, 1, 2, 3, 4];
      if (wd.contains(effectiveDay) && hour >= 9 && hour <= 18) {
        return LocationsData.cityBcRockefellerCabinet;
      }
      return null;
    }
    if (npc.id == 'nicole') {
      final roam = nicoleCollegeRoamingRoom(effectiveDay, hour);
      if (roam != null) return roam;
    }
    if (npc.id == _elsaNpcId) {
      final club = _elsaClubNightLocation(day, hour);
      if (club != null) return club;
    }
    if (npc.id == _sashaNpcId) {
      final club = _sashaSundayClubNightLocation(day, hour);
      if (club != null) return club;
    }
    final gameMinute = sl<GameTimeController>().dateTime.minute;
    if (_weekdayCollegeToilet1230SemDenLoshok(
        npc.id, effectiveDay, hour, gameMinute)) {
      return LocationsData.toilet;
    }
    // Студентки + Sem: 10–17 у будні — під час пар випадкова з 3 аудиторій, на перервах як у вчителів.
    if (collegeRoamingStudentNpcIds.contains(npc.id) &&
        collegeWeekdayIndices.contains(effectiveDay) &&
        isCollegeStudentCampusHour(hour)) {
      if (isCollegeLessonHour(hour)) {
        return collegeStudentLessonAuditorium(npc.id, effectiveDay, hour);
      }
      return collegeStudentBreakRoom(npc.id, effectiveDay, hour);
    }
    // Вчителі між парами — у одній з [collegeTeacherBreakRoomIds] (не в кабінеті директора).
    if ((npc.id == 'amia' || npc.id == 'lisa') &&
        collegeWeekdayIndices.contains(effectiveDay) &&
        isCollegeTeacherBetweenLessons(hour)) {
      return collegeTeacherBreakRoom(npc.id, effectiveDay, hour);
    }
    SchedulePoint? best;
    for (final point in npc.schedule) {
      if (point.days != null && !point.days!.contains(effectiveDay)) continue;
      if (_skipMomVipWithoutCard(npc, point) ||
          _skipSashaVipWithoutCard(npc, point) ||
          _skipDanielleVipWithoutCard(npc, point)) {
        continue;
      }
      bool timeMatches;
      if (point.hourStart <= point.hourEnd) {
        timeMatches = hour >= point.hourStart && hour <= point.hourEnd;
      } else {
        timeMatches = hour >= point.hourStart || hour <= point.hourEnd;
      }
      if (timeMatches && (best == null || point.hourStart > best.hourStart)) {
        best = point;
      }
    }
    if (best != null) {
      // Мама в VIP: лише з абонементом (інше відфільтровано в циклі); зона — рандом [hall/spa/sauna/massage].
      if (npc.id == 'mom' && best.location == LocationsData.cityVipGym) {
        return _momWeekendVipGymRoom(effectiveDay, hour);
      }
      if (npc.id == _sashaNpcId && best.location == LocationsData.cityVipGym) {
        return _sashaWeekdayVipGymRoom(effectiveDay, hour);
      }
      if (npc.id == _danielleNpcId && best.location == LocationsData.cityVipGym) {
        return _danielleWeekendVipGymRoom(effectiveDay, hour);
      }
      // Jessa у стріп-барі: рендеримо рандомно в [VIP зал/туалет].
      if (npc.id == 'jessa' && best.location == LocationsData.poorDistrictStripBar) {
        return _jessaStripBarRoom(effectiveDay, hour);
      }
      // Спец-маркер у розкладі: «гуляє по місту» (фактична кімната з роумінг-пулу).
      if (best.location == LocationsData.cityOverview) {
        return NpcCityRoamingService.pickRoamingLocation(
          npcId: npc.id,
          weekdayIndex: effectiveDay,
          hour: hour,
        );
      }
      if (npc.id == _semNpcId &&
          best.location == LocationsData.friendHomeSemEveningRoam) {
        return _semWeekdayEveningHomeRoom(effectiveDay, hour);
      }
      if (npc.id == _cherieNpcId &&
          best.location == LocationsData.cherieWeekdayEveningHomeRoam) {
        return _cherieWeekdayEveningHomeRoom(effectiveDay, hour);
      }
      if (npc.id == _danielleNpcId &&
          best.location == LocationsData.danielleWeekendParkRoam) {
        return _danielleWeekendParkRoom(effectiveDay, hour);
      }
      if (npc.id == _danielleNpcId &&
          best.location == LocationsData.friendHomeDanielleWeekendNoVipRoam) {
        return _danielleWeekendNoVipHomeRoom(effectiveDay, hour);
      }
      return best.location;
    }
    // Якщо в NPC немає активного слоту — він «гуляє містом» у дозволених зонах.
    return NpcCityRoamingService.pickRoamingLocation(
      npcId: npc.id,
      weekdayIndex: effectiveDay,
      hour: hour,
    );
  }

  /// Sem на годинах 8–22 у кімнаті дому кориша (фасад «покликати»).
  bool isSemAtFriendHouseForDoorSummon(int hour, int weekdayIndex) {
    if (hour < 8 || hour > 22) return false;
    NPCModel? sem;
    for (final n in allNPCs) {
      if (n.id == _semNpcId) {
        sem = n;
        break;
      }
    }
    if (sem == null) return false;
    final loc = getCurrentLocationId(sem, hour, weekdayIndex);
    return LocationsData.isFriendHouseInteriorRoom(loc);
  }

  /// Точка розкладу для UI (спрайт/підпис), коли [getCurrentLocationId] уже збігся з [roomName].
  SchedulePoint? representativeSchedulePoint(
    NPCModel npc,
    String roomName,
    int hour,
    int day,
  ) {
    _cleanupExpiredNpcItems();
    final effectiveDay = _effectiveDayForNpc(npc, day);
    final normRoom = LocationsData.migrateLegacyRoomId(roomName);
    if (getCurrentLocationId(npc, hour, day) != normRoom) return null;

    final gameMinute = sl<GameTimeController>().dateTime.minute;
    if (normRoom == LocationsData.toilet &&
        _weekdayCollegeToilet1230SemDenLoshok(
            npc.id, effectiveDay, hour, gameMinute)) {
      return SchedulePoint(
        hourStart: 12,
        hourEnd: 12,
        location: LocationsData.toilet,
        actionLabel: 'У туалеті',
        spritePath: npc.avatarPath ?? '',
        days: collegeWeekdayIndices,
      );
    }

    final sondoxSleepPoint = _sondoxSleepPoint(npc, hour);
    if (sondoxSleepPoint != null && sondoxSleepPoint.location == normRoom) {
      return sondoxSleepPoint;
    }

    if (npc.id == 'nicole') {
      try {
        return npc.schedule.firstWhere((p) {
          if (p.days != null && !p.days!.contains(effectiveDay)) return false;
          return _timeMatchesPoint(p, hour);
        });
      } catch (_) {
        return null;
      }
    }

    // Студенти: спрайт з маркерного слоту «college_hall» 10–17, хоча фактична кімната — аудиторія/перерва.
    if (collegeRoamingStudentNpcIds.contains(npc.id) &&
        collegeWeekdayIndices.contains(effectiveDay) &&
        isCollegeStudentCampusHour(hour)) {
      try {
        return npc.schedule.firstWhere(
          (p) =>
              p.location == LocationsData.collegeHall &&
              hour >= p.hourStart &&
              hour <= p.hourEnd &&
              (p.days == null || p.days!.contains(effectiveDay)),
        );
      } catch (_) {}
    }

    try {
      return npc.schedule.firstWhere((p) {
        if (p.days != null && !p.days!.contains(effectiveDay)) return false;
        if (p.location != normRoom) return false;
        return _timeMatchesPoint(p, hour);
      });
    } catch (_) {}

    if (npc.id == _sashaNpcId) {
      try {
        return npc.schedule.firstWhere((p) {
          if (p.days != null && !p.days!.contains(effectiveDay)) return false;
          if (p.location != LocationsData.cityOverview) return false;
          return _timeMatchesPoint(p, hour);
        });
      } catch (_) {}
      if (LocationsData.cityVipGymRoomIds.contains(normRoom) &&
          (effectiveDay == 1 || effectiveDay == 3) &&
          hour >= 18 &&
          hour <= 19 &&
          _momHasGymCard()) {
        try {
          return npc.schedule.firstWhere((p) {
            if (p.location != LocationsData.cityVipGym) return false;
            if (p.days != null && !p.days!.contains(effectiveDay)) return false;
            return _timeMatchesPoint(p, hour);
          });
        } catch (_) {}
      }
      final sunEvening = effectiveDay == 6 && hour >= 22 && hour <= 23;
      final monAfter = effectiveDay == 0 && hour >= 0 && hour <= 3;
      if (LocationsData.outOfTownClubRoomIds.contains(normRoom) &&
          (sunEvening || monAfter)) {
        try {
          return npc.schedule.firstWhere((p) {
            if (p.location != LocationsData.outOfTownClub) return false;
            if (p.days != null && !p.days!.contains(effectiveDay)) return false;
            return _timeMatchesPoint(p, hour);
          });
        } catch (_) {}
      }
    }

    if (npc.id == _semNpcId) {
      if (collegeWeekdayIndices.contains(effectiveDay) &&
          hour >= 18 &&
          hour <= 20 &&
          _semWeekdayEveningHomeRoomIds.contains(normRoom)) {
        try {
          return npc.schedule.firstWhere((p) {
            if (p.location != LocationsData.friendHomeSemEveningRoam) {
              return false;
            }
            if (p.days != null && !p.days!.contains(effectiveDay)) return false;
            return _timeMatchesPoint(p, hour);
          });
        } catch (_) {}
      }
      try {
        return npc.schedule.firstWhere((p) {
          if (p.days != null && !p.days!.contains(effectiveDay)) return false;
          if (p.location != LocationsData.cityOverview) return false;
          return _timeMatchesPoint(p, hour);
        });
      } catch (_) {}
    }

    if (npc.id == _cherieNpcId) {
      final world = sl<GameWorldState>();
      if (cherieQuest002PinsNpcToGiftShopOwnerHall(npc, world) &&
          normRoom == LocationsData.poorVillageGiftShopOwnerHall) {
        final av = npc.avatarPath;
        if (av != null && av.isNotEmpty) {
          return SchedulePoint(
            hourStart: 0,
            hourEnd: 23,
            location: LocationsData.poorVillageGiftShopOwnerHall,
            actionLabel: 'Зал (квест)',
            spritePath: av,
            days: null,
          );
        }
      }
      if (collegeWeekdayIndices.contains(effectiveDay)) {
        if (hour >= 19 && hour <= 22) {
          if (_cherieWeekdayEveningHomeRoomIds.contains(normRoom)) {
            try {
              return npc.schedule.firstWhere((p) {
                if (p.location != LocationsData.cherieWeekdayEveningHomeRoam) {
                  return false;
                }
                if (p.days != null && !p.days!.contains(effectiveDay)) {
                  return false;
                }
                return _timeMatchesPoint(p, hour);
              });
            } catch (_) {}
          }
        }
      }
    }

    if (npc.id == _danielleNpcId) {
      final weekend = effectiveDay == 5 || effectiveDay == 6;
      if (weekend && hour >= 12 && hour <= 14) {
        final inPark = normRoom == LocationsData.cityPark ||
            LocationsData.cityParkRoomIds.contains(normRoom);
        if (inPark) {
          try {
            return npc.schedule.firstWhere((p) {
              if (p.location != LocationsData.danielleWeekendParkRoam) {
                return false;
              }
              if (p.days != null && !p.days!.contains(effectiveDay)) {
                return false;
              }
              return _timeMatchesPoint(p, hour);
            });
          } catch (_) {}
        }
      }
      if (weekend && hour >= 15 && hour <= 17) {
        if (_momHasGymCard() &&
            LocationsData.cityVipGymRoomIds.contains(normRoom)) {
          try {
            return npc.schedule.firstWhere((p) {
              if (p.location != LocationsData.cityVipGym) return false;
              if (p.days != null && !p.days!.contains(effectiveDay)) {
                return false;
              }
              return _timeMatchesPoint(p, hour);
            });
          } catch (_) {}
        }
        if (!_momHasGymCard() &&
            _danielleWeekendNoVipHomeRoomIds.contains(normRoom)) {
          try {
            return npc.schedule.firstWhere((p) {
              if (p.location != LocationsData.friendHomeDanielleWeekendNoVipRoam) {
                return false;
              }
              if (p.days != null && !p.days!.contains(effectiveDay)) {
                return false;
              }
              return _timeMatchesPoint(p, hour);
            });
          } catch (_) {}
        }
      }
      try {
        return npc.schedule.firstWhere((p) {
          if (p.days != null && !p.days!.contains(effectiveDay)) return false;
          if (p.location != LocationsData.cityOverview) return false;
          return _timeMatchesPoint(p, hour);
        });
      } catch (_) {}
    }

    if ((npc.id == 'amia' || npc.id == 'lisa') &&
        collegeTeacherBreakRoomIds.contains(normRoom)) {
      try {
        final ownAuditorium = npc.id == 'amia'
            ? LocationsData.auditorium1
            : LocationsData.auditorium2;
        return npc.schedule.firstWhere(
          (p) => p.spritePath.isNotEmpty && p.location == ownAuditorium,
        );
      } catch (_) {}
    }

    // Мама в домашньому залі за піном квесту «001 пляж» (суб/нд 12–14): у розкладі цей слот —
    // cityOverview без спрайту, тож стандартний пошук по location не дає точки.
    if (npc.id == _momNpcId && normRoom == LocationsData.hall) {
      final world = sl<GameWorldState>();
      if (momQuest001OverrideMomHall(npc, world, effectiveDay, hour) != null) {
        final av = npc.avatarPath;
        if (av != null && av.isNotEmpty) {
          return SchedulePoint(
            hourStart: 12,
            hourEnd: 14,
            location: LocationsData.hall,
            actionLabel: '',
            spritePath: av,
          );
        }
      }
    }
    return null;
  }

  /// Кандидати для показу відео: NPC у кімнаті в цей час з непорожнім spritePath.
  /// Для панелі з аватарами: обраний по seed ставиться першим.
  List<({NPCModel npc, SchedulePoint point})> getCandidatesInRoom(String roomName, int hour, int day) {
    final List<({NPCModel npc, SchedulePoint point})> result = [];
    for (final npc in allNPCs) {
      final point = representativeSchedulePoint(npc, roomName, hour, day);
      if (point != null && point.spritePath.isNotEmpty) {
        result.add((npc: npc, point: point));
      }
    }
    return result;
  }

  /// Хто зараз у кімнаті (узгоджено з [getCurrentLocationId]).
  /// У кабінеті директора можуть бути лише Nicole та Dekan.
  List<NPCModel> getNPCsInRoom(String roomName, int hour, int day) {
    final norm = LocationsData.migrateLegacyRoomId(roomName);
    return allNPCs.where((npc) {
      if (norm == LocationsData.directorOffice &&
          npc.id != 'nicole' &&
          npc.id != 'dekan') {
        return false;
      }
      return getCurrentLocationId(npc, hour, day) == norm;
    }).toList();
  }

  /// Скидає стати та змінні всіх NPC для нової гри: хтивість 0, відносини за замовчуванням (Саша — 0), поведінка 0, збудження 0, вплив 0
  void reset() {
    for (final npc in allNPCs) {
      npc.trust = 0.0;
      npc.love = npc.id == 'sasha' ? 0.0 : 40.0;
      npc.corruption = 0;
      npc.lust = 0.0;
      npc.behavior = 0.0;
      npc.arousal = 0;
      npc.money = 0;
      npc.variables.clear();
    }
  }

  NPCModel? npcById(String id) {
    try {
      return allNPCs.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  void giveVipGymCardToMom({
    required DateTime purchasedAt,
    String imagePath = 'lib/assets/items/ab_fitness.jpg',
  }) {
    final mom = npcById(_momNpcId);
    if (mom == null) return;
    final expiresAt = purchasedAt.add(const Duration(days: 30));
    mom.items.removeWhere((it) => it.id == _momGymCardItemId);
    mom.items.add(
      NpcOwnedItem(
        id: _momGymCardItemId,
        name: 'Абонемент в VIP тренажерний зал',
        imagePath: imagePath,
        expiresAtIso: expiresAt.toIso8601String(),
      ),
    );
  }

  void ensureNpcItemsFresh() {
    _cleanupExpiredNpcItems();
  }

  void _cleanupExpiredNpcItems() {
    DateTime now;
    try {
      now = sl<GameTimeController>().dateTime;
    } catch (_) {
      return;
    }
    for (final npc in allNPCs) {
      npc.items.removeWhere((it) {
        final expiresAtIso = it.expiresAtIso;
        if (expiresAtIso == null || expiresAtIso.isEmpty) return false;
        final expiresAt = DateTime.tryParse(expiresAtIso);
        if (expiresAt == null) return false;
        return !now.isBefore(expiresAt);
      });
    }
  }
}
