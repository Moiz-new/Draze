import 'package:flutter/material.dart';

// AppColors class to hold color constants for the Draze app
class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF5c4eff); // Blue for main theme
  static const Color secondary = Color(0xFFF0F8FF); // Orange for accents
  static const Color background = Color(
    0xFFF5F5F5,
  ); // Light grey for background
  static const Color surface = Colors.white; // White for cards and surfaces

  // Text colors
  static const Color textPrimary = Color(
    0xFF212121,
  ); // Dark grey for primary text
  static const Color textSecondary = Color(
    0xFF757575,
  ); // Lighter grey for secondary text

  // Status colors
  static const Color success = Color(0xFF4CAF50); // Green for success states
  static const Color error = Color(0xFFE53935); // Red for error states
  static const Color warning = Color(0xFFFFCA28); // Yellow for warnings

  // Other utility colors
  static const Color divider = Color(0xFFB0BEC5); // Light grey for dividers
  static const Color disabled = Color(0xFFB0BEC5); // Grey for disabled elements
}
