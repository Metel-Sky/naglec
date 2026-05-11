/// Шляхи та ціни навчання на ноутбуці (`lib/assets/laptop/study`).
library;

const String laptopStudyPath = 'lib/assets/laptop/study';
const String laptopStudyMassagePath = 'lib/assets/laptop/study/massage';

const String laptopProgrammingVideoPath = '$laptopStudyPath/programing_1.webm';
final List<String> laptopProgrammingVideoPaths = List<String>.filled(
  5,
  laptopProgrammingVideoPath,
);

const String laptopLockpickVideoPath = '$laptopStudyPath/breack_lock.webm';
final List<String> laptopLockpickVideoPaths = List<String>.filled(
  5,
  laptopLockpickVideoPath,
);

const String laptopStealthVideoPath = '$laptopStudyPath/stels.webm';
final List<String> laptopStealthVideoPaths = List<String>.filled(
  5,
  laptopStealthVideoPath,
);

const String laptopPasswordVideoPath = '$laptopStudyPath/unlock_pc.webm';
final List<String> laptopPasswordVideoPaths = List<String>.filled(
  5,
  laptopPasswordVideoPath,
);

const String laptopPhoneVideoPath = '$laptopStudyPath/unlock_phone_1.webm';
final List<String> laptopPhoneVideoPaths = List<String>.filled(
  5,
  laptopPhoneVideoPath,
);

final List<String> laptopMassageVideoPaths = [
  '$laptopStudyMassagePath/massage_1.webm',
  '$laptopStudyMassagePath/massage_2.webm',
  '$laptopStudyMassagePath/massage_3.webm',
  '$laptopStudyMassagePath/massage_4.webm',
  '$laptopStudyMassagePath/massage_5.webm',
  '$laptopStudyMassagePath/massage_6.webm',
  '$laptopStudyMassagePath/massage_1.webm',
  '$laptopStudyMassagePath/massage_2.webm',
  '$laptopStudyMassagePath/massage_3.webm',
  '$laptopStudyMassagePath/massage_4.webm',
];
const String laptopEroMassageVideoPath =
    '$laptopStudyMassagePath/ero_massage.webm';

const int laptopPriceProgramming = 250;
const int laptopPriceLockpick = 200;
const int laptopPriceStealth = 300;
const int laptopPricePasswords = 350;
const int laptopPricePhone = 400;
const int laptopPriceMassage = 500;
const int laptopPriceEroMassage = 700;
