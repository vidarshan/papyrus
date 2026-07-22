import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart' show Theme, ThemeData;
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:papyrus/chat/PdfViewerScreen.dart';
import 'package:papyrus/providers/pdf_chat_provider.dart';
import 'package:papyrus/ui/ui.dart';
import 'package:provider/provider.dart';

class PdfChatScreen extends StatefulWidget {
  const PdfChatScreen({
    super.key,
    required this.pdfId,
    required this.fileName,
  });

  final String pdfId;
  final String fileName;

  @override
  State<PdfChatScreen> createState() => _PdfChatScreenState();
}

const _suggestedPrompts = [
  'Summarize the key points',
  'Extract action items',
  "Explain this like I'm five",
  'What questions should I ask about this?',
];

class _PdfChatScreenState extends State<PdfChatScreen> {
  late final PdfChatProvider _provider;
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  int _lastMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _provider = PdfChatProvider(pdfId: widget.pdfId, fileName: widget.fileName);
    _provider.addListener(_scrollToBottomOnNewMessage);
    _provider.init();
  }

  @override
  void dispose() {
    _provider.removeListener(_scrollToBottomOnNewMessage);
    _provider.dispose();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottomOnNewMessage() {
    if (_provider.messages.length == _lastMessageCount) return;
    _lastMessageCount = _provider.messages.length;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  void _send() {
    final text = _inputController.text;
    _inputController.clear();
    _provider.sendMessage(text);
  }

  void _sendSuggestion(String prompt) {
    _provider.sendMessage(prompt);
  }

  void _openViewer(BuildContext context, {int page = 1}) {
    Navigator.of(context).push(
      PapyrusPageRoute(
        settings: const RouteSettings(name: '/pdf-viewer'),
        builder: (_) => PdfViewerScreen(
          pdfId: widget.pdfId,
          fileName: widget.fileName,
          initialPage: page,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = PapyrusTheme.of(context);

    return ChangeNotifierProvider.value(
      value: _provider,
      child: PapyrusScaffold(
        title: widget.fileName,
        leading: PapyrusIconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          PapyrusIconButton(
            icon: const Icon(CupertinoIcons.doc_text),
            onPressed: () => _openViewer(context),
          ),
        ],
        body: Consumer<PdfChatProvider>(
          builder: (context, provider, _) {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: PSpacing.md,
                      vertical: PSpacing.sm,
                    ),
                    itemCount:
                        provider.messages.length + (provider.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= provider.messages.length) {
                        return const _ChatBubble(
                          role: ChatRole.model,
                          child: PapyrusLoader(size: 16),
                        );
                      }
                      final message = provider.messages[index];
                      return _ChatBubble(
                        role: message.role,
                        child: message.role == ChatRole.user
                            ? PapyrusText(
                                message.text,
                                color: theme.primaryText,
                              )
                            : _MarkdownMessage(
                                text: message.text,
                                theme: theme,
                                onCitationTap: (page) =>
                                    _openViewer(context, page: page),
                              ),
                      );
                    },
                  ),
                ),
                if (provider.error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: PSpacing.md,
                    ),
                    child: PapyrusAlert(message: provider.error!),
                  ),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: PSpacing.md,
                    ),
                    itemCount: _suggestedPrompts.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(width: PSpacing.xs),
                    itemBuilder: (context, index) {
                      final prompt = _suggestedPrompts[index];
                      return PapyrusButton(
                        label: prompt,
                        variant: PButtonVariant.light,
                        size: PButtonSize.sm,
                        onPressed: provider.isLoading
                            ? null
                            : () => _sendSuggestion(prompt),
                      );
                    },
                  ),
                ),
                const SizedBox(height: PSpacing.xs),
                Padding(
                  padding: const EdgeInsets.all(PSpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: PapyrusTextInput(
                          controller: _inputController,
                          placeholder: 'Ask about this PDF…',
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _send(),
                          enabled: !provider.isLoading,
                        ),
                      ),
                      const SizedBox(width: PSpacing.sm),
                      PapyrusIconButton(
                        icon: const Icon(CupertinoIcons.arrow_up_circle_fill),
                        onPressed: provider.isLoading ? null : _send,
                        size: 44,
                        color: theme.primary,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.role, required this.child});

  final ChatRole role;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = PapyrusTheme.of(context);
    final isUser = role == ChatRole.user;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: PSpacing.xs / 2),
        padding: const EdgeInsets.symmetric(
          horizontal: PSpacing.sm,
          vertical: PSpacing.xs,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: isUser ? theme.primary : theme.surface,
          border: isUser ? null : Border.all(color: theme.border),
          borderRadius: BorderRadius.circular(PRadius.md),
        ),
        child: child,
      ),
    );
  }
}

/// Renders Gemini's markdown-formatted replies (bold, lists, headers, code)
/// using the Papyrus theme's colors and font. `flutter_markdown_plus` reads
/// an ambient Material `Theme` internally as a fallback before our
/// [MarkdownStyleSheet] overrides it, so it's wrapped in a throwaway [Theme]
/// even though the rest of the app avoids Material widgets.
class _MarkdownMessage extends StatelessWidget {
  const _MarkdownMessage({
    required this.text,
    required this.theme,
    required this.onCitationTap,
  });

  final String text;
  final PapyrusThemeData theme;
  final ValueChanged<int> onCitationTap;

  @override
  Widget build(BuildContext context) {
    final baseStyle = TextStyle(
      fontFamily: theme.fontFamily,
      color: theme.textPrimary,
      fontSize: PFontSize.md,
      height: 1.3,
    );

    return Theme(
      data: ThemeData.light(),
      child: MarkdownBody(
        data: text,
        selectable: true,
        onTapLink: (text, href, title) {
          final page = href != null && href.startsWith('page:')
              ? int.tryParse(href.substring('page:'.length))
              : null;
          if (page != null) onCitationTap(page);
        },
        styleSheet: MarkdownStyleSheet(
          p: baseStyle,
          h1: baseStyle.copyWith(
            fontSize: PFontSize.xxl,
            fontWeight: FontWeight.w700,
          ),
          h2: baseStyle.copyWith(
            fontSize: PFontSize.xl,
            fontWeight: FontWeight.w700,
          ),
          h3: baseStyle.copyWith(
            fontSize: PFontSize.lg,
            fontWeight: FontWeight.w600,
          ),
          strong: baseStyle.copyWith(fontWeight: FontWeight.w700),
          em: baseStyle.copyWith(fontStyle: FontStyle.italic),
          listBullet: baseStyle,
          blockquote: baseStyle.copyWith(color: theme.textSecondary),
          blockquoteDecoration: BoxDecoration(
            border: Border(left: BorderSide(color: theme.border, width: 3)),
          ),
          code: baseStyle.copyWith(
            fontFamily: 'monospace',
            backgroundColor: PColors.gray[1],
            fontSize: PFontSize.sm,
          ),
          codeblockDecoration: BoxDecoration(
            color: PColors.gray[1],
            borderRadius: BorderRadius.circular(PRadius.sm),
          ),
          a: baseStyle.copyWith(color: theme.primary),
          horizontalRuleDecoration: BoxDecoration(
            border: Border(top: BorderSide(color: theme.border)),
          ),
        ),
      ),
    );
  }
}
