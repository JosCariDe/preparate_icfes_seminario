import 'package:flutter/material.dart';
import 'package:preparate_icfes_seminario/config/theme/app_colors.dart';
import 'package:preparate_icfes_seminario/config/theme/app_text_styles.dart';

class AppTheme {
  ThemeData getTheme() => ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.primaryBackground,
        textTheme: const TextTheme(
          displayLarge: AppTextStyles.heading1,
          bodyLarge: AppTextStyles.bodyText,
        ),
      );
}
