import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    if (!kDebugMode) {
      _loadSavedCredentials();
    }
  }

  Future<void> _loadSavedCredentials() async {
    final storage = ref.read(secureStorageProvider);
    final rememberMe = await storage.get('remember_me');

    if (rememberMe == 'true') {
      final email = await storage.get('email');
      final password = await storage.get('password');
      if (mounted) {
        setState(() {
          _rememberMe = true;
          if (email != null) _emailController.text = email;
          if (password != null) _passwordController.text = password;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (kDebugMode) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final storage = ref.read(secureStorageProvider);

      if (_isLogin) {
        await authRepo.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        await authRepo.createUserWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      }

      if (_rememberMe) {
        await storage.put('remember_me', 'true');
        await storage.put('email', _emailController.text.trim());
        await storage.put('password', _passwordController.text.trim());
      } else {
        await storage.delete('remember_me');
        await storage.delete('email');
        await storage.delete('password');
      }

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    if (kDebugMode) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.signInWithGoogle();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            kDebugMode ? 'Debug Access' : (_isLogin ? 'Sign In' : 'Sign Up')),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 100,
                  height: 100,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Plain-English legal help for everyday people.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  kDebugMode
                      ? 'Debug mode is active. Login, auth, and ads are intentionally off so we can finish the app flow first.'
                      : 'Use guest mode to try the app now, then create an account later for saved history and premium features.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 24),
                if (!kDebugMode) ...[
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          !value.contains('@')) {
                        return 'Please enter a valid email.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Password must be at least 6 characters long.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                    title: const Text('Remember me'),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
                const SizedBox(height: 24),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  Column(
                    children: [
                      if (!kDebugMode)
                        ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          child: Text(_isLogin ? 'Sign In' : 'Sign Up'),
                        ),
                      if (!kDebugMode) const SizedBox(height: 12),
                      if (!kDebugMode)
                        OutlinedButton(
                          onPressed: _signInWithGoogle,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          child: const Text('Sign in with Google'),
                        ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed('/home');
                        },
                        icon: const Icon(Icons.arrow_forward),
                        label: Text(kDebugMode
                            ? 'Continue in Debug Mode'
                            : 'Continue as Guest'),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        kDebugMode
                            ? 'Auth and ads stay off in debug mode so we can perfect the app before wiring monetization and account flows.'
                            : 'Free plan includes ads. Upgrade later for more states, better source depth, saved history, and premium explainers.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                      if (!kDebugMode) const SizedBox(height: 16),
                      if (!kDebugMode)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isLogin = !_isLogin;
                            });
                          },
                          child: Text(_isLogin
                              ? 'Create an account'
                              : 'I already have an account'),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
