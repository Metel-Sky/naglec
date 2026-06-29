import '../../models/npc_model.dart';
import '../../data/locations_room_data.dart';

const String kZazieGalleryPortraitPath = 'lib/assets/npcs/zazie/zazie.jpg';
const String kZazieAvatarPath = 'lib/assets/npcs/zazie/zazie_ava.png';

/// Zazie — живе в квартирі Shalina (елітний ЖК, кв. 3), власна кімната.
/// Тимчасовий розклад: постійно у своїй кімнаті (детальний графік — пізніше).
NPCModel createZazieNpc() {
  return NPCModel(
    id: 'zazie',
    gender: NpcGender.female,
    name: 'Zazie',
    fullName: 'Zazie',
    status: 'Студентка коледжу',
    subStatus: 'Партнерка Geisha',
    bodyDescription:
        'Невисока блондинка з дуже гарною, підтягнутою фігурою. Завжди охайна, '
        'гарно вдягнена, приємно пахне. Посміхається легко; часто кидає спокусливі погляди.',
    biographyType:
        'Zazie — дев’ятнадцяти років, блондинка. Живе разом із Shalina та Geisha '
        'в елітному житловому комплексі, у квартирі Shalina — не як гостя на день, '
        'а як частина цього дому. Вчиться в коледжі на відмінно, але тримається особняком: '
        'у групі рідко заговорює, спілкується переважно з дівчатами, а найближча до неї — Geisha.\n\n'
        'Про Zazie ходить багато пліток — про гроші, знайомства, сміливі погляди, — '
        'проте жодна з них не має перевіреного підтвердження. У місті її знають як дівчину, '
        'що завжди гарно вдягнена, завжди посміхається й завжди охайна; від неї приємно пахне. '
        'Чутки, що вона лесбійка, давно стали фоном її імені; сама Zazie на питання '
        'лише посміхається ширше, ніж варто було б.',
    biographyAppearance:
        'Невисока блондинка з дуже гарною фігурою: груди підтягнуті й помітні, '
        'попка — маленька й кругла. Завжди акуратна, гарно одягнена, приємно пахне. '
        'Посміхається часто; коли дивиться довше — ніби навмисно, спокусливо, '
        'перевіряючи, чи хтось помітив.',
    age: 19,
    galleryPortraitPath: kZazieGalleryPortraitPath,
    avatarPath: kZazieAvatarPath,
    schedule: [
      SchedulePoint(
        hourStart: 0,
        hourEnd: 23,
        location: LocationsData.cityEliteApartment3Room,
        actionLabel: 'Вдома',
        spritePath: kZazieAvatarPath,
      ),
    ],
  );
}
