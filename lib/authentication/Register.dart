import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:papyrus/navigation/MainTabScreen.dart';
import 'package:papyrus/ui/ui.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  String? _nameError;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validate() {
    String? nameErr;
    String? emailErr;
    String? passErr;

    if (_nameController.text.trim().isEmpty) {
      nameErr = 'Please enter your name';
    }

    final email = _emailController.text.trim();
    if (email.isEmpty) {
      emailErr = 'Please enter your email';
    } else if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      emailErr = 'Please enter a valid email';
    }

    if (_passwordController.text.isEmpty) {
      passErr = 'Please enter your password';
    } else if (_passwordController.text.length < 6) {
      passErr = 'Password must be at least 6 characters';
    }

    setState(() {
      _nameError = nameErr;
      _emailError = emailErr;
      _passwordError = passErr;
    });

    return nameErr == null && emailErr == null && passErr == null;
  }

  void _showError(String message) {
    showPapyrusDialog(context, title: 'Registration Failed', message: message);
  }

  void _submit() async {
    if (!_validate()) return;

    setState(() => _isLoading = true);
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final uid = credential.user!.uid;
      await credential.user?.updateDisplayName(_nameController.text.trim());

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': _nameController.text.trim(),
        'username': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
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
        case 'email-already-in-use':
          message = 'An account already exists with this email';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address';
          break;
        case 'weak-password':
          message = 'Password must be at least 6 characters';
          break;
        default:
          message = 'An error occurred. Please try again';
      }
      if (mounted) _showError(message);
    } catch (e) {
      if (mounted) _showError('Something went wrong: ${e.toString()}');
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
              const PapyrusText('Create an account', variant: PTextVariant.subtitle),
              const SizedBox(height: 24),
              PapyrusTextInput(
                controller: _nameController,
                label: 'Name',
                placeholder: 'Your name',
                textInputAction: TextInputAction.next,
                errorText: _nameError,
                leading: const Icon(CupertinoIcons.person, size: 18),
              ),
              const SizedBox(height: 16),
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
                placeholder: 'At least 6 characters',
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
              const SizedBox(height: 24),
              PapyrusButton(
                label: 'Sign Up',
                fullWidth: true,
                loading: _isLoading,
                onPressed: _isLoading ? null : _submit,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const PapyrusText('Already have an account?', variant: PTextVariant.caption),
                  PapyrusButton(
                    label: 'Log In',
                    variant: PButtonVariant.subtle,
                    size: PButtonSize.xs,
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
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
