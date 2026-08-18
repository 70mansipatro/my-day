import 'package:flutter/material.dart';

/// Centralized MyDay brand palette (Peach) and neutral colors.
///
/// All screens/widgets should reference these constants instead of
/// hardcoding brand colors, so the theme stays consistent and easy to
/// retune from a single place.
class AppColors {
  AppColors._();

  // Peach — brand/primary palette.
  static const Color peach50 = Color(0xFFFFF6ED);
  static const Color peach100 = Color(0xFFFFEAD5);
  static const Color peach200 = Color(0xFFFFDDBF);
  static const Color peach300 = Color(0xFFFFCEA8);
  static const Color peach400 = Color(0xFFFFC291);
  static const Color peach500 = Color(0xFFFFD3AC);
  static const Color peach600 = Color(0xFFF6B988);
  static const Color peach700 = Color(0xFFE5A36D);
  static const Color peach800 = Color(0xFFD18A52);
  static const Color peach900 = Color(0xFFB76F3C);

  // Neutrals.
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF1F1F1);
  static const Color gray200 = Color(0xFFE5E5E5);
  static const Color gray300 = Color(0xFFD4D4D4);
  static const Color gray400 = Color(0xFFA3A3A3);
  static const Color gray600 = Color(0xFF525252);
  static const Color gray800 = Color(0xFF262626);
  static const Color black = Color(0xFF000000);

  // Dark theme surfaces.
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkPrimaryContainer = Color(0xFF6B4630);
  static const Color darkBorder = Color(0xFF3A3A3A);
  static const Color darkSecondaryText = Color(0xFFD4D4D4);
}
