import 'package:flutter/material.dart';

/// テキスト入力ダイアログ (仮)
/// (色やテキストサイズも設定できるように変更予定)
class TextInputDialog extends StatefulWidget {
  const TextInputDialog({
    Key? key,
    this.initialText = null,
  }) : super(key: key);

  final String? initialText;

  @override
  State<TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<TextInputDialog> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialText);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('テキスト要素'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: 'テキスト'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(controller.text),
          child: const Text('OK'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
