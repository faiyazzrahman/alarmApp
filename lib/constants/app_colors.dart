import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
  static const primaryBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0B0024), // top
      Color(0xFF082257), // bottom
    ],
  );

  static const Color primaryAccent = Color(0xFF5200FF); // Buttons / CTA
  static const Color secondaryAccent = Color(0xFF9C8CFF);

  // =========================
  // TEXT COLORS
  // =========================

  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color textMuted = Colors.white60;

  // =========================
  // BUTTON COLORS
  // =========================

  static const Color buttonPrimary = primaryAccent;
  static const Color buttonText = Colors.white;

  // =========================
  // CARD / CONTAINER COLORS
  // =========================

  static const Color cardDark = Color(0xFF12182F);
  static const Color cardLight = Color(0xFF1C2440);

  // =========================
  // STATUS COLORS
  // =========================

  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);

  // =========================
  // DIVIDER
  // =========================

  static const Color divider = Color(0x33FFFFFF); // 20% white
}
