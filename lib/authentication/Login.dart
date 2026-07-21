import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:papyrus/navigation/MainTabScreen.dart';
import 'package:papyrus/ui/ui.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validate() {
    String? emailErr;
    String? passErr;

    final email = _emailController.text.trim();
    if (email.isEmpty) {
      emailErr = 'Please enter your email';
    } else if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      emailErr = 'Please enter a valid email';
    }

    final password = _passwordController.text;
    if (password.isEmpty) {
      passErr = 'Please enter your password';
    } else if (password.length < 6) {
      passErr = 'Password must be at least 6 characters';
    }

    setState(() {
      _emailError = emailErr;
      _passwordError = passErr;
    });

    return emailErr == null && passErr == null;
  }

  void _submit() async {
    if (!_validate()) return;

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          PapyrusPageRoute(
            settings: const RouteSettings(name: '/home'),
            builder: (_) => const MainTabScreen(),
          ),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email';
          break;
        case 'wrong-password':
          message = 'Incorrect password';
          break;
        case 'invalid-credential':
          message = 'Incorrect email or password';
          break;
        default:
          message = e.message ?? 'An error occurred';
      }
      if (mounted) {
        showPapyrusDialog(context, title: 'Sign In Failed', message: message);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = PapyrusTheme.of(context);
    return PapyrusScaffold(
      padHorizontal: true,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PapyrusText('Papyrus', variant: PTextVariant.title, color: theme.primary),
              const SizedBox(height: 8),
              const PapyrusText('Log in to your account', variant: PTextVariant.subtitle),
              const SizedBox(height: 24),
              PapyrusTextInput(
                controller: _emailController,
                label: 'Email',
                placeholder: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                errorText: _emailError,
                leading: const Icon(CupertinoIcons.mail, size: 18),
              ),
              const SizedBox(height: 16),
              PapyrusTextInput(
                controller: _passwordController,
                label: 'Password',
                placeholder: 'Your password',
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                errorText: _passwordError,
                onSubmitted: (_) => _submit(),
                leading: const Icon(CupertinoIcons.lock, size: 18),
                trailing: PapyrusIconButton(
                  size: 28,
                  icon: Icon(
                    _obscurePassword ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                    size: 16,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: PapyrusButton(
                  label: 'Forgot Password?',
                  variant: PButtonVariant.subtle,
                  size: PButtonSize.xs,
                  onPressed: () {},
                ),
              ),
              const SizedBox(height: 16),
              PapyrusButton(
                label: 'Login',
                fullWidth: true,
                loading: _isLoading,
                onPressed: _isLoading ? null : _submit,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const PapyrusText("Don't have an account?", variant: PTextVariant.caption),
                  PapyrusButton(
                    label: 'Sign Up',
                    variant: PButtonVariant.subtle,
                    size: PButtonSize.xs,
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/signup');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
