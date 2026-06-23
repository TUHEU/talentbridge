// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand ─────────────────────────────────────────────────
  static const Color primary      = Color(0xFF1FA2FF);
  static const Color primaryDark  = Color(0xFF0D7DD9);
  static const Color primaryLight = Color(0xFFE8F4FF);
  static const Color secondary    = Color(0xFF12D8FA);
  static const Color accent       = Color(0xFF1FD1A5);
  static const Color accentAmber  = Color(0xFFFFB300);

  // ── Gradients ─────────────────────────────────────────────
  static const LinearGradient brandGradient = LinearGradient(
    colors: [primary, secondary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient brandVertical = LinearGradient(
    colors: [primary, Color(0xFF0A8FE8), accent],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static const LinearGradient cardGradientBlue = LinearGradient(
    colors: [Color(0xFF1FA2FF), Color(0xFF0A8FE8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient cardGradientPurple = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF9C94FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient cardGradientOrange = LinearGradient(
    colors: [Color(0xFFFF7043), Color(0xFFFF9468)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient cardGradientTeal = LinearGradient(
    colors: [Color(0xFF1FD1A5), Color(0xFF4DB6AC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient cardGradientAmber = LinearGradient(
    colors: [Color(0xFFFFB300), Color(0xFFFFCC02)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient cardGradientRed = LinearGradient(
    colors: [Color(0xFFE53935), Color(0xFFEF5350)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Feature colours ───────────────────────────────────────
  static const Color aiAdvisor   = Color(0xFF6C63FF);
  static const Color jobs        = Color(0xFFFF7043);
  static const Color community   = Color(0xFF1FD1A5);
  static const Color messages    = Color(0xFF8E24AA);
  static const Color startup     = Color(0xFFFFB300);
  static const Color connections = Color(0xFF00ACC1);
  static const Color profile     = Color(0xFF43A047);

  // ── Semantic ──────────────────────────────────────────────
  static const Color success = Color(0xFF16A34A);
  static const Color error   = Color(0xFFDC2626);
  static const Color warning = Color(0xFFD97706);
  static const Color info    = Color(0xFF0284C7);

  // ── Light neutrals ────────────────────────────────────────
  static const Color white   = Colors.white;
  static const Color bg      = Color(0xFFF0F4F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color grey50  = Color(0xFFF8FAFC);
  static const Color grey100 = Color(0xFFF1F5F9);
  static const Color grey200 = Color(0xFFE2E8F0);
  static const Color grey300 = Color(0xFFCBD5E1);
  static const Color grey400 = Color(0xFF94A3B8);
  static const Color grey500 = Color(0xFF64748B);
  static const Color grey600 = Color(0xFF475569);
  static const Color grey700 = Color(0xFF334155);
  static const Color grey800 = Color(0xFF1E293B);
  static const Color grey900 = Color(0xFF0F172A);

  // ── Dark theme ────────────────────────────────────────────
  static const Color darkBg      = Color(0xFF080C14);
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkCard    = Color(0xFF1A2235);
  static const Color darkCard2   = Color(0xFF1F2D45);
  static const Color darkBorder  = Color(0xFF253048);
  static const Color darkText    = Color(0xFFE2E8F0);
  static const Color darkTextSub = Color(0xFF94A3B8);

  // ── Backward-compatible aliases ───────────────────────────
  /// Same as [darkBg]. Use [darkBg] in new code.
  static const Color darkBackground = darkBg;
}
