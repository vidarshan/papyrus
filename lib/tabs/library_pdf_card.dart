import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:papyrus/providers/library_provider.dart';
import 'package:papyrus/ui/ui.dart';

/// A summary card for a persisted PDF conversation - name, message count,
/// and a preview of the last reply. Shared by [HomeTab] and [LibraryTab]
/// since both list the same [LibraryProvider] data.
class LibraryPdfCard extends StatelessWidget {
  const LibraryPdfCard({
    super.key,
    required this.pdf,
    required this.opening,
    required this.onTap,
  });

  final LibraryPdf pdf;
  final bool opening;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: opening ? null : onTap,
      child: PapyrusCard(
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
                        child: PapyrusText(
                          pdf.name,
                          variant: PTextVariant.body,
                        ),
                      ),
                      if (pdf.messageCount > 0)
                        PapyrusBadge(label: '${pdf.messageCount}'),
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
          ],
        ),
      ),
    );
  }
}
