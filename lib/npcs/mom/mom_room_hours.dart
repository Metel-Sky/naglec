// Годинні вікна для динамічного відео мами в mom_room (окремий файл для стабільної збірки).

/// Три sleep-ролики: з 23:00 до 06:00 (години 23 та 0–5).
bool momRoomSleepTrioHour(int hour) => hour >= 23 || hour < 6;

/// Два ролики «перевдягання»: 22:00–23:00 та 06:00–07:00.
bool momRoomPereodevaetsaPairHour(int hour) =>
    hour == 22 || (hour >= 6 && hour < 7);

/// Будь-яке динамічне відео в `mom_room` замість спрайта з розкладу.
bool momRoomDynamicEveningMediaHour(int hour) =>
    momRoomSleepTrioHour(hour) || momRoomPereodevaetsaPairHour(hour);
