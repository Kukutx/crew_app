import 'dart:ui';

import 'package:flutter/material.dart';

import 'app_button_theme.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      background: AppColors.background,
      surface: AppColors.surface,
      onBackground: AppColors.onSurface,
      onSurface: AppColors.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Inter',
      textTheme: TextTheme(
        displayLarge: AppTextStyles.display,
        displayMedium: AppTextStyles.display,
        headlineLarge: AppTextStyles.headline,
        headlineMedium: AppTextStyles.title,
        headlineSmall: AppTextStyles.subtitle,
        titleLarge: AppTextStyles.title,
        titleMedium: AppTextStyles.subtitle,
        titleSmall: AppTextStyles.caption,
        bodyLarge: AppTextStyles.body,
        bodyMedium: AppTextStyles.body,
        bodySmall: AppTextStyles.caption,
        labelLarge: AppTextStyles.subtitle,
        labelMedium: AppTextStyles.caption,
        labelSmall: AppTextStyles.chip,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: AppColors.onSurface,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        shadowColor: AppColors.onSurface.withOpacity(0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.zero,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: StadiumBorder(),
        elevation: 6,
      ),
      elevatedButtonTheme: AppButtonTheme.elevated(),
      outlinedButtonTheme: AppButtonTheme.outlined(),
      textButtonTheme: AppButtonTheme.text(),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppColors.border.withOpacity(0.6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppColors.border.withOpacity(0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
        hintStyle: AppTextStyles.bodyMuted,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.background,
        selectedColor: AppColors.primary.withOpacity(0.1),
        disabledColor: AppColors.border,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        labelStyle: AppTextStyles.chip,
        secondaryLabelStyle: AppTextStyles.chip.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
      ),
      dividerTheme: const DividerThemeData(space: 1, color: Colors.transparent),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      dialogBackgroundColor: AppColors.surface,
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface.withOpacity(0.94),
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        showDragHandle: true,
      ),
      iconTheme: const IconThemeData(color: AppColors.onSurface),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        indicatorColor: AppColors.primary.withOpacity(0.12),
        backgroundColor: AppColors.surface.withOpacity(0.92),
      ),
      splashFactory: InkSparkle.splashFactory,
      extensions: const <ThemeExtension<dynamic>>[
        GlassBackgroundTheme(),
      ],
    );
  }
}

class GlassBackgroundTheme extends ThemeExtension<GlassBackgroundTheme> {
  const GlassBackgroundTheme({this.blurSigma = 18, this.opacity = 0.92});

  final double blurSigma;
  final double opacity;

  @override
  ThemeExtension<GlassBackgroundTheme> copyWith({
    double? blurSigma,
    double? opacity,
  }) {
    return GlassBackgroundTheme(
      blurSigma: blurSigma ?? this.blurSigma,
      opacity: opacity ?? this.opacity,
    );
  }

  @override
  ThemeExtension<GlassBackgroundTheme> lerp(
    covariant ThemeExtension<GlassBackgroundTheme>? other,
    double t,
  ) {
    if (other is! GlassBackgroundTheme) {
      return this;
    }
    return GlassBackgroundTheme(
      blurSigma: lerpDouble(blurSigma, other.blurSigma, t) ?? blurSigma,
      opacity: lerpDouble(opacity, other.opacity, t) ?? opacity,
    );
  }
}
