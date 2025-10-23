import "package:flutter/material.dart";
import "package:flutter/services.dart";

class CreateTextField extends StatelessWidget {
  final VoidCallback onCancel;
  final ValueChanged<String> onSubmit;
  final String? hint;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final TextStyle? style;
  final bool multiline;
  final bool rounded;

  const CreateTextField({
    required this.onCancel,
    required this.onSubmit,
    required this.controller,
    this.hint,
    this.focusNode,
    this.style,
    this.multiline = false,
    this.rounded = false,
  });

  @override
  Widget build(BuildContext context) => Focus(
    onFocusChange: (value) { if (!value) onCancel(); },
    onKeyEvent: (node, event) {
      // Call's onCancel() if the key is ESC, otherwise let the TextField handle it
      if (event.logicalKey == LogicalKeyboardKey.escape) { onCancel(); }
      return KeyEventResult.ignored;
    },
    child: TextField(
      focusNode: focusNode,
      controller: controller,
      autofocus: true,
      onSubmitted: onSubmit,
      style: style,
      maxLines: multiline ? null : 1,
      decoration: InputDecoration(
        hintText: hint,
        border: rounded ? const OutlineInputBorder() : null,
      ),
    ),
  );
}
