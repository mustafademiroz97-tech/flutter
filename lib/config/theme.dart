import 'package:flutter/material.dart';

/// Dark theme configuration for the application
class DarkThemeConfig {
  // ==================== Color Palette ====================
  
  /// Primary colors
  static const Color primaryColor = Color(0xFF1F1F1F);
  static const Color primaryLight = Color(0xFF2D2D2D);
  static const Color primaryDark = Color(0xFF121212);
  
  /// Secondary colors
  static const Color secondaryColor = Color(0xFF6C5CE7);
  static const Color secondaryLight = Color(0xFF7D6EFF);
  static const Color secondaryDark = Color(0xFF5F4FD5);
  
  /// Accent colors
  static const Color accentColor = Color(0xFF00D4FF);
  static const Color accentLight = Color(0xFF1DE9B6);
  static const Color accentDark = Color(0xFF00B8D4);
  
  /// Neutral colors
  static const Color backgroundColor = Color(0xFF0F0F0F);
  static const Color surfaceColor = Color(0xFF1A1A1A);
  static const Color cardColor = Color(0xFF252525);
  static const Color dividerColor = Color(0xFF3A3A3A);
  
  /// Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textTertiary = Color(0xFF808080);
  static const Color textHint = Color(0xFF606060);
  
  /// Status colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFFF6B6B);
  static const Color warningColor = Color(0xFFFFA500);
  static const Color infoColor = Color(0xFF2196F3);
  
  /// Semantic colors
  static const Color disabledColor = Color(0xFF424242);
  static const Color shadowColor = Color(0xFF000000);
  static const Color overlayColor = Color(0x99000000);
  
  // ==================== Typography ====================
  
  /// Font family
  static const String fontFamilyPrimary = 'Roboto';
  static const String fontFamilySecondary = 'RobotoMono';
  
  /// Display text styles
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 57,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    color: textPrimary,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 45,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    color: textPrimary,
  );
  
  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 36,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    color: textPrimary,
  );
  
  /// Headline text styles
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    color: textPrimary,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: textPrimary,
  );
  
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: textPrimary,
  );
  
  /// Title text styles
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: textPrimary,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    color: textPrimary,
  );
  
  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: textPrimary,
  );
  
  /// Body text styles
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    color: textPrimary,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    color: textPrimary,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    color: textSecondary,
  );
  
  /// Label text styles
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: textPrimary,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: textSecondary,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: textTertiary,
  );
  
  // ==================== Component Themes ====================
  
  /// AppBar theme
  static AppBarTheme get appBarTheme => AppBarTheme(
    backgroundColor: primaryColor,
    foregroundColor: textPrimary,
    elevation: 0,
    centerTitle: false,
    toolbarHeight: 56,
    titleTextStyle: headlineMedium,
    iconTheme: const IconThemeData(color: textPrimary),
    actionsIconTheme: const IconThemeData(color: textPrimary),
    surfaceTintColor: Colors.transparent,
  );
  
  /// Floating Action Button theme
  static FloatingActionButtonThemeData get floatingActionButtonTheme =>
      FloatingActionButtonThemeData(
    backgroundColor: secondaryColor,
    foregroundColor: textPrimary,
    elevation: 6,
    focusElevation: 8,
    hoverElevation: 8,
    highlightElevation: 12,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  );
  
  /// ElevatedButton theme
  static ElevatedButtonThemeData get elevatedButtonTheme =>
      ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: secondaryColor,
      foregroundColor: textPrimary,
      disabledBackgroundColor: disabledColor,
      disabledForegroundColor: textTertiary,
      elevation: 4,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: labelLarge,
    ),
  );
  
  /// OutlinedButton theme
  static OutlinedButtonThemeData get outlinedButtonTheme =>
      OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: secondaryColor,
      disabledForegroundColor: textTertiary,
      side: const BorderSide(color: secondaryColor, width: 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: labelLarge,
    ),
  );
  
  /// TextButton theme
  static TextButtonThemeData get textButtonTheme => TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: secondaryColor,
      disabledForegroundColor: textTertiary,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      textStyle: labelLarge,
    ),
  );
  
  /// InputDecoration theme
  static InputDecorationTheme get inputDecorationTheme =>
      InputDecorationTheme(
    filled: true,
    fillColor: cardColor,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: dividerColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: dividerColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: secondaryColor, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: errorColor),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: errorColor, width: 2),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: dividerColor),
    ),
    hintStyle: bodyMedium.copyWith(color: textHint),
    labelStyle: bodyMedium.copyWith(color: textSecondary),
    helperStyle: bodySmall.copyWith(color: textTertiary),
    errorStyle: bodySmall.copyWith(color: errorColor),
    prefixIconColor: textSecondary,
    suffixIconColor: textSecondary,
    errorMaxLines: 2,
  );
  
  /// Card theme
  static CardTheme get cardTheme => CardTheme(
    color: cardColor,
    elevation: 2,
    margin: const EdgeInsets.all(0),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    shadowColor: shadowColor.withOpacity(0.3),
    clipBehavior: Clip.antiAlias,
  );
  
  /// Dialog theme
  static DialogTheme get dialogTheme => DialogTheme(
    backgroundColor: surfaceColor,
    elevation: 8,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    titleTextStyle: headlineSmall,
    contentTextStyle: bodyMedium,
  );
  
  /// SnackBar theme
  static SnackBarThemeData get snackBarTheme => SnackBarThemeData(
    backgroundColor: primaryLight,
    contentTextStyle: bodyMedium.copyWith(color: textPrimary),
    elevation: 6,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    actionTextColor: accentColor,
    behavior: SnackBarBehavior.floating,
  );
  
  /// Bottom Navigation Bar theme
  static BottomNavigationBarThemeData get bottomNavigationBarTheme =>
      BottomNavigationBarThemeData(
    backgroundColor: primaryColor,
    selectedItemColor: secondaryColor,
    unselectedItemColor: textTertiary,
    elevation: 8,
    type: BottomNavigationBarType.fixed,
    selectedLabelStyle: labelMedium.copyWith(color: secondaryColor),
    unselectedLabelStyle: labelMedium.copyWith(color: textTertiary),
    showUnselectedLabels: true,
  );
  
  /// Chip theme
  static ChipThemeData get chipTheme => ChipThemeData(
    backgroundColor: cardColor,
    selectedColor: secondaryColor,
    disabledColor: disabledColor,
    labelPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    labelStyle: labelMedium.copyWith(color: textPrimary),
    secondaryLabelStyle: labelMedium.copyWith(color: textPrimary),
    brightness: Brightness.dark,
  );
  
  /// Slider theme
  static SliderThemeData get sliderTheme => SliderThemeData(
    activeTrackColor: secondaryColor,
    inactiveTrackColor: dividerColor,
    disabledActiveTrackColor: disabledColor,
    disabledInactiveTrackColor: dividerColor,
    activeTickMarkColor: secondaryColor,
    inactiveTickMarkColor: dividerColor,
    disabledActiveTickMarkColor: disabledColor,
    disabledInactiveTickMarkColor: dividerColor,
    thumbColor: secondaryColor,
    disabledThumbColor: disabledColor,
    overlayColor: secondaryColor.withOpacity(0.3),
    valueIndicatorColor: secondaryColor,
    valueIndicatorStrokeColor: secondaryDark,
    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
    overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
    tickMarkShape: const RoundSliderTickMarkShape(),
  );
  
  /// Switch theme
  static SwitchThemeData get switchTheme => SwitchThemeData(
    thumbColor: MaterialStatePropertyAll<Color>(
      MaterialStateColor.resolveWith(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return secondaryColor;
          }
          return textTertiary;
        },
      ),
    ),
    trackColor: MaterialStatePropertyAll<Color>(
      MaterialStateColor.resolveWith(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return secondaryColor.withOpacity(0.3);
          }
          return dividerColor;
        },
      ),
    ),
  );
  
  /// ListTile theme
  static ListTileThemeData get listTileTheme => const ListTileThemeData(
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    textColor: textPrimary,
    iconColor: textSecondary,
    selectedTileColor: cardColor,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
  );
  
  /// CheckBox theme
  static CheckboxThemeData get checkboxTheme => CheckboxThemeData(
    fillColor: MaterialStatePropertyAll<Color>(
      MaterialStateColor.resolveWith(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return secondaryColor;
          }
          return Colors.transparent;
        },
      ),
    ),
    borderSide: MaterialStatePropertyAll<BorderSide>(
      BorderSide(
        color: MaterialStateColor.resolveWith(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return secondaryColor;
            }
            return dividerColor;
          },
        ),
        width: 2,
      ),
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  );
  
  /// Radio theme
  static RadioThemeData get radioTheme => RadioThemeData(
    fillColor: MaterialStatePropertyAll<Color>(
      MaterialStateColor.resolveWith(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return secondaryColor;
          }
          return textTertiary;
        },
      ),
    ),
  );
  
  // ==================== Utility Methods ====================
  
  /// Get the complete ThemeData object
  static ThemeData getThemeData() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      primaryColorLight: primaryLight,
      primaryColorDark: primaryDark,
      scaffoldBackgroundColor: backgroundColor,
      canvasColor: surfaceColor,
      cardColor: cardColor,
      shadowColor: shadowColor,
      highlightColor: secondaryColor.withOpacity(0.2),
      splashColor: secondaryColor.withOpacity(0.3),
      hoverColor: secondaryColor.withOpacity(0.1),
      focusColor: secondaryColor.withOpacity(0.2),
      disabledColor: disabledColor,
      dividerColor: dividerColor,
      dialogBackgroundColor: surfaceColor,
      indicatorColor: secondaryColor,
      errorColor: errorColor,
      appBarTheme: appBarTheme,
      floatingActionButtonTheme: floatingActionButtonTheme,
      elevatedButtonTheme: elevatedButtonTheme,
      outlinedButtonTheme: outlinedButtonTheme,
      textButtonTheme: textButtonTheme,
      inputDecorationTheme: inputDecorationTheme,
      cardTheme: cardTheme,
      dialogTheme: dialogTheme,
      snackBarTheme: snackBarTheme,
      bottomNavigationBarTheme: bottomNavigationBarTheme,
      chipTheme: chipTheme,
      sliderTheme: sliderTheme,
      switchTheme: switchTheme,
      listTileTheme: listTileTheme,
      checkboxTheme: checkboxTheme,
      radioTheme: radioTheme,
      textTheme: TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        displaySmall: displaySmall,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      ),
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        onPrimary: textPrimary,
        primaryContainer: primaryLight,
        onPrimaryContainer: textPrimary,
        secondary: secondaryColor,
        onSecondary: textPrimary,
        secondaryContainer: secondaryLight,
        onSecondaryContainer: textPrimary,
        tertiary: accentColor,
        onTertiary: textPrimary,
        tertiaryContainer: accentLight,
        onTertiaryContainer: textPrimary,
        error: errorColor,
        onError: textPrimary,
        errorContainer: errorColor.withOpacity(0.2),
        onErrorContainer: errorColor,
        background: backgroundColor,
        onBackground: textPrimary,
        surface: surfaceColor,
        onSurface: textPrimary,
        surfaceVariant: cardColor,
        onSurfaceVariant: textSecondary,
        outline: dividerColor,
        outlineVariant: dividerColor.withOpacity(0.5),
        scrim: shadowColor.withOpacity(0.5),
        inverseSurface: textPrimary,
        inverseOnSurface: backgroundColor,
        inversePrimary: secondaryColor,
      ),
    );
  }
  
  /// Get color with opacity
  static Color getColorWithOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
  
  /// Get contrast text color (white or black) based on background
  static Color getContrastTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
  
  /// Get shadow elevation color
  static List<BoxShadow> getBoxShadow({
    int elevation = 2,
    bool isDark = true,
  }) {
    final baseColor = isDark ? shadowColor : const Color(0xFF000000);
    final opacity = (elevation / 24) * 0.3;
    return [
      BoxShadow(
        color: baseColor.withOpacity(opacity * 0.3),
        blurRadius: elevation.toDouble(),
        offset: Offset(0, elevation * 0.25),
      ),
    ];
  }
  
  /// Get gradient colors
  static LinearGradient getPrimaryGradient({
    begin = Alignment.topLeft,
    end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: [secondaryColor, secondaryDark],
    );
  }
  
  static LinearGradient getAccentGradient({
    begin = Alignment.topLeft,
    end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: [accentColor, accentDark],
    );
  }
  
  /// Get border radius utility
  static BorderRadius getBorderRadius(double radius) {
    return BorderRadius.circular(radius);
  }
  
  static const BorderRadius smallBorderRadius = BorderRadius.all(Radius.circular(4));
  static const BorderRadius mediumBorderRadius = BorderRadius.all(Radius.circular(8));
  static const BorderRadius largeBorderRadius = BorderRadius.all(Radius.circular(12));
  static const BorderRadius extraLargeBorderRadius = BorderRadius.all(Radius.circular(16));
  
  /// Get edge insets utility
  static const EdgeInsets extraSmallPadding = EdgeInsets.all(4);
  static const EdgeInsets smallPadding = EdgeInsets.all(8);
  static const EdgeInsets mediumPadding = EdgeInsets.all(16);
  static const EdgeInsets largePadding = EdgeInsets.all(24);
  static const EdgeInsets extraLargePadding = EdgeInsets.all(32);
  
  /// Duration constants
  static const Duration shortDuration = Duration(milliseconds: 150);
  static const Duration mediumDuration = Duration(milliseconds: 300);
  static const Duration longDuration = Duration(milliseconds: 500);
  
  /// Curve constants for animations
  static const Cubic smoothCurve = Curves.easeInOutCubic;
  static const Cubic fastCurve = Curves.easeOutCubic;
  static const Cubic slowCurve = Curves.easeInCubic;
}
