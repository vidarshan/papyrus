import 'package:papyrus/chat/PdfChatScreen.dart';
import 'package:papyrus/providers/library_provider.dart';
import 'package:papyrus/tabs/library_pdf_card.dart';
import 'package:papyrus/ui/ui.dart';
import 'package:provider/provider.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late final LibraryProvider _provider;
  String? _openingId;
  String? _openError;

  @override
  void initState() {
    super.initState();
    _provider = LibraryProvider();
    _provider.init();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  Future<void> _openChat(LibraryPdf pdf) async {
    setState(() {
      _openingId = pdf.id;
      _openError = null;
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
      if (mounted) setState(() => _openError = 'Could not open ${pdf.name}.');
    } finally {
      if (mounted) setState(() => _openingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: PapyrusScaffold(
        title: 'Home',
        padHorizontal: true,
        body: Consumer<LibraryProvider>(
          builder: (context, provider, _) => _buildBody(context, provider),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, LibraryProvider provider) {
    if (provider.isLoading) {
      return const Center(child: PapyrusLoader(size: 28));
    }

    if (provider.pdfs.isEmpty) {
      return Center(
        child: PapyrusText(
          'Upload a PDF from Library to start your first conversation.',
          variant: PTextVariant.caption,
          align: TextAlign.center,
        ),
      );
    }

    final totalMessages = provider.pdfs.fold<int>(
      0,
      (sum, pdf) => sum + pdf.messageCount,
    );

    return ListView(
      padding: const EdgeInsets.only(top: PSpacing.md, bottom: PSpacing.lg),
      children: [
        if (provider.error != null) ...[
          PapyrusAlert(message: provider.error!),
          const SizedBox(height: PSpacing.md),
        ],
        if (_openError != null) ...[
          PapyrusAlert(message: _openError!),
          const SizedBox(height: PSpacing.md),
        ],
        Row(
          children: [
            Expanded(
              child: _StatTile(label: 'PDFs', value: provider.pdfs.length),
            ),
            const SizedBox(width: PSpacing.sm),
            Expanded(
              child: _StatTile(label: 'Messages', value: totalMessages),
            ),
          ],
        ),
        const SizedBox(height: PSpacing.lg),
        const PapyrusText(
          'Recent conversations',
          variant: PTextVariant.subtitle,
        ),
        const SizedBox(height: PSpacing.sm),
        for (final pdf in provider.pdfs) ...[
          LibraryPdfCard(
            pdf: pdf,
            opening: _openingId == pdf.id,
            onTap: () => _openChat(pdf),
          ),
          const SizedBox(height: PSpacing.sm),
        ],
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return PapyrusCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PapyrusText(
            '$value',
            variant: PTextVariant.title,
            size: PFontSize.xxl,
          ),
          const SizedBox(height: 2),
          PapyrusText(label, variant: PTextVariant.caption),
        ],
      ),
    );
  }
}
