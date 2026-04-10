import 'package:flutter/material.dart';

void showAppSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  final trimmed = message.trim();
  if (trimmed.isEmpty) {
    return;
  }
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) {
    return;
  }
  final theme = Theme.of(context);
  messenger
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError
            ? theme.colorScheme.errorContainer
            : theme.colorScheme.inverseSurface,
        content: Text(
          trimmed,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isError
                ? theme.colorScheme.onErrorContainer
                : theme.colorScheme.onInverseSurface,
          ),
        ),
      ),
    );
}
