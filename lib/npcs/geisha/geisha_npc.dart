import '../../models/npc_model.dart';
import '../../data/locations_room_data.dart';

const String kGeishaGalleryPortraitPath = 'lib/assets/npcs/geisha/geisha.jpg';
const String kGeishaAvatarPath = 'lib/assets/npcs/geisha/geisha_ava.png';

/// Geisha — «кімната Geisha» (тераса) в квартирі Shalina (елітний ЖК, кв. 3).
/// Тимчасовий розклад: постійно у своїй кімнаті (детальний графік — пізніше).
NPCModel createGeishaNpc() {
  return NPCModel(
    id: 'geisha',
    gender: NpcGender.female,
    name: 'Geisha',
    fullName: 'Geisha',
    status: 'Працівниця готелю',
    subStatus: 'Партнерка Zazie',
    bodyDescription:
        'Невисока, худорлява, дуже струнка, з гарною фігурою. Дрібні кучері — '
        'світле, рудувате, фарбоване; завжди охайна зачіска, приємно пахне.',
    biographyType:
        'Geisha — двадцять чотири роки, живе разом із Shalina та Zazie в їхній '
        'квартирі в елітному ЖК. Працює в готелі бідного району: зміни через день, по добі. '
        'Одяг обирає скромніший, ніж у сусідок; зароблене, кажуть, майже одразу кудись зникає — '
        'ніби Geisha відправляє гроші комусь далеко, можливо родині, хоч вона цього нікому '
        'не підтверджує.\n\n'
        'Іноді Shalina підвозить її на роботу на своєму Mercedes — і тоді в будинку '
        'шепочуть ще більше. У місті Geisha майже не звертає уваги на оточуючих: '
        'хто підійде — отримає холодну стіну мовчання. Разом із Zazie їх часто називають парою; '
        'чутки, що вона лесбійка, Geisha не заперечує — просто проходить повз.',
    biographyAppearance:
        'Дуже красива, невисока, худорлява й струнка — з гарною фігурою. '
        'Волосся фарбоване: світле, з рудим відтінком, у дрібних кучериках — '
        'трохи об’ємніші, ніж у типових афроамериканок, але без важкої хвої. '
        'Завжди охайна зачіска, приємний парфум. Вдягається простіше за Shalina та Zazie, '
        'але виглядає акуратно.',
    age: 24,
    galleryPortraitPath: kGeishaGalleryPortraitPath,
    avatarPath: kGeishaAvatarPath,
    schedule: [
      SchedulePoint(
        hourStart: 0,
        hourEnd: 23,
        location: LocationsData.cityEliteApartment3Terrace,
        actionLabel: 'Вдома',
        spritePath: kGeishaAvatarPath,
      ),
    ],
  );
}
