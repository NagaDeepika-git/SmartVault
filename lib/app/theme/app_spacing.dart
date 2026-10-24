import 'package:flutter/material.dart';

/// Spacing, radius, and elevation tokens for consistent layout geometry.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double hero = 48.0;

  // Insets
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0);
  static const EdgeInsets pagePaddingWide = EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  static const EdgeInsets dialogPadding = EdgeInsets.all(24.0);
}

/// Border radius tokens for modern rounded geometry.
class AppRadius {
  AppRadius._();

  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double full = 999.0;

  static const BorderRadius radiusSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius radiusMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius radiusLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius radiusXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius radiusFull = BorderRadius.all(Radius.circular(full));
}

/// Elevation and subtle lighting shadow tokens.
class AppShadows {
  AppShadows._();

  static List<BoxShadow> get subtleDark => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.35),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get vaultGlow => [
    BoxShadow(
      color: const Color(0xFFF5C57A).withValues(alpha: 0.18),
      blurRadius: 24,
      spreadRadius: 2,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get cardElevation => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.2),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
}
