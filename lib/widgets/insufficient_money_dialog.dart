import 'package:flutter/material.dart';

import '../services/locale_controller.dart';
import '../services/service_locator.dart';

/// Модальне вікно, коли операція потребує грошей, а на рахунку їх не вистачає.
void showInsufficientMoneyDialog(BuildContext context) {
  final t = sl<LocaleController>().t;
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      content: Text(t('not_enough_money_dialog_message')),
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
