import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexavault/firebase_options.dart';
import 'package:nexavault/ui/screens/dashboard_screen.dart';

/// NexaVault — Agentic Digital Asset Allocation
/// Google Solution Challenge 2026
///
/// Architecture: Detect → Reason → Act
///
///  ┌─────────────────────────────────────────────────────────┐
///  │ DETECT   FilePicker captures file bytes + name          │
///  │ REASON   AgenticAllocatorService → Gemini / Mock        │
///  │ ACT      Riverpod state update → UI re-renders         │
///  └─────────────────────────────────────────────────────────┘
void main() async {
  // Ensure Flutter binding is initialized before any async work
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Load environment variables from .env before constructing any providers.
  // This is safe — if the file is missing, the mock service is used anyway.
  await dotenv.load(fileName: '.env');

  runApp(
    // ProviderScope must wrap the entire app for Riverpod to function globally
    const ProviderScope(
      child: NexaVaultApp(),
    ),
  );
}

class NexaVaultApp extends StatelessWidget {
  const NexaVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NexaVault Allocator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF080B14),
        fontFamily: 'Roboto',
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF10B981),
          secondary: Color(0xFF3B82F6),
          surface: Color(0xFF111827),
        ),
        cardColor: const Color(0xFF0D1525),
        dividerColor: const Color(0x12FFFFFF),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF1E293B),
          contentTextStyle: TextStyle(color: Colors.white),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}
