import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dropweek/supabase_client.dart';
import 'package:dropweek/screens/dashboard_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<ShadFormState>();
  bool _isLogin = false;
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loading = true);

    try {
      final client = SupabaseClientManager.client;

      if (_isLogin) {
        await client.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        await client.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          data: {'display_name': _nameController.text.trim()},
        );
      }

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ShadToaster.of(context).show(
        ShadToast.destructive(
          title: Text(e.message),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ShadToaster.of(context).show(
        ShadToast.destructive(
          title: Text(e.toString()),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ShadForm(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.checklist_rounded,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'DropWeek',
                    style: theme.textTheme.h3,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isLogin
                        ? 'Melde dich mit deinem Konto an'
                        : 'Erstelle ein neues Konto',
                    style: theme.textTheme.p,
                  ),
                  const SizedBox(height: 32),
                  if (!_isLogin)
                    ShadInputFormField(
                      controller: _nameController,
                      placeholder: const Text('Name'),
                      leading: const Icon(Icons.person_outline),
                      validator: (v) {
                        if (!_isLogin && v.trim().isEmpty) {
                          return 'Bitte gib deinen Namen ein';
                        }
                        return null;
                      },
                    ),
                  if (!_isLogin) const SizedBox(height: 16),
                  ShadInputFormField(
                    controller: _emailController,
                    placeholder: const Text('Email'),
                    leading: const Icon(Icons.email_outlined),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v.trim().isEmpty) {
                        return 'Bitte gib deine Email ein';
                      }
                      if (!v.contains('@')) {
                        return 'Ungültige Email-Adresse';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ShadInputFormField(
                    controller: _passwordController,
                    placeholder: const Text('Passwort'),
                    leading: const Icon(Icons.lock_outline),
                    obscureText: true,
                    validator: (v) {
                      if (v.length < 6) {
                        return 'Passwort muss mindestens 6 Zeichen lang sein';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ShadButton(
                    width: double.infinity,
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(_isLogin ? 'Anmelden' : 'Registrieren'),
                  ),
                  const SizedBox(height: 16),
                  ShadButton.ghost(
                    onPressed: () {
                      setState(() => _isLogin = !_isLogin);
                    },
                    child: Text(
                      _isLogin
                          ? 'Noch kein Konto? Registrieren'
                          : 'Bereits ein Konto? Anmelden',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
