import 'package:ezymember/constants/app_colors.dart';
import 'package:flutter/material.dart';

class AppThemes {
  ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.lightPrimary,
      onPrimary: AppColors.lightOnPrimary,
      primaryContainer: AppColors.lightPrimaryContainer,
      onPrimaryContainer: AppColors.lightOnPrimaryContainer,

      secondary: AppColors.lightSecondary,
      onSecondary: AppColors.lightOnSecondary,
      secondaryContainer: AppColors.lightSecondaryContainer,
      onSecondaryContainer: AppColors.lightOnSecondaryContainer,

      tertiary: AppColors.lightTertiary,
      onTertiary: AppColors.lightOnTertiary,
      tertiaryContainer: AppColors.lightTertiaryContainer,
      onTertiaryContainer: AppColors.lightOnTertiaryContainer,

      error: AppColors.lightError,
      onError: AppColors.lightOnError,
      errorContainer: AppColors.lightErrorContainer,
      onErrorContainer: AppColors.lightOnErrorContainer,

      surface: AppColors.lightSurface,
      onSurface: AppColors.lightOnSurface,
      surfaceDim: AppColors.lightSurfaceDim,
      surfaceBright: AppColors.lightSurfaceBright,

      surfaceContainerLowest: AppColors.lightSurfaceContainerLowest,
      surfaceContainerLow: AppColors.lightSurfaceContainerLow,
      surfaceContainer: AppColors.lightSurfaceContainer,
      surfaceContainerHigh: AppColors.lightSurfaceContainerHigh,
      surfaceContainerHighest: AppColors.lightSurfaceContainerHighest,

      onSurfaceVariant: AppColors.lightSecondaryText,
      outline: AppColors.lightSecondaryText,
      outlineVariant: AppColors.lightSecondaryText,
      shadow: AppColors.lightShadow,
      scrim: Color(0x55000000),

      inverseSurface: Color(0xFF212121),
      onInverseSurface: AppColors.lightOnPrimary,
      inversePrimary: Color(0xFF2196F3),

      surfaceTint: AppColors.lightPrimary,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: AppColors.lightPrimary,
      iconTheme: IconThemeData(color: AppColors.lightOnPrimary),
      titleTextStyle: TextStyle(color: AppColors.lightOnPrimary, fontSize: 20.0, fontWeight: FontWeight.bold),
    ),
    fontFamily: "AlibabaPuHuiTi",
  );
}
