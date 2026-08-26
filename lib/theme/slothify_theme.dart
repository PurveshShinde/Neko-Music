import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Slothify brand color palette and theme definition.
class SlothifyColors {
  SlothifyColors._();

  // ── Backgrounds ──
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF14151B);
  static const Color surfaceVariant = Color(0xFF28282A);
  static const Color cardDark = Color(0xFF1E2028);
  static const Color cardElevated = Color(0xFF22232D);

  // ── Brand Accent ──
  static const Color accent = Color(0xFF6C5CE7);
  static const Color accentLight = Color(0xFF8B7CF6);
  static const Color accentDim = Color(0xFF4A3FB5);

  // ── Semantic ──
  static const Color success = Color(0xFF00D68F);
  static const Color error = Color(0xFFFF6B6B);

  // ── Text ──
  static const Color textPrimary = Color(0xFFF0F0F5);
  static const Color textSecondary = Color(0xFF9496A1);
  static const Color textTertiary = Color(0xFF5D5F6E);

  // ── Misc ──
  static const Color border = Color(0xFF2A2B35);
  static const Color shimmer = Color(0xFF2E2F3A);
  static const Color miniPlayerBg = Color(0xFF1E2028);
  static const Color glassBorder = Color(0x30FFFFFF);
  static const Color glassOverlay = Color(0x18FFFFFF);
}

class SlothifyTheme {
  SlothifyTheme._();

  static TextTheme get _outfitTextTheme {
    return GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme);
  }

  static ThemeData get darkTheme {
    final baseTextTheme = _outfitTextTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: SlothifyColors.background,
      colorScheme: ColorScheme.dark(
        surface: SlothifyColors.surface,
        primary: SlothifyColors.accent,
        secondary: SlothifyColors.accentLight,
        error: SlothifyColors.error,
        onPrimary: Colors.white,
        onSurface: SlothifyColors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: SlothifyColors.textPrimary,
          letterSpacing: -0.5,
        ),
        iconTheme: const IconThemeData(color: SlothifyColors.textSecondary),
      ),
      cardTheme: CardThemeData(
        color: SlothifyColors.cardDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: SlothifyColors.surfaceVariant,
        selectedColor: SlothifyColors.accent,
        labelStyle: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: SlothifyColors.textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: SlothifyColors.textSecondary,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: SlothifyColors.surface,
        indicatorColor: SlothifyColors.accent.withValues(alpha: 0.18),
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: SlothifyColors.textSecondary,
          ),
        ),
        iconTheme: const WidgetStatePropertyAll(
          IconThemeData(color: SlothifyColors.textSecondary, size: 22),
        ),
      ),
      textTheme: baseTextTheme.copyWith(
        headlineLarge: GoogleFonts.outfit(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: SlothifyColors.textPrimary,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: SlothifyColors.textPrimary,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: SlothifyColors.textPrimary,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: SlothifyColors.textPrimary,
        ),
        titleSmall: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: SlothifyColors.textSecondary,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: SlothifyColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: SlothifyColors.textSecondary,
        ),
        bodySmall: GoogleFonts.outfit(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: SlothifyColors.textTertiary,
        ),
        labelLarge: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: SlothifyColors.textPrimary,
        ),
      ),
    );
  }
}
