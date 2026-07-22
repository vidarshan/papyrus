import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:papyrus/chat/PdfChatScreen.dart';
import 'package:papyrus/providers/library_provider.dart';
import 'package:papyrus/tabs/library_pdf_card.dart';
import 'package:papyrus/ui/ui.dart';
import 'package:provider/provider.dart';

/// Searches the signed-in user's persisted PDF library by file name and by
/// the last Gemini reply's preview text, so a conversation can be found
/// again by roughly what it was about as well as by file name.
class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  late final LibraryProvider _provider;
  final _queryController = TextEditingController();
  String _query = '';
  String? _openingId;
  String? _actionError;

  @override
  void initState() {
    super.initState();
    _provider = LibraryProvider();
    _provider.init();
  }

  @override
  void dispose() {
    _provider.dispose();
    _queryController.dispose();
    super.dispose();
  }

  List<LibraryPdf> _matches(LibraryProvider provider) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return provider.pdfs.where((pdf) {
      return pdf.name.toLowerCase().contains(q) ||
          (pdf.lastMessagePreview?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  Future<void> _openChat(LibraryPdf pdf) async {
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
      await _provider.renamePdf(pdf, newName);
    } catch (e) {
      if (mounted) {
        setState(() => _actionError = 'Could not rename ${pdf.name}.');
      }
    }
  }

  Future<void> _deletePdf(LibraryPdf pdf) async {
    try {
      await _provider.deletePdf(pdf);
    } catch (e) {
      if (mounted) {
        setState(() => _actionError = 'Could not delete ${pdf.name}.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: PapyrusScaffold(
        title: 'Search',
        padHorizontal: true,
        body: Consumer<LibraryProvider>(
          builder: (context, provider, _) => _buildBody(context, provider),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, LibraryProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: PSpacing.md),
        PapyrusTextInput(
          controller: _queryController,
          placeholder: 'Search PDFs and conversations…',
          leading: const Icon(CupertinoIcons.search),
          autofocus: true,
          onChanged: (value) => setState(() => _query = value),
        ),
        const SizedBox(height: PSpacing.md),
        Expanded(child: _buildResults(context, provider)),
      ],
    );
  }

  Widget _buildResults(BuildContext context, LibraryProvider provider) {
    if (provider.isLoading) {
      return const Center(child: PapyrusLoader(size: 28));
    }

    if (provider.error != null) {
      return PapyrusAlert(message: provider.error!);
    }

    if (_query.trim().isEmpty) {
      return Center(
        child: PapyrusText(
          'Start typing to search your PDFs and conversations.',
          variant: PTextVariant.caption,
          align: TextAlign.center,
        ),
      );
    }

    final results = _matches(provider);

    if (results.isEmpty) {
      return Center(
        child: PapyrusText(
          'No PDFs or conversations match "${_query.trim()}".',
          variant: PTextVariant.caption,
          align: TextAlign.center,
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: PSpacing.lg),
      children: [
        if (_actionError != null) ...[
          PapyrusAlert(message: _actionError!),
          const SizedBox(height: PSpacing.md),
        ],
        for (final pdf in results) ...[
          LibraryPdfCard(
            pdf: pdf,
            opening: _openingId == pdf.id,
            onTap: () => _openChat(pdf),
            onRename: (newName) => _renamePdf(pdf, newName),
            onDelete: () => _deletePdf(pdf),
          ),
          const SizedBox(height: PSpacing.sm),
        ],
      ],
    );
  }
}
