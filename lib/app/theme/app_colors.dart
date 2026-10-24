import 'package:flutter/material.dart';

/// Centralized color tokens for SmartVault.
/// Embodies a luxurious digital vault aesthetic: deep midnight navy foundation,
/// metallic steel surfaces, and warm champagne/amber accents.
class AppColors {
  AppColors._();

  // Dark Theme Palette (Default Vault Aesthetic)
  static const Color darkBackground = Color(0xFF0A0E1A);
  static const Color darkSurface = Color(0xFF121828);
  static const Color darkSurfaceLight = Color(0xFF1A2238);
  static const Color darkCard = Color(0xFF161F33);
  static const Color darkBorder = Color(0xFF26324D);

  // Light Theme Palette (Clean Executive Aesthetic)
  static const Color lightBackground = Color(0xFFF4F6FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceAlt = Color(0xFFE8EEF8);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFD6DFEC);

  // Accent & Brand Colors
  static const Color champagne = Color(0xFFF5C57A);
  static const Color champagneGlow = Color(0xFFD4AF37);
  static const Color amber = Color(0xFFFF9F1C);
  static const Color amberDark = Color(0xFFE08200);

  // Status & Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color successBackground = Color(0x1F10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningBackground = Color(0x1FF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color errorBackground = Color(0x1FEF4444);
  static const Color info = Color(0xFF38BDF8);
  static const Color infoBackground = Color(0x1F38BDF8);

  // Text Colors (Dark)
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  // Text Colors (Light)
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textMutedLight = Color(0xFF94A3B8);

  // Gradients
  static const LinearGradient vaultHeroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A2640),
      Color(0xFF0D1424),
      Color(0xFF090D18),
    ],
  );

  static const LinearGradient champagneGoldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFD700),
      Color(0xFFF5C57A),
      Color(0xFFD4AF37),
    ],
  );

  static const LinearGradient activeWarrantyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF10B981),
      Color(0xFF059669),
    ],
  );

  static const LinearGradient expiringWarrantyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF59E0B),
      Color(0xFFD97706),
    ],
  );

  static const LinearGradient expiredWarrantyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFEF4444),
      Color(0xFFDC2626),
    ],
  );
}
