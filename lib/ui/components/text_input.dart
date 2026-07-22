import 'package:flutter/cupertino.dart' show cupertinoTextSelectionControls;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/papyrus_theme.dart';
import '../theme/tokens.dart';
import 'text.dart';

/// A Mantine-style TextInput: label, description, error text, leading/
/// trailing decoration, all wired directly to the low-level EditableText
/// widget (no Material TextField / CupertinoTextField involved).
class PapyrusTextInput extends StatefulWidget {
  const PapyrusTextInput({
    super.key,
    this.controller,
    this.label,
    this.placeholder,
    this.description,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.leading,
    this.trailing,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.autofocus = false,
    this.maxLines = 1,
  });

  final TextEditingController? controller;
  final String? label;
  final String? placeholder;
  final String? description;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? leading;
  final Widget? trailing;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final bool autofocus;
  final int maxLines;

  @override
  State<PapyrusTextInput> createState() => _PapyrusTextInputState();
}

class _PapyrusTextInputState extends State<PapyrusTextInput>
    implements TextSelectionGestureDetectorBuilderDelegate {
  final GlobalKey<EditableTextState> _editableTextKey =
      GlobalKey<EditableTextState>();
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late TextSelectionGestureDetectorBuilder _selectionBuilder;
  bool _focused = false;

  @override
  GlobalKey<EditableTextState> get editableTextKey => _editableTextKey;
  @override
  bool get forcePressEnabled => false;
  @override
  bool get selectionEnabled => true;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();
    _focusNode.addListener(
      () => setState(() => _focused = _focusNode.hasFocus),
    );
    _selectionBuilder = TextSelectionGestureDetectorBuilder(delegate: this);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  void _requestFocus() => _focusNode.requestFocus();

  @override
  Widget build(BuildContext context) {
    final theme = PapyrusTheme.of(context);
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    final borderColor = hasError
        ? theme.error
        : _focused
        ? theme.borderFocus
        : theme.border;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          PapyrusText(
            widget.label!,
            variant: PTextVariant.body,
            weight: FontWeight.w500,
          ),
          const SizedBox(height: 4),
        ],
        if (widget.description != null) ...[
          PapyrusText(widget.description!, variant: PTextVariant.caption),
          const SizedBox(height: 4),
        ],
        GestureDetector(
          onTap: widget.enabled ? _requestFocus : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: widget.enabled ? theme.surface : PColors.gray[0],
              borderRadius: BorderRadius.circular(PRadius.sm),
              border: Border.all(color: borderColor, width: _focused ? 2 : 1),
            ),
            child: Row(
              children: [
                if (widget.leading != null) ...[
                  IconTheme(
                    data: IconThemeData(color: theme.textSecondary, size: 18),
                    child: widget.leading!,
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: _selectionBuilder.buildGestureDetector(
                    behavior: HitTestBehavior.translucent,
                    child: _buildEditable(theme),
                  ),
                ),
                if (widget.trailing != null) ...[
                  const SizedBox(width: 8),
                  widget.trailing!,
                ],
              ],
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          PapyrusText(
            widget.errorText!,
            variant: PTextVariant.caption,
            color: theme.error,
          ),
        ],
      ],
    );
  }

  Widget _buildEditable(PapyrusThemeData theme) {
    final textStyle = TextStyle(
      fontFamily: theme.fontFamily,
      color: widget.enabled ? theme.textPrimary : theme.textDisabled,
      fontSize: PFontSize.md,
      height: 1.3,
    );

    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        if (widget.placeholder != null)
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, _) {
              if (value.text.isNotEmpty) return const SizedBox.shrink();
              return Text(
                widget.placeholder!,
                style: textStyle.copyWith(color: theme.textDisabled),
              );
            },
          ),
        EditableText(
          key: _editableTextKey,
          controller: _controller,
          focusNode: _focusNode,
          style: textStyle,
          cursorColor: theme.primary,
          backgroundCursorColor: PColors.gray[3],
          selectionColor: theme.primary.withValues(alpha: 0.25),
          selectionControls: cupertinoTextSelectionControls,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: widget.obscureText,
          autocorrect: !widget.obscureText,
          enableSuggestions: !widget.obscureText,
          maxLines: widget.maxLines,
          readOnly: !widget.enabled,
          autofocus: widget.autofocus,
          cursorWidth: 1.5,
          cursorRadius: const Radius.circular(1),
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
        ),
      ],
    );
  }
}
