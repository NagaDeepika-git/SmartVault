import 'package:flutter/material.dart';

/// Screen breakpoint classifications.
enum ScreenType {
  mobile,
  tablet,
  desktop,
}

/// Helper methods for determining screen size and applying responsive design patterns.
/// Fulfills Flutter syllabus responsive requirements using MediaQuery and LayoutBuilder.
class ResponsiveHelper {
  ResponsiveHelper._();

  static const double mobileBreakpoint = 768.0;
  static const double tabletBreakpoint = 1024.0;
  static const double maxContentWidth = 1200.0;

  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return ScreenType.mobile;
    if (width < tabletBreakpoint) return ScreenType.tablet;
    return ScreenType.desktop;
  }

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint;

  static bool isWide(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint;
}

/// Adaptive layout builder widget that renders different layouts for mobile, tablet, and desktop.
class ResponsiveLayout extends StatelessWidget {
  final Widget Function(BuildContext context) mobile;
  final Widget Function(BuildContext context)? tablet;
  final Widget Function(BuildContext context)? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= ResponsiveHelper.tabletBreakpoint && desktop != null) {
          return desktop!(context);
        } else if (constraints.maxWidth >= ResponsiveHelper.mobileBreakpoint && tablet != null) {
          return tablet!(context);
        } else {
          return mobile(context);
        }
      },
    );
  }
}
