import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF1E3A8A);
  static const secondary = Color(0xFF14B8A6);
  static const accent = Color(0xFFF59E0B);
  static const background = Color(0xFFF9FAFB);
  static const card = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const success = Color(0xFF10B981);
  static const error = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);
  static const primaryLight = Color(0xFF3B5FBF);
  static const secondaryLight = Color(0xFF5EEAD4);
  static const divider = Color(0xFFE5E7EB);
  static const inputFill = Color(0xFFF3F4F6);

  static const primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const cardGradient = LinearGradient(
    colors: [Color(0xFF1E3A8A), Color(0xFF14B8A6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const goldGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
