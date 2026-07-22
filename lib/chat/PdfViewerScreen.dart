import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:papyrus/ui/ui.dart';
import 'package:pdfx/pdfx.dart';

/// Renders the actual pages of a PDF that's already in Firebase Storage at
/// `users/{uid}/pdfs/{pdfId}.pdf`, so a conversation isn't the only way to
/// see what's in the document. Pass [initialPage] to jump straight to a
/// page a Gemini reply cited.
class PdfViewerScreen extends StatefulWidget {
  const PdfViewerScreen({
    super.key,
    required this.pdfId,
    required this.fileName,
    this.initialPage = 1,
  });

  final String pdfId;
  final String fileName;
  final int initialPage;

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  late final PdfControllerPinch _controller;

  @override
  void initState() {
    super.initState();
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
      body: PdfViewPinch(
        controller: _controller,
        builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
          options: const DefaultBuilderOptions(),
          documentLoaderBuilder: (_) =>
              const Center(child: PapyrusLoader(size: 28)),
          pageLoaderBuilder: (_) =>
              const Center(child: PapyrusLoader(size: 20)),
          errorBuilder: (_, _) => Center(
            child: PapyrusAlert(message: 'Could not load ${widget.fileName}.'),
          ),
        ),
      ),
    );
  }
}
