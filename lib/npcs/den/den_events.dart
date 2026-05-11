import '../../models/npc_model.dart';

/// Один квест **hooligan** (хуліганський ланцюжок Дена): три етапи поспіль.
///
/// Прогрес у [NPCModel.variables]: етапи [DenEventVars.firstMeetingDone],
/// [DenEventVars.secondMeeting], [DenEventVars.thirdMeeting].
/// Коли всі три виконані — [DenEventVars.hooligan] = `true`.
///
/// UI-фази нижче лише дроблять відображення всередині кожного етапу.

/// UI-етапи 1-го етапу квесту hooligan (знайомство).
enum DenIntroUiPhase { initial, agreed, blya, afterBlya }

/// UI-етапи 2-го етапу квесту hooligan (після знайомства).
enum DenSecondUiPhase {
  initial,
  afterDiscuss,
  afterAgree,
  afterBlya,
  afterDa,
  afterHow,
}

/// UI-етапи 3-го етапу квесту hooligan.
enum DenThirdUiPhase { initial, afterDiscuss }

/// Після завершення квесту hooligan — додатковий діалог.
enum DenAfterUiPhase { initial, afterTalk }

/// Ключі змінних квесту **hooligan** (Ден) у [NPCModel.variables].
class DenEventVars {
  static const String firstMeetingDone = 'denFirstMeetingDone';
  static const String introduction = 'denIntroduction';
  static const String secondMeeting = 'denSecondMeeting';
  static const String secondChainDone = 'denSecondChainDone';
  static const String thirdMeeting = 'denThirdMeeting';

  /// `true`, коли всі три етапи hooligan пройдені.
  static const String hooligan = 'hooligan';
}

/// Медіа квесту hooligan: шляхи до асетів і налаштування відео.
/// Щоб змінити файл відео/картинки — правити тільки тут; у [MainGameScreen] лише виклик плеєра.
abstract final class DenHooliganQuestMedia {
  /// Після «Погодитися» в 1-му ланцюжку (заглушка-картинка).
  static const String introAgreePlaceholderImage = 'lib/assets/npcs/den/test_1.jpg';

  /// Після кнопки «Бля...» в 1-му ланцюжку.
  static const String introBlyaVideo = 'lib/assets/npcs/den/test_2.webm';

  /// Після «Погодитися» у 2-му ланцюжку.
  static const String secondAgreeVideo = 'lib/assets/npcs/den/test_23.webm';

  /// Після «Бля...» у 2-му ланцюжку.
  static const String secondBlyaVideo = 'lib/assets/npcs/den/test_2.webm';

  static const bool videoMuted = true;
  static const bool videoFullScreen = true;

  /// Автозакриття плеєра після кінця ролика (false = лишається до «Піти» / ручного скидання).
  static const bool introBlyaCloseWhenCompleted = false;
  static const bool secondAgreeCloseWhenCompleted = true;
  static const bool secondBlyaCloseWhenCompleted = false;
}

/// Чи завершено квест hooligan (усі 3 етапи).
bool isDenHooliganQuestComplete(NPCModel den) =>
    den.id == 'den' && den.getVar(DenEventVars.hooligan) == true;

/// Виставляє [DenEventVars.hooligan], якщо виконані всі три етапи (міграція старих сейвів).
void syncDenHooliganQuestFlagFromProgress(NPCModel den) {
  if (den.id != 'den') return;
  if (den.getVar(DenEventVars.firstMeetingDone) == true &&
      den.getVar(DenEventVars.secondMeeting) == true &&
      den.getVar(DenEventVars.thirdMeeting) == true) {
    den.setVar(DenEventVars.hooligan, true);
  }
}

/// Тексти діалогів Дена (квест hooligan).
String getDenDialogueText({
  required NPCModel den,
  required DenIntroUiPhase introPhase,
  required bool secondInProgress,
  required DenSecondUiPhase secondPhase,
  required DenThirdUiPhase thirdPhase,
  required DenAfterUiPhase afterPhase,
}) {
  final denFirstMeetingDone = den.getVar(DenEventVars.firstMeetingDone) == true;
  final denIntroduction = den.getVar(DenEventVars.introduction) == true;
  final denSecondMeeting = den.getVar(DenEventVars.secondMeeting) == true;
  final denThirdMeeting = den.getVar(DenEventVars.thirdMeeting) == true;

  const firstPrompt = 'Чого треба? Скоса глянув на мене Вован.';

  const stage1Introduce = '''
Привіт, хотів познайомитися! Я Сергій Смирнов.
Першокурсник? Ясно! Парень пробігся по мені байдужим поглядом. Стій! А це не твоя сестра на старших курсах вчиться? Оксана?
Моя! Кивнув я.
Класна дівка! Я б її... Мрійливо посміхнувся Вова. Чого ти хотів?
Познайомитись, може подружитись! Знизав я плечима.
З якого дива? Здивувався він. Хто ти, а хто я. Ти щось круте зробив?
Ні! А що треба? Я готовий!
Та хрін його знає... Замислився він. Слабо покурити просто в аудиторії?
''';

  const stage1Agree =
      'Я зайшов в аудиторію і закурив сигарету. Викладачка офігела, наорала і потягла мене до завуча Лизавети Андріївни...';

  const stage1BlyaVideo = '''
Так! Хто тут у нас... подивилася списки жінка.
Смирнов! Тиждень навчаєшся, а вже відзначився! Ну і навіщо ти вирішив курити в аудиторії? Вулиці тобі не вистачило.
Каюсь! Зробив я скорботну міну.
Це все нерви! Видав я.
Малий, які в твоєму віці можуть бути нерви! Зітхнула вона.
Гаразд, нервовий, йди! Ще раз попадешся — говоритимемо інакше!
''';

  const stage2Prompt = 'Чого треба? Скоса глянув на мене Вован.';

  const stage2AfterDiscuss = '''
Ну красень! Посміхнувся мені Вован. Справа дріб'язкова, але не злякався, а зробив! Молодець!
Нічого складного! Кивнув я.
Може, і вийде з тебе нормальний пацан! Але покурити — це фігня.
Слабо балончиком розмалювати кабінет нашої завучки Лизки?
''';

  const stage2AfterAgree = '''
Я взяв рюкзак з балончиками і пішов до її кабінету. Дочекавшись, поки вона вийде, я проник усередину і став розмальовувати її картини фарбою.
Коли вже збирався звалювати, несподівано зайшла завуч:
Смирнов! Ти здурів? Негайно зі мною! До ректора!
''';

  const stage2AfterDa = '''
Ну зрозуміло! Кивнув ректор, коли ми сіли в його кабінеті, а Лизавета Андріївна розповіла, що я накоїв.
І навіщо ти це зробив?
Не знаю! Просто потягнуло на творчість! Хотів додати полотнам фарб.
Смирнов! Ти зариваєшся! Ти на межі відрахування!
Так?!
А що, ви мене не виженете?
— Ні! Смирнов, я просто так не здаюся!
''';

  const stage2AfterHowQuestion = 'І як же?';

  const stage2AfterHow = '''
Будеш удень у вихідні приходити до нас додому і чистити басейн.
У період з 10 до 16 хтось завжди вдома. Будеш відпрацьовувати!
А багато відпрацьовувати?
Стільки, скільки я скажу, ледарю! А тепер геть із цього кабінету.
''';

  const stage3Prompt = 'Чого треба? Скоса глянув на мене Вован.';

  const stage3AfterDiscuss = '''
От тепер я вірю, що ми зможемо здружитися! Розплився в усмішці Вован.
Ну красень! Піднасрав Лизці! Як тебе не вигнали?
Домовився! Махнув я рукою.
Красавчик! Дав мені п'ять. Якщо що — підгрібай.
''';

  const afterThirdTalk = '''
Как делишки, Вован?
Заебок, Смирный! Ты чо как?
Тоже нормалдос!
Ну и красавелла!
''';

  if (!denFirstMeetingDone) {
    switch (introPhase) {
      case DenIntroUiPhase.initial:
        return firstPrompt;
      case DenIntroUiPhase.agreed:
        return stage1Introduce;
      case DenIntroUiPhase.blya:
        return stage1Agree;
      case DenIntroUiPhase.afterBlya:
        return stage1BlyaVideo;
    }
  }

  if (!denIntroduction) return stage2Prompt;
  if (secondInProgress) {
    switch (secondPhase) {
      case DenSecondUiPhase.initial:
      case DenSecondUiPhase.afterDiscuss:
        return stage2AfterDiscuss;
      case DenSecondUiPhase.afterAgree:
        return stage2AfterAgree;
      case DenSecondUiPhase.afterBlya:
        return stage2AfterDa;
      case DenSecondUiPhase.afterDa:
        return stage2AfterHowQuestion;
      case DenSecondUiPhase.afterHow:
        return stage2AfterHow;
    }
  }

  if (!denSecondMeeting) {
    return den.getVar(DenEventVars.secondChainDone) == true ? stage3Prompt : stage2Prompt;
  }
  if (!denThirdMeeting) {
    if (thirdPhase == DenThirdUiPhase.afterDiscuss) return stage3AfterDiscuss;
    return stage3Prompt;
  }
  if (afterPhase == DenAfterUiPhase.afterTalk) return afterThirdTalk;
  return stage3AfterDiscuss;
}
