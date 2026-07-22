import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:papyrus/ui/ui.dart';
import 'package:pdfx/pdfx.dart';

/// Renders the actual pages of a PDF that's already in Firebase Storage at
/// `users/{uid}/pdfs/{pdfId}.pdf`, so a conversation isn't the only way to
/// see what's in the document. Pass [initialPage] to jump straight to a
/// page a Gemini reply cited, and [citedQuote] to surface the exact
/// sentence it cited - pdfx only rasterizes pages with no text layer, so
/// there's nothing to highlight on the page itself; a banner is the
/// closest equivalent to "show me exactly what was cited" available here.
class PdfViewerScreen extends StatefulWidget {
  const PdfViewerScreen({
    super.key,
    required this.pdfId,
    required this.fileName,
    this.initialPage = 1,
    this.citedQuote,
  });

  final String pdfId;
  final String fileName;
  final int initialPage;
  final String? citedQuote;

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  late final PdfControllerPinch _controller;
  late String? _bannerQuote;

  @override
  void initState() {
    super.initState();
    _bannerQuote = widget.citedQuote;
    _controller = PdfControllerPinch(
      document: PdfDocument.openData(_fetchBytes()),
      initialPage: widget.initialPage,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<Uint8List> _fetchBytes() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final bytes = await FirebaseStorage.instance
        .ref('users/$uid/pdfs/${widget.pdfId}.pdf')
        .getData(50 * 1024 * 1024);
    if (bytes == null) {
      throw StateError('Could not download ${widget.fileName}.');
    }
    return bytes;
  }

  @override
  Widget build(BuildContext context) {
    final theme = PapyrusTheme.of(context);

    return PapyrusScaffold(
      title: widget.fileName,
      leading: PapyrusIconButton(
        icon: const Icon(CupertinoIcons.back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        ValueListenableBuilder<int>(
          valueListenable: _controller.pageListenable,
          builder: (context, page, _) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: PSpacing.sm),
            child: Center(
              child: PapyrusText(
                'Page $page',
                variant: PTextVariant.caption,
                color: theme.textSecondary,
              ),
            ),
          ),
        ),
      ],
      body: Stack(
        children: [
          PdfViewPinch(
            controller: _controller,
            builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
              options: const DefaultBuilderOptions(),
              documentLoaderBuilder: (_) =>
                  const Center(child: PapyrusLoader(size: 28)),
              pageLoaderBuilder: (_) =>
                  const Center(child: PapyrusLoader(size: 20)),
              errorBuilder: (_, _) => Center(
                child: PapyrusAlert(
                  message: 'Could not load ${widget.fileName}.',
                ),
              ),
            ),
          ),
          if (_bannerQuote != null)
            Positioned(
              top: PSpacing.md,
              left: PSpacing.md,
              right: PSpacing.md,
              child: _CitationBanner(
                quote: _bannerQuote!,
                onDismiss: () => setState(() => _bannerQuote = null),
              ),
            ),
        ],
      ),
    );
  }
}

class _CitationBanner extends StatelessWidget {
  const _CitationBanner({required this.quote, required this.onDismiss});

  final String quote;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = PapyrusTheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PSpacing.sm,
        vertical: PSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: PColors.primary[0],
        borderRadius: BorderRadius.circular(PRadius.md),
        border: Border(left: BorderSide(color: theme.primary, width: 3)),
        boxShadow: [
          BoxShadow(
            color: PColors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: PapyrusText(
              '“$quote”',
              variant: PTextVariant.body,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(width: PSpacing.xs),
          PapyrusIconButton(
            icon: const Icon(CupertinoIcons.xmark),
            size: 28,
            onPressed: onDismiss,
          ),
        ],
      ),
    );
  }
}
