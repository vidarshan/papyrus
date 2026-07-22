import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:papyrus/providers/library_provider.dart';
import 'package:papyrus/ui/ui.dart';

/// A summary card for a persisted PDF conversation - name, message count,
/// and a preview of the last reply. Shared by [HomeTab], [LibraryTab] and
/// [SearchTab] since all three list the same [LibraryProvider] data.
class LibraryPdfCard extends StatelessWidget {
  const LibraryPdfCard({
    super.key,
    required this.pdf,
    required this.opening,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
  });

  final LibraryPdf pdf;
  final bool opening;
  final VoidCallback onTap;
  final ValueChanged<String> onRename;
  final VoidCallback onDelete;

  void _confirmDelete(BuildContext context) {
    showPapyrusDialog(
      context,
      title: 'Delete this PDF?',
      message:
          'This removes "${pdf.name}" and its conversation. '
          "This can't be undone.",
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
      destructive: true,
      onConfirm: onDelete,
    );
  }

  Future<void> _showRename(BuildContext context) async {
    final controller = TextEditingController(text: pdf.name);
    await showPapyrusDialog(
      context,
      title: 'Rename PDF',
      child: PapyrusTextInput(controller: controller, autofocus: true),
      confirmLabel: 'Save',
      cancelLabel: 'Cancel',
      onConfirm: () => onRename(controller.text),
    );
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PapyrusCard(
      onTap: opening ? null : onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                Row(
                  children: [
                    Expanded(
                      child: PapyrusText(pdf.name, variant: PTextVariant.body),
                    ),
                    if (pdf.messageCount > 0) ...[
                      PapyrusBadge(label: '${pdf.messageCount}'),
                      const SizedBox(width: 4),
                    ],
                  ],
                ),
                if (pdf.lastMessagePreview != null) ...[
                  const SizedBox(height: 2),
                  PapyrusText(
                    pdf.lastMessagePreview!,
                    variant: PTextVariant.caption,
                  ),
                ],
              ],
            ),
          ),
          if (!opening) ...[
            PapyrusIconButton(
              icon: const Icon(CupertinoIcons.pencil),
              size: 28,
              onPressed: () => _showRename(context),
            ),
            PapyrusIconButton(
              icon: const Icon(CupertinoIcons.trash),
              size: 28,
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ],
      ),
    );
  }
}
