import 'dart:io';

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:papyrus/chat/PdfChatScreen.dart';
import 'package:papyrus/providers/device_pdfs_provider.dart';
import 'package:papyrus/providers/library_provider.dart';
import 'package:papyrus/tabs/library_pdf_card.dart';
import 'package:papyrus/ui/ui.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class LibraryTab extends StatefulWidget {
  const LibraryTab({super.key});

  @override
  State<LibraryTab> createState() => _LibraryTabState();
}

class _LibraryTabState extends State<LibraryTab> {
  late final DevicePdfsProvider _provider;
  late final LibraryProvider _libraryProvider;
  String? _openingId;
  String? _actionError;

  @override
  void initState() {
    super.initState();
    _provider = DevicePdfsProvider();
    _provider.init();
    _libraryProvider = LibraryProvider();
    _libraryProvider.init();
  }

  @override
  void dispose() {
    _provider.dispose();
    _libraryProvider.dispose();
    super.dispose();
  }

  /// Opens a chat for a PDF that's already persisted in the user's library.
  Future<void> _openLibraryChat(LibraryPdf pdf) async {
    setState(() {
      _openingId = pdf.id;
      _actionError = null;
    });

    try {
      if (!mounted) return;
      await Navigator.of(context).push(
        PapyrusPageRoute(
          settings: const RouteSettings(name: '/pdf-chat'),
          builder: (_) => PdfChatScreen(pdfId: pdf.id, fileName: pdf.name),
        ),
      );
    } catch (e) {
      if (mounted) setState(() => _actionError = 'Could not open ${pdf.name}.');
    } finally {
      if (mounted) setState(() => _openingId = null);
    }
  }

  Future<void> _renamePdf(LibraryPdf pdf, String newName) async {
    try {
      await _libraryProvider.renamePdf(pdf, newName);
    } catch (e) {
      if (mounted) {
        setState(() => _actionError = 'Could not rename ${pdf.name}.');
      }
    }
  }

  Future<void> _deletePdf(LibraryPdf pdf) async {
    try {
      await _libraryProvider.deletePdf(pdf);
    } catch (e) {
      if (mounted) {
        setState(() => _actionError = 'Could not delete ${pdf.name}.');
      }
    }
  }

  /// Opens a chat for a PDF found on the device, indexing it into the
  /// persisted library first (if not already) so it reappears next time.
  Future<void> _openChat(DevicePdf pdf) async {
    setState(() {
      _openingId = pdf.id;
      _actionError = null;
    });

    try {
      final bytes = await _provider.readBytes(pdf);
      final pdfId = await _provider.ensureUploaded(pdf, bytes: bytes);
      if (!mounted) return;
      await Navigator.of(context).push(
        PapyrusPageRoute(
          settings: const RouteSettings(name: '/pdf-chat'),
          builder: (_) => PdfChatScreen(pdfId: pdfId, fileName: pdf.name),
        ),
      );
    } catch (e) {
      if (mounted) setState(() => _actionError = 'Could not open ${pdf.name}.');
    } finally {
      if (mounted) setState(() => _openingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _libraryProvider),
        ChangeNotifierProvider.value(value: _provider),
      ],
      child: PapyrusScaffold(
        title: 'Library',
        padHorizontal: true,
        body: Consumer2<LibraryProvider, DevicePdfsProvider>(
          builder: (context, libraryProvider, provider, _) =>
              _buildBody(context, libraryProvider, provider),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    LibraryProvider libraryProvider,
    DevicePdfsProvider provider,
  ) {
    if (provider.permissionDenied && provider.pdfs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PapyrusAlert(
              title: 'Storage permission needed',
              message:
                  'Papyrus needs permission to see PDFs stored on your device.',
            ),
            const SizedBox(height: PSpacing.md),
            PapyrusButton(
              label: provider.permissionPermanentlyDenied
                  ? 'Open settings'
                  : 'Grant permission',
              onPressed: provider.permissionPermanentlyDenied
                  ? openAppSettings
                  : provider.loadDevicePdfs,
            ),
            const SizedBox(height: PSpacing.sm),
            PapyrusButton(
              label: 'Browse manually instead',
              variant: PButtonVariant.subtle,
              onPressed: provider.browseForPdfs,
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(top: PSpacing.md, bottom: PSpacing.lg),
      children: [
        if (libraryProvider.error != null) ...[
          PapyrusAlert(message: libraryProvider.error!),
          const SizedBox(height: PSpacing.md),
        ],
        if (provider.error != null) ...[
          PapyrusAlert(message: provider.error!),
          const SizedBox(height: PSpacing.md),
        ],
        if (_actionError != null) ...[
          PapyrusAlert(message: _actionError!),
          const SizedBox(height: PSpacing.md),
        ],
        ..._buildLibrarySection(libraryProvider),
        ..._buildDeviceSection(provider),
      ],
    );
  }

  List<Widget> _buildLibrarySection(LibraryProvider libraryProvider) {
    if (libraryProvider.isLoading) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: PSpacing.md),
          child: Center(child: PapyrusLoader(size: 24)),
        ),
      ];
    }
    if (libraryProvider.pdfs.isEmpty) return const [];

    return [
      const PapyrusText('Your PDFs', variant: PTextVariant.subtitle),
      const SizedBox(height: PSpacing.sm),
      for (final pdf in libraryProvider.pdfs) ...[
        LibraryPdfCard(
          pdf: pdf,
          opening: _openingId == pdf.id,
          onTap: () => _openLibraryChat(pdf),
          onRename: (newName) => _renamePdf(pdf, newName),
          onDelete: () => _deletePdf(pdf),
        ),
        const SizedBox(height: PSpacing.sm),
      ],
      const SizedBox(height: PSpacing.md),
    ];
  }

  List<Widget> _buildDeviceSection(DevicePdfsProvider provider) {
    final title = Platform.isAndroid && provider.needsLegacyStorage
        ? 'PDFs on this device'
        : 'Add a PDF';

    return [
      Row(
        children: [
          Expanded(child: PapyrusText(title, variant: PTextVariant.subtitle)),
          PapyrusIconButton(
            icon: const Icon(CupertinoIcons.folder_badge_plus),
            onPressed: provider.browseForPdfs,
          ),
        ],
      ),
      const SizedBox(height: PSpacing.sm),
      if (provider.isLoading)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: PSpacing.md),
          child: Center(child: PapyrusLoader(size: 24)),
        )
      else if (provider.pdfs.isEmpty)
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (Platform.isAndroid && !provider.needsLegacyStorage)
                Padding(
                  padding: const EdgeInsets.only(bottom: PSpacing.sm),
                  child: PapyrusText(
                    'Pick a PDF from your device to add it here.',
                    variant: PTextVariant.caption,
                  ),
                ),
              PapyrusButton(
                label: 'Browse for PDFs',
                leading: const Icon(CupertinoIcons.folder),
                onPressed: provider.browseForPdfs,
              ),
            ],
          ),
        )
      else
        for (final pdf in provider.pdfs) ...[
          _buildDeviceCard(provider, pdf),
          const SizedBox(height: PSpacing.sm),
        ],
    ];
  }

  Widget _buildDeviceCard(DevicePdfsProvider provider, DevicePdf pdf) {
    final status = provider.uploadStatus[pdf.id] ?? PdfUploadStatus.idle;
    final opening = _openingId == pdf.id;
    return PapyrusCard(
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: opening ? null : () => _openChat(pdf),
              child: Row(
                children: [
                  opening
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: PapyrusLoader(size: 16),
                        )
                      : const Icon(CupertinoIcons.doc_text),
                  const SizedBox(width: PSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PapyrusText(pdf.name, variant: PTextVariant.body),
                        PapyrusText(
                          _formatSize(pdf.size),
                          variant: PTextVariant.caption,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: PSpacing.sm),
          _buildTrailing(provider, pdf, status),
        ],
      ),
    );
  }

  Widget _buildTrailing(
    DevicePdfsProvider provider,
    DevicePdf pdf,
    PdfUploadStatus status,
  ) {
    final theme = PapyrusTheme.of(context);
    switch (status) {
      case PdfUploadStatus.uploading:
        return const PapyrusLoader(size: 18);
      case PdfUploadStatus.uploaded:
        return Icon(
          CupertinoIcons.check_mark_circled_solid,
          color: theme.success,
        );
      case PdfUploadStatus.failed:
        return PapyrusIconButton(
          icon: Icon(CupertinoIcons.exclamationmark_circle, color: theme.error),
          onPressed: () => provider.uploadPdf(pdf),
        );
      case PdfUploadStatus.idle:
        return PapyrusIconButton(
          icon: const Icon(CupertinoIcons.cloud_upload),
          onPressed: () => provider.uploadPdf(pdf),
        );
    }
  }

  String _formatSize(int bytes) {
    if (bytes <= 0) return '';
    const units = ['B', 'KB', 'MB', 'GB'];
    var size = bytes.toDouble();
    var unitIndex = 0;
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    return '${size.toStringAsFixed(size < 10 && unitIndex > 0 ? 1 : 0)} ${units[unitIndex]}';
  }
}
