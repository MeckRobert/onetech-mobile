import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppStyles {
  // Colors
  static const Color background = Color(0xFF0F0F10);
  static const Color cardBg = Color(0xFF1B1B1E);
  static const Color accentGold = Color(0xFFE2A540);
  static const Color accentGoldLight = Color(0xFFF3C26B);
  static const Color textMain = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF8E8E93);
  
  static const Color greenProfit = Color(0xFF4CAF50);
  static const Color redExpense = Color(0xFFE53935);

  // Gradient definitions
  static const Gradient goldGradient = LinearGradient(
    colors: [Color(0xFFE2A540), Color(0xFFFFD580)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E1E22), Color(0xFF121214)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Text Styles
  static TextStyle get titleLarge => GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textMain,
      );

  static TextStyle get titleMedium => GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textMain,
      );

  static TextStyle get bodyMain => GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: textMain,
      );

  static TextStyle get bodyMuted => GoogleFonts.outfit(
        fontSize: 13,
        color: textMuted,
      );

  static TextStyle get amountBig => GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textMain,
      );

  static TextStyle get percentGreen => GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: greenProfit,
      );

  static TextStyle get percentRed => GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: redExpense,
      );

  // Card Decoration
  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardBg,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // Button Style
  static ButtonStyle goldButton = ElevatedButton.styleFrom(
    foregroundColor: Colors.black,
    backgroundColor: accentGold,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
  );

  static ButtonStyle outlineButton = ElevatedButton.styleFrom(
    foregroundColor: textMain,
    backgroundColor: Colors.transparent,
    side: const BorderSide(color: accentGold, width: 1.5),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
  );

  // Input Decoration
  static InputDecoration inputDecoration(String hint, {Widget? prefixIcon, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.outfit(color: textMuted, fontSize: 14),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFF1E1E22),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: accentGold, width: 1.5),
      ),
    );
  }
}
