import '../../models/npc_model.dart';

const String kJuniperNpcId = 'juniper';

/// Статус у профілі / галереї до початку стосунків із Sem.
const String kJuniperDefaultStatus = 'Студентка коледжу';

/// Статус після початку зустрічань із Sem ([SemQuest001.isJuniperSemGirlfriendStatus]).
const String kJuniperSemGirlfriendStatus = 'Дівчина Sem';

const String kJuniperGalleryPortraitPath =
    'lib/assets/npcs/juniper/img/juniper.jpg';
const String kJuniperAvatarPath =
    'lib/assets/npcs/juniper/img/juniper_ava.png';

/// Відео знайомства — [SemJuniperRoomIntro]; вечірні візити — [SemJuniperEveningVisits].
/// До знайомства з ГG не показується в роумінгу ([SemQuest001.isJuniperVisibleInWorld]).
NPCModel createJuniperNpc() {
  return NPCModel(
    id: kJuniperNpcId,
    gender: NpcGender.female,
    name: 'Juniper',
    fullName: 'Juniper',
    status: kJuniperDefaultStatus,
    bodyDescription:
        'Маленького зросту — сто п\'ятдесят сім. Струнка, спортивна фігура; '
        'рухається легко, ніби завжди на старті. Грудей майже не видно.',
    biographyType:
        'Вісімнадцяти років, вчиться в сусідньому коледжі. Де саме живе — невідомо: '
        'у нашому районі її бачать частіше, ніж багатьох місцевих — ніби тут у неї '
        'другий дім. Багато посміхається, знайомиться з усіма на ходу; здається, друзів '
        'у неї більше, ніж годин на добу. Постійно кудись біжить і спішить — навіть '
        'коли стоїть на місці, ніби вже запізнюється на наступну справу.\n\n'
        'Живе спортом: то секція, то пробіжка, то «швидко на тренування» — і знову '
        'зникає. Sem каже, що вона збирає хобі швидше, ніж стікери в телефоні: волейбол, '
        'велосипед, танці, зараз нібито скалолазіння. Якщо запізниться — усміхнеться так, '
        'ніби це частина плану, і встигне пробігти переконливе «ой, зараз, хвилинку!».',
    biographyAppearance:
        'Невисока, підтягнута, з живими очима й постійною напівусмішкою. Одягається '
        'просто й зручно — кросівки, шорти або спортивні штани; ніби одразу після '
        'тренування або перед ним. Не сидить спокійно: постукує пальцями, глядає на '
        'годинник, перевіряє телефон — у чатах завжди щось кипить. На вулиці киває '
        'кожному другому знайомому; іноді здається, що знає половину міста.',
    age: 18,
    trust: 0,
    love: 0,
    galleryPortraitPath: kJuniperGalleryPortraitPath,
    avatarPath: kJuniperAvatarPath,
    schedule: const [],
  );
}
