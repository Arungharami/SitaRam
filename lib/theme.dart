import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Production Devotional Color Scheme
  static const Color maroonBg = Color(0xFF1F0B05); // Deep Temple Maroon
  static const Color templeObsidian = Color(0xFF170803); // Darker tone
  static const Color saffronPrimary = Color(0xFFE65100); // Spiritual Orange
  static const Color goldAccent = Color(0xFFD4AF37); // Devotional Gold
  static const Color cardBgMaroon = Color(0xFF2E130A); // Rich Card background
  static const Color softCreamText = Color(0xFFFFFDF9); // Calming ivory text
  static const Color textDimMaroon = Color(0xFFC7B1A8); // Soft text on dark background

  // Gradients
  static const LinearGradient saffronGoldGradient = LinearGradient(
    colors: [saffronPrimary, Color(0xFFFF8F00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient templeGradient = LinearGradient(
    colors: [maroonBg, templeObsidian],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGlassGradient = LinearGradient(
    colors: [
      Color(0x24FFFFFF),
      Color(0x06FFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: maroonBg,
      primaryColor: saffronPrimary,
      colorScheme: const ColorScheme.dark(
        surface: cardBgMaroon,
        primary: saffronPrimary,
        secondary: goldAccent,
        onPrimary: Colors.white,
        onSurface: softCreamText,
        outline: Colors.white10,
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.dark().textTheme.copyWith(
          titleLarge: const TextStyle(fontWeight: FontWeight.bold, color: softCreamText),
          titleMedium: const TextStyle(fontWeight: FontWeight.w600, color: softCreamText),
          bodyLarge: const TextStyle(color: softCreamText, height: 1.6),
          bodyMedium: const TextStyle(color: textDimMaroon, height: 1.5),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: maroonBg,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: softCreamText,
        ),
        iconTheme: IconThemeData(color: softCreamText),
      ),
      cardTheme: CardThemeData(
        color: cardBgMaroon,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.white12),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: templeObsidian,
        selectedItemColor: saffronPrimary,
        unselectedItemColor: textDimMaroon,
        elevation: 8,
      ),
    );
  }

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFFFF8F0),
      primaryColor: saffronPrimary,
      colorScheme: const ColorScheme.light(
        surface: Color(0xFFFFF3E0),
        primary: saffronPrimary,
        secondary: goldAccent,
        onPrimary: Colors.white,
        onSurface: Color(0xFF1F0B05),
        outline: Colors.black12,
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.light().textTheme,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFFF8F0),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1F0B05),
        ),
        iconTheme: IconThemeData(color: Color(0xFF1F0B05)),
      ),
      cardTheme: CardThemeData(
        color: Color(0xFFFFF3E0),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: Colors.black12),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Color(0xFFFFF8F0),
        selectedItemColor: saffronPrimary,
        unselectedItemColor: Color(0xFF8D6E63),
        elevation: 8,
      ),
    );
  }

  // Premium container styling helper (lotus styling cards)
  static BoxDecoration devotionalCardDecoration({
    double borderRadius = 16,
    Color borderColor = Colors.white12,
  }) {
    return BoxDecoration(
      color: cardBgMaroon,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor),
      boxShadow: const [
        BoxShadow(
          color: Colors.black38,
          blurRadius: 12,
          offset: Offset(0, 6),
        )
      ],
    );
  }

  // Decorative Lotus border styling (subtle saffron/gold)
  static BoxDecoration lotusCardDecoration() {
    return BoxDecoration(
      color: cardBgMaroon,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: goldAccent.withValues(alpha: 0.4), width: 1.5),
      boxShadow: [
        BoxShadow(
          color: saffronPrimary.withValues(alpha: 0.15),
          blurRadius: 10,
          spreadRadius: 2,
        )
      ],
    );
  }
}
