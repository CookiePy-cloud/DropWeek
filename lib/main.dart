import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dropweek/supabase_client.dart';
import 'package:dropweek/screens/onboarding_screen.dart';
import 'package:dropweek/screens/login_screen.dart';
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

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  final _storage = const FlutterSecureStorage();
  bool? _onboardingDone;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final done = await _storage.read(key: 'onboarding_done');
    if (!mounted) return;
    setState(() => _onboardingDone = done == 'true');
  }

  @override
  Widget build(BuildContext context) {
    if (_onboardingDone == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_onboardingDone!) {
      return const OnboardingScreen();
    }

    final session = SupabaseClientManager.client.auth.currentSession;
    return session != null ? const DashboardScreen() : const LoginScreen();
  }
}
