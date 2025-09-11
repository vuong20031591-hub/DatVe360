import 'package:flutter/material.dart';

/// App color constants following the design system
class AppColors {
  AppColors._();

  // Light theme colors
  static const Color lightPrimary = Color(0xFF6366F1);
  static const Color lightText = Color(0xFF0F172A);
  static const Color lightBackground = Color(0xFFF9FAFB);
  static const Color lightAccent = Color(0xFFF59E0B);
  static const Color lightSuccess = Color(0xFF22C55E);
  static const Color lightError = Color(0xFFEF4444);
  static const Color lightWarning = Color(0xFFF59E0B);
  static const Color lightInfo = Color(0xFF3B82F6);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightOnSurface = Color(0xFF0F172A);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightSecondary = Color(0xFF64748B);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);

  // Dark theme colors
  static const Color darkPrimary = Color(0xFF818CF8);
  static const Color darkText = Color(0xFFF9FAFB);
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkAccent = Color(0xFFFBBF24);
  static const Color darkSuccess = Color(0xFF4ADE80);
  static const Color darkError = Color(0xFFF87171);
  static const Color darkWarning = Color(0xFFFBBF24);
  static const Color darkInfo = Color(0xFF60A5FA);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkOnSurface = Color(0xFFF9FAFB);
  static const Color darkOnPrimary = Color(0xFF0F172A);
  static const Color darkSecondary = Color(0xFF94A3B8);
  static const Color darkOnSecondary = Color(0xFF0F172A);

  // Neutral colors
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  // Transport mode colors
  static const Color flightColor = Color(0xFF3B82F6);
  static const Color trainColor = Color(0xFF10B981);
  static const Color busColor = Color(0xFFF59E0B);
  static const Color ferryColor = Color(0xFF8B5CF6);

  // Status colors
  static const Color availableColor = Color(0xFF22C55E);
  static const Color bookedColor = Color(0xFFEF4444);
  static const Color selectedColor = Color(0xFF6366F1);
  static const Color heldColor = Color(0xFFF59E0B);
}
