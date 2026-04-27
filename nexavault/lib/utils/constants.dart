import 'package:flutter/material.dart';

// ──────────────────────────────────────────────────────────────────────
//  AppConstants — NexaVault Allocator Design System
//  Dark gradient theme matching the AllocatAI web interface
// ──────────────────────────────────────────────────────────────────────
class AppConstants {
  static const List<String> missionBucketCategories = [
    'Surplus Assets',
    'Critical Needs',
    'Logistics & Routing',
    'Miscellaneous',
    'Agent Requires Review',
  ];

  // Brand colors
  static const Color bgDark        = Color(0xFF080B14);
  static const Color bgSurface      = Color(0xFF111827);
  static const Color bgCard         = Color(0xFF0D1525);
  static const Color primary        = Color(0xFF10B981); // Emerald green
  static const Color primaryDark    = Color(0xFF059669);
  static const Color blue           = Color(0xFF3B82F6);
  static const Color textMain       = Color(0xFFF1F5F9);
  static const Color textMuted      = Color(0xFF64748B);
  static const Color borderColor    = Color(0x12FFFFFF);
  static const Color borderGlow     = Color(0x6610B981);

  // Gradient shortcuts
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, blue],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0A0F1E), Color(0xFF0A1628)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Bucket colors
  static Color bucketColor(String category) {
    switch (category) {
      case 'Surplus Assets':    return const Color(0xFF10B981);
      case 'Critical Needs':    return const Color(0xFFEF4444);
      case 'Logistics & Routing': return const Color(0xFF3B82F6);
      case 'Agent Requires Review': return const Color(0xFFF59E0B);
      default:                  return const Color(0xFF64748B);
    }
  }

  static IconData bucketIcon(String category) {
    switch (category) {
      case 'Surplus Assets':    return Icons.inventory_2_outlined;
      case 'Critical Needs':    return Icons.local_hospital_outlined;
      case 'Logistics & Routing': return Icons.local_shipping_outlined;
      case 'Agent Requires Review': return Icons.rate_review_outlined;
      default:                  return Icons.folder_outlined;
    }
  }

  // Deprecated - keep for compatibility
  static const Color primaryBrandColor = primary;
  static const Color backgroundLight   = bgDark;
}
