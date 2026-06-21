import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dropweek/screens/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  final _storage = const FlutterSecureStorage();
  int _currentPage = 0;

  final _pages = const [
    _OnboardingPage(
      icon: Icons.checklist_rounded,
      title: 'Welcome to DropWeek',
      description: 'Organize your week simply and efficiently. '
          'Create tasks, track your progress, and stay on top of things.',
    ),
    _OnboardingPage(
      icon: Icons.dashboard_customize_rounded,
      title: 'Manage Tasks',
      description: 'Add new tasks, edit them, '
          'and mark them as done. All in one place.',
    ),
    _OnboardingPage(
      icon: Icons.cloud_sync_rounded,
      title: 'Always Synced',
      description: 'Your tasks are automatically saved to the cloud '
          'and available on all your devices.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _nextPage() async {
    if (_currentPage < _pages.length - 1) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      await _storage.write(key: 'onboarding_done', value: 'true');
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  Future<void> _skip() async {
    await _storage.write(key: 'onboarding_done', value: 'true');
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 16, right: 16),
                child: ShadButton.ghost(
                  onPressed: _skip,
                  child: const Text('Skip'),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: _pages,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 48, left: 24, right: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == i ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? theme.colorScheme.primary
                              : theme.colorScheme.mutedForeground
                                  .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ShadButton(
                    width: double.infinity,
                    onPressed: _nextPage,
                    child: Text(
                      _currentPage < _pages.length - 1
                          ? 'Next'
                          : 'Let\'s go',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 96, color: theme.colorScheme.primary),
          const SizedBox(height: 32),
          Text(title, style: theme.textTheme.h3, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(
            description,
            style: theme.textTheme.p,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
