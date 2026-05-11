// ignore_for_file: avoid_print
/// Генерує assets/data/location_display_en.json (англійські назви кімнат за room id).
/// Запуск з кореня проєкту: dart run tool/generate_location_display_en.dart
import 'dart:convert';
import 'dart:io';

void main() {
  final root = Directory.current;
  final loc = File('${root.path}/assets/data/location.json');
  final out = File('${root.path}/assets/data/location_display_en.json');
  final data = jsonDecode(loc.readAsStringSync(encoding: utf8));
  final ids = <String>{};
  void collectRooms(Map<String, dynamic> d) {
    final rooms = d['rooms'];
    if (rooms is Map) {
      ids.addAll(rooms.keys.map((k) => k.toString()));
    }
    final houseRooms = d['houseRooms'];
    if (houseRooms is Map) {
      for (final hm in houseRooms.values) {
        if (hm is Map) {
          ids.addAll(hm.keys.map((k) => k.toString()));
        }
      }
    }
  }

  void walk(Object? o) {
    if (o is Map) {
      final m = o.cast<String, dynamic>();
      collectRooms(m);
      for (final e in m.entries) {
        if (e.key == 'rooms' || e.key == 'houseRooms') continue;
        walk(e.value);
      }
    } else if (o is List) {
      for (final x in o) {
        walk(x);
      }
    }
  }

  walk(data);
  final sorted = ids.toList()..sort();
  final outMap = <String, String>{for (final id in sorted) id: englishFor(id)};
  final encoder = JsonEncoder.withIndent('  ');
  out.writeAsStringSync('${encoder.convert(outMap)}\n', encoding: utf8);
  print(
    'Wrote ${outMap.length} entries to ${out.path.replaceFirst(root.path + Platform.pathSeparator, '')}',
  );
}

const _specific = <String, String>{
  'corridor': 'Corridor',
  'kitchen': 'Kitchen',
  'room_gg': "Player's room",
  'bathroom': 'Bathroom',
  'mom_room': "Mom's room",
  'piper_room': "Piper's room",
  'elsa_room': "Elsa's room",
  'hall': 'Living room',
  'yard': 'Backyard',
  'basement': 'Basement',
  'college_hall': 'Lobby',
  'auditorium_1': 'English class',
  'auditorium_2': 'Math class',
  'auditorium_3': 'History class',
  'college_corridor': 'Corridor',
  'director_office': "Principal's office",
  'canteen': 'Library',
  'gym': 'Gym',
  'college_yard': 'College yard',
  'toilet': 'Restroom',
  'street': 'Street',
  'friend_house': "Korysh's house",
  'aunt_house': "Aunt's house",
  'neighbor_house': "Neighbor's house",
  'classmate_house': "Classmate's house",
  'city': 'City',
  'city_business_center': 'Business center',
  'city_mall': 'Mall',
  'city_park': 'Park',
  'city_elite_residential': 'Elite residential',
  'city_elite_apt_1': 'Elite residence · Apt 1',
  'city_elite_apt_2': 'Elite residence · Apt 2',
  'city_elite_apt_3': 'Elite residence · Apt 3',
  'city_elite_apt_4': 'Elite residence · Apt 4',
  'city_elite_apt_5': 'Elite residence · Apt 5',
  'city_elite_apt_6': 'Elite residence · Apt 6',
  'city_vip_gym': 'VIP gym',
  'poor_district_overview': 'Poor district',
  'poor_district_residential': 'Apartment buildings',
  'poor_district_residential_overview': 'Apartment buildings',
  'poor_district_house_1': 'Building 1',
  'poor_district_house_2': 'Building 2',
  'poor_village_overview': 'Rich Village',
  'out_of_town_overview': 'Seaside',
  'out_of_town_beach': 'Beach',
  'out_of_town_pier': 'Pier',
  'out_of_town_promenade': 'Promenade',
  'out_of_town_club': 'Club',
  'mom_office': "Mom's office",
  'office': 'Office',
};

const _suffixEn = <String, String>{
  'kitchen': 'Kitchen',
  'bathroom': 'Bathroom',
  'hall': 'Living room',
  'corridor': 'Corridor',
  'room': 'Room',
  'bedroom': 'Bedroom',
  'terrace': 'Terrace',
  'sauna': 'Sauna',
  'pool': 'Pool',
  'office': 'Office',
  'yard': 'Yard',
  'shop': 'Shop',
  'gym': 'Gym',
  'hotel': 'Hotel',
  'bar': 'Bar',
  'vip': 'VIP area',
  'toilet': 'Restroom',
  'showroom': 'Showroom',
  'workshop': 'Workshop',
  'reception': 'Reception',
  'massage': 'Massage',
  'spa': 'Spa',
  'wrestling': 'Wrestling room',
  'cinema': 'Cinema',
  'electronics': 'Electronics store',
  'pharmacy': 'Pharmacy',
  'sex_shop': 'Sex shop',
  'restaurant_hall': 'Restaurant',
  'restaurant_vip': 'VIP restaurant',
  'gift_shop': 'Gift shop',
  'gift_shop_office': 'Gift shop office',
  'gift_shop_warehouse': 'Gift shop warehouse',
  'call_center': 'Call center',
  'call_center_boss_office': 'Boss office',
  'call_center_operators_hall': 'Operators hall',
  'gleam_team': 'Gleam Team',
  'gleam_team_cabinet': 'Team cabinet',
  'gleam_team_projects': 'Projects room',
  'logistics': 'Logistics company',
  'logistics_boss_office': 'Logistics boss office',
  'logistics_mom_office': "Mom's office",
  'rockefeller_office': "Rockefeller's office",
  'car_dealership': 'Car dealership',
  'parents_room': "Parents' room",
  'sister_room': "Sister's room",
  'brother_room': "Brother's room",
  'guest_room': 'Guest room',
  'niece_room': "Niece's room",
  'child_1': "Child's room 1",
  'child_2': "Child's room 2",
  'lounge': 'Lounge',
  'dark_alley': 'Dark alley',
  'strip_bar': 'Strip club',
  'strip_bar_vip': 'Strip club VIP',
  'strip_bar_toilet': 'Strip club restroom',
  'beach': 'Beach',
  'pier': 'Pier',
  'promenade': 'Promenade',
  'club_bar': 'Club bar',
  'club_toilet': 'Club restroom',
  'park_cafe': 'Park café',
  'park_coffee': 'Coffee stand',
  'apt': 'Apartment',
};

(String? prefix, String rest) _housePrefix(String rid) {
  const pairs = [
    ('friend_', "Korysh's house — "),
    ('aunt_', "Aunt's house — "),
    ('neighbor_', 'Neighbor\'s — '),
    ('classmate_', 'Classmate\'s — '),
  ];
  for (final p in pairs) {
    if (rid.startsWith(p.$1)) {
      return (p.$2, rid.substring(p.$1.length));
    }
  }
  return (null, rid);
}

String _titleCaseSegment(String p) {
  return p
      .replaceAll('_', ' ')
      .split(RegExp(r'\s+'))
      .where((s) => s.isNotEmpty)
      .map((w) => w.length == 1 ? w.toUpperCase() : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
      .join(' ');
}

String tailLabel(String rest) {
  final parts = rest.split('_');
  for (var n = 3; n >= 1; n--) {
    if (parts.length >= n) {
      final key = parts.sublist(parts.length - n).join('_');
      if (_suffixEn.containsKey(key)) {
        return _suffixEn[key]!;
      }
    }
  }
  final out = <String>[];
  for (final p in parts) {
    out.add(_suffixEn[p] ?? _titleCaseSegment(p));
  }
  return out.join(' · ');
}

String? poorDistrictLabel(String rid) {
  var m = RegExp(r'^poor_district_h(\d+)_a(\d+)_room_(\d+)$').firstMatch(rid);
  if (m != null) {
    final h = m.group(1)!;
    final a = m.group(2)!;
    final r = m.group(3)!;
    return 'Poor district · Bld $h · Unit A$a · Room $r';
  }
  m = RegExp(r'^poor_district_h(\d+)_apt_(\d+)$').firstMatch(rid);
  if (m != null) {
    return 'Poor district · Bld ${m.group(1)} · Apt ${m.group(2)}';
  }
  return null;
}

String? poorVillageHouseLabel(String rid) {
  final m = RegExp(r'^poor_village_house_(.+)$').firstMatch(rid);
  if (m == null) return null;
  final tail = _titleCaseSegment(m.group(1)!);
  return 'Rich Village · $tail';
}

String? cityEliteLabel(String rid) {
  final m = RegExp(r'^city_elite_apt_(\d+)_(.+)$').firstMatch(rid);
  if (m == null) return null;
  final apt = m.group(1)!;
  final rest = m.group(2)!;
  final sub = _suffixEn[rest] ?? _titleCaseSegment(rest);
  return 'Elite residence · Apt $apt · $sub';
}

String? cityBcLabel(String rid) {
  if (!rid.startsWith('city_bc_') &&
      !rid.startsWith('city_car_') &&
      !rid.startsWith('city_mall_')) {
    return null;
  }
  late final String inner;
  if (rid.startsWith('city_bc_')) {
    inner = rid.substring('city_bc_'.length);
  } else if (rid.startsWith('city_car_dealership')) {
    final rest = rid.length > 18 ? rid.substring(18) : '';
    inner = rest.contains('_')
        ? rid.substring('city_car_dealership_'.length)
        : 'dealership';
    if (inner == 'dealership' || inner.isEmpty) {
      return 'Car dealership';
    }
    return 'Car dealership · ${_suffixEn[inner] ?? _titleCaseSingle(inner)}';
  } else {
    inner = rid.substring('city_mall_'.length);
  }
  final key = inner;
  final keyParts = key.split('_');
  for (var n = keyParts.length; n >= 1; n--) {
    final cand = keyParts.take(n).join('_');
    if (_suffixEn.containsKey(cand)) {
      final rem = keyParts.skip(n).join('_');
      if (rem.isNotEmpty) {
        return '${_suffixEn[cand]} · ${tailLabel(rem)}';
      }
      return _suffixEn[cand]!;
    }
  }
  return 'City · ${_titleCaseSegment(key)}';
}

String _titleCaseSingle(String inner) {
  if (inner.isEmpty) return inner;
  return '${inner[0].toUpperCase()}${inner.substring(1)}';
}

String englishFor(String rid) {
  if (_specific.containsKey(rid)) {
    return _specific[rid]!;
  }
  final pd = poorDistrictLabel(rid);
  if (pd != null) return pd;
  final pv = poorVillageHouseLabel(rid);
  if (pv != null) return pv;
  final ce = cityEliteLabel(rid);
  if (ce != null) return ce;
  final cbc = cityBcLabel(rid);
  if (cbc != null) return cbc;
  if (rid.startsWith('poor_village_')) {
    final rest = rid.substring('poor_village_'.length);
    final parts = rest.split('_');
    if (parts.length >= 2) {
      final owner = _titleCaseSingle(parts.first);
      final sub = parts.sublist(1).join('_');
      final subEn = _suffixEn[sub] ?? _titleCaseSegment(sub);
      return 'Rich Village · $owner — $subEn';
    }
  }
  final hp = _housePrefix(rid);
  if (hp.$1 != null) {
    return hp.$1! + tailLabel(hp.$2);
  }
  if (rid.contains('_')) {
    return tailLabel(rid);
  }
  return _titleCaseSingle(rid);
}
