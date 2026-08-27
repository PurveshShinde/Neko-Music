import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Neko brand color palette and theme definition.
class NekoColors {
  NekoColors._();

  // ── Backgrounds (AMOLED) ──
  static const Color amoledBackground = Color(0xFF000000);
  static const Color amoledSurface = Color(0xFF121212);
  
  // ── Backgrounds (Light Vintage) ──
  static const Color lightBackground = Color(0xFFF9F6F0);
  static const Color lightSurface = Color(0xFFF4F0E6);

  // ── Brand Accent ──
  static const Color accent = Color(0xFF6C5CE7);

  // ── Semantic ──
  static const Color success = Color(0xFF00D68F);
  static const Color error = Color(0xFFFF6B6B);

  // ── Text (AMOLED) ──
  static const Color amoledTextPrimary = Color(0xFFF5F5F0);
  static const Color amoledTextSecondary = Color(0xFFA3A19C);

  // ── Text (Light Vintage) ──
  static const Color lightTextPrimary = Color(0xFF2C2A28);
  static const Color lightTextSecondary = Color(0xFF5B5651);

  // ── Legacy / Hardcoded Colors (For unmigrated screens) ──
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF14151B);
  static const Color surfaceVariant = Color(0xFF28282A);
  static const Color textSecondary = Color(0xFF9496A1);
  static const Color textTertiary = Color(0xFF5D5F6E);
  static const Color border = Color(0xFF2A2B35);
  static const Color cardDark = Color(0xFF1E2028);
  static const Color miniPlayerBg = Color(0xFF1E2028);

  static Color colorFromTitle(String title) {
    // Filter out greens from the palette
    const palette = [
      Color(0xFF6C5CE7), // Purple
      Color(0xFF0984E3), // Blue  
      Color(0xFFE17055), // Coral
      Color(0xFF2D3436), // Charcoal
      Color(0xFF6D4C41), // Brown
      Color(0xFF4A235A), // Deep Purple
      Color(0xFF1A237E), // Indigo
      Color(0xFFB71C1C), // Deep Red
      Color(0xFF37474F), // Blue Grey
      Color(0xFF880E4F), // Pink
      Color(0xFFE65100), // Deep Orange
      Color(0xFF263238), // Dark Blue Grey
      Color(0xFF4527A0), // Deep Violet
      Color(0xFF5D4037), // Dark Brown
      Color(0xFF283593), // Dark Indigo
    ];
    final index = title.codeUnits.fold(0, (a, b) => a + b) % palette.length;
    return palette[index];
  }
}

extension DynamicColorExt on Color {
  /// Converts a vibrant color to a calm pastel variant for light mode.
  Color toCalmColor() {
    return HSLColor.fromColor(this)
        .withLightness(0.85)
        .withSaturation(0.3)
        .toColor();
  }

  /// Converts a vibrant color to a deep, muted earthy tone for AMOLED mode.
  Color toAmoledMutedColor() {
    return HSLColor.fromColor(this)
        .withLightness(0.20)
        .withSaturation(0.25)
        .toColor();
  }
}

class NekoTheme {
  NekoTheme._();

  static ThemeData getTheme(bool isAmoled) {
    final bgColor = isAmoled ? NekoColors.amoledBackground : NekoColors.lightBackground;
    final surfaceColor = isAmoled ? NekoColors.amoledSurface : NekoColors.lightSurface;
    
    final primaryTextColor = isAmoled ? NekoColors.amoledTextPrimary : NekoColors.lightTextPrimary;
    final secondaryTextColor = isAmoled ? NekoColors.amoledTextSecondary : NekoColors.lightTextSecondary;

    // Use Outfit for base text
    final baseTextTheme = GoogleFonts.outfitTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: isAmoled ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: bgColor,
      colorScheme: ColorScheme(
        brightness: isAmoled ? Brightness.dark : Brightness.light,
        primary: NekoColors.accent,
        onPrimary: Colors.white,
        secondary: NekoColors.accent,
        onSecondary: Colors.white,
        error: NekoColors.error,
        onError: Colors.white,
        surface: surfaceColor,
        onSurface: primaryTextColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: isAmoled 
          ? GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: primaryTextColor,
            )
          : GoogleFonts.playfairDisplay(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: primaryTextColor,
            ),
        iconTheme: IconThemeData(color: secondaryTextColor),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isAmoled 
              ? BorderSide.none 
              : const BorderSide(color: Color(0x15000000), width: 1), // Subtle card edge for light mode
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isAmoled ? const Color(0xFF1E1E1E) : const Color(0xFFEBE5D8),
        selectedColor: NekoColors.accent,
        labelStyle: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: primaryTextColor,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: secondaryTextColor,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceColor,
        indicatorColor: NekoColors.accent.withValues(alpha: 0.18),
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: secondaryTextColor,
          ),
        ),
        iconTheme: WidgetStatePropertyAll(
          IconThemeData(color: secondaryTextColor, size: 22),
        ),
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.pacifico(
          fontSize: 32,
          fontWeight: FontWeight.w400,
          color: primaryTextColor,
        ),
        displayMedium: GoogleFonts.pacifico(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: primaryTextColor,
        ),
        headlineLarge: isAmoled 
          ? GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: primaryTextColor,
            )
          : GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: primaryTextColor,
            ),
        headlineMedium: isAmoled 
          ? GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: primaryTextColor,
            )
          : GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: primaryTextColor,
            ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: primaryTextColor,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: primaryTextColor,
        ),
        titleSmall: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: primaryTextColor,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: primaryTextColor,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: secondaryTextColor,
        ),
        bodySmall: GoogleFonts.outfit(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: secondaryTextColor,
        ),
        labelLarge: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: primaryTextColor,
        ),
      ),
    );
  }
}
