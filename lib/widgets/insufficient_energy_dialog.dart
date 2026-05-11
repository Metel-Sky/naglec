import 'package:flutter/material.dart';

import '../services/locale_controller.dart';
import '../services/service_locator.dart';

/// Модальне вікно, коли для дії не вистачає енергії.
void showInsufficientEnergyDialog(BuildContext context) {
  final t = sl<LocaleController>().t;
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      content: Text(t('not_enough_energy_dialog_message')),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(t('dialog_close')),
        ),
      ],
    ),
  );
}
