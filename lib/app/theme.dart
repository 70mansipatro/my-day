import 'package:flutter/material.dart';

import 'app_colors.dart';

/// App-wide Material 3 theme configuration.
///
/// Brand color is Peach (see [AppColors.peach500]). Peach surfaces always
/// pair with dark ([AppColors.gray800]) text/icons for readability — never
/// white-on-peach.
class AppTheme {
  AppTheme._();

  static const Color primaryColor = AppColors.peach500;

  static const double _cardRadius = 16;
  static const double _controlRadius = 12;
  static const double _chipRadius = 20;
  static const double _dialogRadius = 20;

  static ColorScheme get _lightColorScheme =>
      ColorScheme.fromSeed(
        seedColor: AppColors.peach500,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppColors.peach500,
        onPrimary: AppColors.gray800,
        primaryContainer: AppColors.peach100,
        onPrimaryContainer: AppColors.gray800,
        secondary: AppColors.peach600,
        onSecondary: AppColors.gray800,
        secondaryContainer: AppColors.peach200,
        onSecondaryContainer: AppColors.gray800,
        surface: AppColors.white,
        onSurface: AppColors.gray800,
        surfaceContainerHighest: AppColors.peach100,
        surfaceContainer: AppColors.peach50,
        outline: AppColors.gray200,
        outlineVariant: AppColors.gray200,
        onSurfaceVariant: AppColors.gray600,
        error: Colors.red,
        onError: AppColors.white,
      );

  static ColorScheme get _darkColorScheme =>
      ColorScheme.fromSeed(
        seedColor: AppColors.peach500,
        brightness: Brightness.dark,
      ).copyWith(
        primary: AppColors.peach500,
        onPrimary: AppColors.gray800,
        primaryContainer: AppColors.darkPrimaryContainer,
        onPrimaryContainer: AppColors.white,
        secondary: AppColors.peach600,
        onSecondary: AppColors.gray800,
        secondaryContainer: AppColors.darkPrimaryContainer,
        onSecondaryContainer: AppColors.white,
        surface: AppColors.darkSurface,
        onSurface: AppColors.white,
        surfaceContainerHighest: AppColors.darkSurface,
        outline: AppColors.darkBorder,
        outlineVariant: AppColors.darkBorder,
        onSurfaceVariant: AppColors.darkSecondaryText,
        error: Colors.red,
        onError: AppColors.white,
      );

  /// Soft, warm, minimal light theme built around the Peach brand color.
  static ThemeData get lightTheme => _buildTheme(_lightColorScheme);

  /// Dark counterpart, kept ready for when the app wires up a theme
  /// toggle — Peach is used only as an accent, not a background.
  static ThemeData get darkTheme => _buildTheme(_darkColorScheme);

  static ThemeData _buildTheme(ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    final Color scaffoldBg = isDark
        ? AppColors.darkBackground
        : AppColors.peach50;
    final Color cardBg = scheme.surface;
    final Color borderColor = scheme.outline;
    final Color mutedText = scheme.onSurfaceVariant;
    final Color disabledBg = isDark ? AppColors.darkBorder : AppColors.gray200;
    final Color disabledFg = AppColors.gray400;
    final Color unselectedControl = isDark
        ? AppColors.darkSecondaryText
        : AppColors.gray400;

    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBg,
      splashColor: AppColors.peach200.withValues(alpha: 0.3),
      highlightColor: AppColors.peach100.withValues(alpha: 0.2),

      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: cardBg,
        foregroundColor: scheme.onSurface,
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),

      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardRadius),
          side: BorderSide(color: borderColor),
        ),
      ),

      dividerTheme: DividerThemeData(color: borderColor, thickness: 1),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkSurface : AppColors.peach50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_controlRadius),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_controlRadius),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_controlRadius),
          borderSide: const BorderSide(color: AppColors.peach500, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_controlRadius),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_controlRadius),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        labelStyle: TextStyle(color: mutedText),
        floatingLabelStyle: const TextStyle(color: AppColors.peach900),
        hintStyle: TextStyle(color: mutedText),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size.fromHeight(50)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_controlRadius),
            ),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return disabledBg;
            if (states.contains(WidgetState.pressed)) return AppColors.peach600;
            return AppColors.peach500;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return disabledFg;
            return AppColors.gray800;
          }),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size.fromHeight(50)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_controlRadius),
            ),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return disabledBg;
            if (states.contains(WidgetState.pressed)) return AppColors.peach600;
            return AppColors.peach500;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return disabledFg;
            return AppColors.gray800;
          }),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size.fromHeight(50)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_controlRadius),
            ),
          ),
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return BorderSide(color: borderColor);
            }
            return const BorderSide(color: AppColors.peach500);
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return disabledFg;
            return AppColors.peach900;
          }),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return disabledFg;
            return AppColors.peach900;
          }),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.peach500,
        foregroundColor: AppColors.gray800,
        splashColor: AppColors.peach600,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardBg,
        indicatorColor: isDark
            ? AppColors.darkPrimaryContainer
            : AppColors.peach100,
        surfaceTintColor: Colors.transparent,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.peach900 : unselectedControl,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? scheme.onSurface : unselectedControl,
          );
        }),
      ),

      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return disabledBg;
          if (states.contains(WidgetState.selected)) return AppColors.peach500;
          return Colors.transparent;
        }),
        checkColor: const WidgetStatePropertyAll(AppColors.gray800),
        side: BorderSide(color: borderColor, width: 1.5),
      ),

      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.peach500;
          return isDark ? AppColors.darkBorder : AppColors.gray300;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.peach500;
          return borderColor;
        }),
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.gray800;
          return AppColors.white;
        }),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return disabledFg;
          if (states.contains(WidgetState.selected)) return AppColors.peach500;
          return unselectedControl;
        }),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: isDark
            ? AppColors.darkSurface
            : const Color(0xFFF5F5F5),
        selectedColor: AppColors.peach200,
        disabledColor: disabledBg,
        labelStyle: TextStyle(color: scheme.onSurface),
        secondaryLabelStyle: const TextStyle(color: AppColors.gray800),
        side: BorderSide(color: borderColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_chipRadius),
          side: const BorderSide(color: Colors.transparent),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.peach500,
        linearTrackColor: isDark ? AppColors.darkBorder : AppColors.peach100,
        circularTrackColor: isDark ? AppColors.darkBorder : AppColors.peach100,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: cardBg,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_dialogRadius),
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardBg,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(_dialogRadius),
          ),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.gray800,
        contentTextStyle: const TextStyle(color: AppColors.white),
        actionTextColor: AppColors.peach300,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_controlRadius),
        ),
      ),

      datePickerTheme: DatePickerThemeData(
        backgroundColor: cardBg,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: AppColors.peach500,
        headerForegroundColor: AppColors.gray800,
        todayBorder: const BorderSide(color: AppColors.peach500),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.gray800;
          return scheme.onSurface;
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.peach500;
          return Colors.transparent;
        }),
      ),

      listTileTheme: ListTileThemeData(iconColor: mutedText),
    );
  }
}
