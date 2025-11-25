// import 'package:flutter/material.dart';

// // AppSizes class to hold size constants for the Draze app
// class AppSizes {
//   // Padding and margins
//   static double smallPadding(BuildContext context) =>
//       MediaQuery.of(context).size.width * 0.02; // 2% of screen width
//   static double mediumPadding(BuildContext context) =>
//       MediaQuery.of(context).size.width * 0.04; // 4% of screen width
//   static double largePadding(BuildContext context) =>
//       MediaQuery.of(context).size.width * 0.06; // 6% of screen width

//   // Font sizes
//   static double smallText(BuildContext context) =>
//       MediaQuery.of(context).size.height * 0.018; // 1.8% of screen height
//   static double mediumText(BuildContext context) =>
//       MediaQuery.of(context).size.height * 0.022; // 2.2% of screen height
//   static double largeText(BuildContext context) =>
//       MediaQuery.of(context).size.height * 0.028; // 2.8% of screen height
//   static double titleText(BuildContext context) =>
//       MediaQuery.of(context).size.height * 0.035; // 3.5% of screen height

//   // Icon sizes
//   static double smallIcon(BuildContext context) =>
//       MediaQuery.of(context).size.width * 0.06; // 6% of screen width
//   static double mediumIcon(BuildContext context) =>
//       MediaQuery.of(context).size.width * 0.08; // 8% of screen width
//   static double largeIcon(BuildContext context) =>
//       MediaQuery.of(context).size.width * 0.1; // 10% of screen width

//   // Button sizes
//   static double buttonHeight(BuildContext context) =>
//       MediaQuery.of(context).size.height * 0.06; // 6% of screen height
//   static double buttonWidth(BuildContext context) =>
//       MediaQuery.of(context).size.width * 0.4; // 40% of screen width

//   // Card and container sizes
//   static double cardCornerRadius(BuildContext context) =>
//       MediaQuery.of(context).size.width * 0.03; // 2% of screen width
//   static double cardElevation(BuildContext context) =>
//       MediaQuery.of(context).size.width * 0.02; // 1% of screen width
// }

import 'package:flutter/material.dart';
import 'dart:math';

class AppSizes {
  // Base padding values
  static double smallPadding(BuildContext context) =>
      MediaQuery.of(context).size.width * 0.015; // ~6px on 400px wide screen
  static double mediumPadding(BuildContext context) =>
      MediaQuery.of(context).size.width * 0.03; // ~12px
  static double largePadding(BuildContext context) =>
      MediaQuery.of(context).size.width * 0.05; // ~20px

  // Base icon sizes
  static double smallIcon(BuildContext context) =>
      MediaQuery.of(context).size.width * 0.05; // ~20px
  static double mediumIcon(BuildContext context) =>
      MediaQuery.of(context).size.width * 0.07; // ~28px
  static double largeIcon(BuildContext context) =>
      MediaQuery.of(context).size.width * 0.1; // ~40px

  // Text sizes with safeguards against negative values
  static double smallText(BuildContext context) {
    final baseSize =
        MediaQuery.of(context).size.height * 0.015; // ~12px on 800px height
    final textScale = MediaQuery.of(context).textScaleFactor;
    return max(
      10.0,
      baseSize * textScale,
    ).clamp(10.0, 14.0); // Ensure 10px <= size <= 14px
  }

  static double mediumText(BuildContext context) {
    final baseSize = MediaQuery.of(context).size.height * 0.02; // ~16px
    final textScale = MediaQuery.of(context).textScaleFactor;
    return max(
      12.0,
      baseSize * textScale,
    ).clamp(12.0, 18.0); // Ensure 12px <= size <= 18px
  }

  static double largeText(BuildContext context) {
    final baseSize = MediaQuery.of(context).size.height * 0.025; // ~20px
    final textScale = MediaQuery.of(context).textScaleFactor;
    return max(
      16.0,
      baseSize * textScale,
    ).clamp(16.0, 24.0); // Ensure 16px <= size <= 24px
  }

  static double titleText(BuildContext context) {
    final baseSize = MediaQuery.of(context).size.height * 0.035; // ~28px
    final textScale = MediaQuery.of(context).textScaleFactor;
    return max(
      20.0,
      baseSize * textScale,
    ).clamp(20.0, 32.0); // Ensure 20px <= size <= 32px
  }

  // Button sizes
  static double buttonHeight(BuildContext context) =>
      MediaQuery.of(context).size.height * 0.06; // ~48px
  static double buttonWidth(BuildContext context) =>
      MediaQuery.of(context).size.width * 0.4; // ~160px

  // Card properties
  static double cardCornerRadius(BuildContext context) =>
      MediaQuery.of(context).size.width * 0.02; // ~8px
  static double cardElevation(BuildContext context) =>
      MediaQuery.of(context).size.width * 0.01; // ~4px
}
