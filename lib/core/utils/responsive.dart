import 'package:flutter/material.dart';

/// App-wide responsive breakpoints.
///
/// mobile: < 600px, tablet: 600-1024px, desktop: > 1024px.
enum ScreenSize { mobile, tablet, desktop }

class Responsive {
  Responsive._();

  static const double mobileMax = 600;
  static const double tabletMax = 1024;

  static ScreenSize of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < mobileMax) return ScreenSize.mobile;
    if (width < tabletMax) return ScreenSize.tablet;
    return ScreenSize.desktop;
  }

  static bool isMobile(BuildContext context) =>
      of(context) == ScreenSize.mobile;
  static bool isTablet(BuildContext context) =>
      of(context) == ScreenSize.tablet;
  static bool isDesktop(BuildContext context) =>
      of(context) == ScreenSize.desktop;
}
