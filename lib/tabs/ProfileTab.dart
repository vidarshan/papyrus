import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:papyrus/authentication/Login.dart';
import 'package:papyrus/providers/theme_controller.dart';
import 'package:papyrus/ui/ui.dart';
import 'package:provider/provider.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _deleting = false;
  String? _error;

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        PapyrusPageRoute(
          settings: const RouteSettings(name: '/login'),
          builder: (_) => const LoginScreen(),
        ),
        (route) => false,
      );
    }
  }

  void _confirmDeleteAccount(BuildContext context) {
    showPapyrusDialog(
      context,
      title: 'Delete your account?',
      message:
          'This permanently deletes every PDF, conversation, and your '
          "profile. This can't be undone.",
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
      destructive: true,
      onConfirm: _deleteAccount,
    );
  }

  /// Deletes every PDF (messages subcollection, doc, and Storage object),
  /// the user's profile doc, then the Firebase Auth account itself. Firebase
  /// requires a recent sign-in to delete an account; if the session is
  /// older than that, this surfaces a clear message instead of a raw
  /// exception rather than attempting a full re-authentication flow.
  Future<void> _deleteAccount() async {
    setState(() {
      _deleting = true;
      _error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);

      final pdfs = await userRef.collection('pdfs').get();
      for (final pdfDoc in pdfs.docs) {
        final messages = await pdfDoc.reference.collection('messages').get();
        final batch = FirebaseFirestore.instance.batch();
        for (final message in messages.docs) {
          batch.delete(message.reference);
        }
        batch.delete(pdfDoc.reference);
        await batch.commit();

        final storagePath = pdfDoc.data()['storagePath'] as String?;
        if (storagePath != null) {
          try {
            await FirebaseStorage.instance.ref(storagePath).delete();
          } catch (_) {
            // Best-effort cleanup: the Firestore doc that drives every
            // PDF list in the app is already gone, so a failure here is a
            // silent cleanup miss rather than a user-facing error.
          }
        }
      }

      await userRef.delete();
      await user.delete();

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          PapyrusPageRoute(
            settings: const RouteSettings(name: '/login'),
            builder: (_) => const LoginScreen(),
          ),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _deleting = false;
        _error = e.code == 'requires-recent-login'
            ? 'For your security, please log out and log back in, then '
                  'try deleting your account again.'
            : 'Could not delete your account: ${e.message}';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _deleting = false;
        _error = 'Could not delete your account.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = PapyrusTheme.of(context);
    final user = FirebaseAuth.instance.currentUser;
    final themeController = context.watch<ThemeController>();

    return PapyrusScaffold(
      title: 'Profile',
      padHorizontal: true,
      body: ListView(
        children: [
          const SizedBox(height: PSpacing.lg),
          if (user?.email != null)
            PapyrusText(
              user!.email!,
              variant: PTextVariant.body,
              color: theme.textSecondary,
              align: TextAlign.center,
            ),
          const SizedBox(height: PSpacing.xl),
          const PapyrusText('Appearance', variant: PTextVariant.subtitle),
          const SizedBox(height: PSpacing.sm),
          _ThemeModeSelector(controller: themeController),
          const SizedBox(height: PSpacing.xl),
          if (_error != null) ...[
            PapyrusAlert(message: _error!),
            const SizedBox(height: PSpacing.md),
          ],
          PapyrusButton(
            label: 'Log Out',
            variant: PButtonVariant.subtle,
            color: theme.error,
            onPressed: () => _logout(context),
          ),
          const SizedBox(height: PSpacing.sm),
          PapyrusButton(
            label: 'Delete Account',
            variant: PButtonVariant.light,
            color: theme.error,
            loading: _deleting,
            onPressed: _deleting
                ? null
                : () => _confirmDeleteAccount(context),
          ),
        ],
      ),
    );
  }
}

class _ThemeModeSelector extends StatelessWidget {
  const _ThemeModeSelector({required this.controller});

  final ThemeController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final mode in PapyrusThemeMode.values) ...[
          if (mode != PapyrusThemeMode.values.first)
            const SizedBox(width: PSpacing.xs),
          Expanded(
            child: PapyrusButton(
              label: switch (mode) {
                PapyrusThemeMode.light => 'Light',
                PapyrusThemeMode.dark => 'Dark',
                PapyrusThemeMode.system => 'System',
              },
              size: PButtonSize.sm,
              variant: controller.mode == mode
                  ? PButtonVariant.filled
                  : PButtonVariant.light,
              onPressed: () => controller.setMode(mode),
            ),
          ),
        ],
      ],
    );
  }
}
