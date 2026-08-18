import 'package:flutter/material.dart';

import 'responsive_hero_image.dart';

/// Rounded banner image shown at the top of a screen for visual flavor.
///
/// Thin wrapper around [ResponsiveHeroImage] so every existing call site
/// gets responsive sizing, bottom-gradient blending, and a graceful
/// fallback without having to change its call sites.
class ScreenHeaderImage extends StatelessWidget {
  const ScreenHeaderImage({super.key, required this.asset, this.height = 150});

  final String asset;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ResponsiveHeroImage(
      imagePath: asset,
      mobileHeight: height,
      tabletHeight: height + 60,
      desktopHeight: height + 140,
    );
  }
}
