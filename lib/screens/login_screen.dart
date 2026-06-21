import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dropweek/supabase_client.dart';
import 'package:dropweek/screens/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<ShadFormState>();

  int _step = 0;
  bool _isRegister = false;
  bool _loading = false;

  static const _totalSteps = 2;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _nextStep() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return Future.value();
    }

    if (_step == 0) {
      setState(() => _step = 1);
      return Future.value();
    }

    return _submit();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loading = true);

    try {
      final client = SupabaseClientManager.client;

      if (_isRegister) {
        await client.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          data: {'display_name': _nameController.text.trim()},
        );
      } else {
        await client.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (_) => false,
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ShadToaster.of(context).show(
        ShadToast.destructive(title: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ShadToaster.of(context).show(
        ShadToast.destructive(title: Text(e.toString())),
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
                  Text('DropWeek', style: theme.textTheme.h3),
                  const SizedBox(height: 4),
                  Text(
                    _isRegister
                        ? 'Create a new account'
                        : 'Sign in with your account',
                    style: theme.textTheme.p,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _totalSteps,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _step == i ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _step >= i
                              ? theme.colorScheme.primary
                              : theme.colorScheme.mutedForeground
                                  .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  if (_step == 0) ...[
                    ShadInputFormField(
                      controller: _emailController,
                      placeholder: const Text('Email'),
                      leading: const Icon(Icons.email_outlined),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v.trim().isEmpty) return 'Please enter your email';
                        if (!v.contains('@')) return 'Invalid email address';
                        return null;
                      },
                    ),
                  ] else ...[
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _isRegister
                          ? Padding(
                              key: const ValueKey('name'),
                              padding: const EdgeInsets.only(bottom: 16),
                              child: ShadInputFormField(
                                controller: _nameController,
                                placeholder: const Text('Name'),
                                leading: const Icon(Icons.person_outline),
                                validator: (v) {
                                  if (_isRegister && v.trim().isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  return null;
                                },
                              ),
                            )
                          : const SizedBox.shrink(key: ValueKey('no_name')),
                    ),
                    ShadInputFormField(
                      controller: _passwordController,
                      placeholder: const Text('Password'),
                      leading: const Icon(Icons.lock_outline),
                      obscureText: true,
                      validator: (v) {
                        if (v.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                  ],

                  const SizedBox(height: 24),

                  ShadButton(
                    width: double.infinity,
                    onPressed: _loading ? null : _nextStep,
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(_step == 0 ? 'Next' : 'Complete'),
                  ),

                  if (_step == 1) ...[
                    const SizedBox(height: 16),
                    ShadButton.ghost(
                      onPressed: () {
                        setState(() => _isRegister = !_isRegister);
                      },
                      child: Text(
                        _isRegister
                            ? 'Already have an account? Sign in'
                            : 'Don\'t have an account? Register',
                      ),
                    ),
                    const SizedBox(height: 8),
                    ShadButton.ghost(
                      onPressed: () {
                        setState(() {
                          _step = 0;
                          _isRegister = false;
                        });
                      },
                      child: const Text('Back to email'),
                    ),
                  ] else ...[
                    const SizedBox(height: 16),
                    ShadButton.ghost(
                      onPressed: () {
                        setState(() => _isRegister = !_isRegister);
                      },
                      child: Text(
                        _isRegister
                            ? 'Already have an account? Sign in'
                            : 'Don\'t have an account? Register',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
