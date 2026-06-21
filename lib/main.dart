import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:dropweek/supabase_client.dart';
import 'package:dropweek/screens/onboarding_screen.dart';
import 'package:dropweek/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseClientManager.initialize();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp(
      title: 'DropWeek',
      debugShowCheckedModeBanner: false,
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final session = SupabaseClientManager.client.auth.currentSession;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: session != null
          ? const DashboardScreen()
          : const OnboardingScreen(),
    );
  }
}
