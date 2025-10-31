import "dart:io";

import "package:flutter/material.dart";
import "package:flutter/services.dart";

class TextEditor {
  final focusNode = FocusNode();
  final controller = TextEditingController();

  final _isEditing = ValueNotifier(false);
  bool get isEditing => _isEditing.value;
  set isEditing(bool value) => _isEditing.value = value;
  void addListener(VoidCallback callback) => _isEditing.addListener(callback);
  void dispose() => _isEditing.dispose();

  final ValueChanged<String> onSubmit;
  final VoidCallback? onCancel;
  TextEditor(this.onSubmit, {this.onCancel});

  void cancel() {
    isEditing = false;
    focusNode.unfocus();
    controller.clear();
    onCancel?.call();
  }

  void submit([String? value]) {
    value ??= controller.text;
    focusNode.unfocus();
    isEditing = false;
    onSubmit(value);
  }

  void startEditing(String? text) {
    isEditing = true;
    controller.text = text ?? "";
    focusNode.requestFocus();
  }
}

class ToggleTextField extends StatelessWidget {
  final String hint;
  final TextEditor editor;
  final TextStyle? style;
  final String? Function() getValue;

  const ToggleTextField({
    required this.editor,
    required this.hint,
    required this.getValue,
    this.style,
  });

  @override
  Widget build(BuildContext context) => editor.isEditing
    ? CreateTextField(
      editor: editor,
      hint: hint,
      style: style,
    ) : InkWell(
      onTap: () => editor.startEditing(getValue()),
      child: Text(getValue() ?? hint, style: style),
    );
}

class CreateTextField extends StatelessWidget {
  final String? hint;
  final TextEditor editor;
  final TextStyle? style;
  final bool multiline;
  final bool rounded;

  const CreateTextField({
    required this.editor,
    this.hint,
    this.style,
    this.multiline = false,
    this.rounded = false,
  });

  @override
  Widget build(BuildContext context) => Focus(
    onFocusChange: (value) { if (!value) editor.cancel(); },
    onKeyEvent: (node, event) {
      // Call's onCancel() if the key is ESC, otherwise let the TextField handle it
      if (event.logicalKey == LogicalKeyboardKey.escape) editor.cancel();
      return KeyEventResult.ignored;
    },
    child: TextField(
      focusNode: editor.focusNode,
      controller: editor.controller,
      onSubmitted: editor.submit,
      autofocus: !Platform.isAndroid,
      style: style,
      maxLines: multiline ? null : 1,
      decoration: InputDecoration(
        hintText: hint,
        border: rounded ? const OutlineInputBorder() : null,
      ),
    ),
  );
}
