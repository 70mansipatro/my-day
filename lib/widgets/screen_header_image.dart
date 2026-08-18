import 'package:flutter/material.dart';

/// Rounded banner image shown at the top of a screen for visual flavor.
class ScreenHeaderImage extends StatelessWidget {
  const ScreenHeaderImage({super.key, required this.asset, this.height = 150});

  final String asset;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        asset,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}
