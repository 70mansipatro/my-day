import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../app/app_colors.dart';
import '../core/utils/responsive.dart';

/// Global responsive hero/banner image.
///
/// Picks a height by screen breakpoint (mobile/tablet/desktop), never
/// stretches or fills the source image, and blends its bottom edge into the
/// surrounding scaffold background with a gradient instead of ending in a
/// hard rectangle. Falls back to a peach placeholder if the asset fails to
/// load, and supports an optional [child] overlay (e.g. greeting text)
/// anchored over the gradient. Applies a small [topMargin] by default so the
/// image never sits flush against the top of a screen.
class ResponsiveHeroImage extends StatelessWidget {
  const ResponsiveHeroImage({
    super.key,
    required this.imagePath,
    this.borderRadius,
    this.mobileHeight = 150,
    this.tabletHeight = 220,
    this.desktopHeight = 320,
    this.alignment = Alignment.center,
    this.gradientEnabled = true,
    this.topMargin = 8,
    this.child,
    this.semanticLabel,
  });

  final String imagePath;
  final double? borderRadius;
  final double mobileHeight;
  final double tabletHeight;
  final double desktopHeight;
  final Alignment alignment;
  final bool gradientEnabled;
  final double topMargin;
  final Widget? child;
  final String? semanticLabel;

  double _heightFor(ScreenSize size) {
    switch (size) {
      case ScreenSize.mobile:
        return mobileHeight;
      case ScreenSize.tablet:
        return tabletHeight;
      case ScreenSize.desktop:
        return desktopHeight;
    }
  }

  double _radiusFor(ScreenSize size) {
    if (borderRadius != null) return borderRadius!;
    return size == ScreenSize.desktop ? 20 : 16;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = Responsive.of(context);
    final height = _heightFor(screenSize);
    final radius = _radiusFor(screenSize);
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cacheWidth = (MediaQuery.sizeOf(context).width * dpr).round();

    return Padding(
      padding: EdgeInsets.only(top: topMargin),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox(
          width: double.infinity,
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Semantics(
                label: semanticLabel,
                image: true,
                excludeSemantics: semanticLabel == null,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  alignment: alignment,
                  cacheWidth: cacheWidth > 0 ? cacheWidth : null,
                  filterQuality: ui.FilterQuality.medium,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.peach100,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.image_outlined,
                      color: AppColors.peach900,
                      size: 40,
                    ),
                  ),
                ),
              ),
              if (gradientEnabled)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: height * 0.45,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          scaffoldBg.withValues(alpha: 0),
                          scaffoldBg.withValues(alpha: 0.8),
                          scaffoldBg,
                        ],
                      ),
                    ),
                  ),
                ),
              if (child != null)
                Positioned(left: 0, right: 0, bottom: 0, child: child!),
            ],
          ),
        ),
      ),
    );
  }
}
