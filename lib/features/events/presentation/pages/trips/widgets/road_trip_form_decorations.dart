import 'package:flutter/material.dart';

InputDecoration roadTripInputDecoration(
  BuildContext context,
  String label,
  String? hint,
) {
  final colorScheme = Theme.of(context).colorScheme;

  return InputDecoration(
    labelText: label,
    hintText: hint,
    filled: true,
    fillColor: colorScheme.surface,
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.4)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.4)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: colorScheme.primary, width: 1.8),
    ),
  );
}
