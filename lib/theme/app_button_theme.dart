import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

class AppButtonTheme {
  AppButtonTheme._();

  static ElevatedButtonThemeData elevated() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shape: const StadiumBorder(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: AppTextStyles.subtitle.copyWith(color: Colors.white),
      ).copyWith(
        overlayColor: WidgetStateProperty.all(
          AppColors.primary.withOpacity(0.08),
        ),
      ),
    );
  }

  static OutlinedButtonThemeData outlined() {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: const StadiumBorder(),
        side: const BorderSide(color: AppColors.primary, width: 1.4),
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: AppTextStyles.subtitle.copyWith(color: AppColors.primary),
      ).copyWith(
        overlayColor: WidgetStateProperty.all(
          AppColors.primary.withOpacity(0.08),
        ),
      ),
    );
  }

  static TextButtonThemeData text() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: AppTextStyles.subtitle.copyWith(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ).copyWith(
        overlayColor: WidgetStateProperty.all(
          AppColors.primary.withOpacity(0.08),
        ),
      ),
    );
  }
}
