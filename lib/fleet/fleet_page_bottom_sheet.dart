import 'package:flutter/material.dart';

/// FleetPageのBottomSheet
class FleetPageBottomSheet extends StatelessWidget {
  const FleetPageBottomSheet({
    Key? key,
    required this.onTextMenuTap,
    required this.onEmojiMenuTap,
    required this.onImageMenuTap,
    required this.onLayerMenuTap,
    required this.onCaptureMenuTap,
  }) : super(key: key);

  /// 「テキスト追加」がタップされたときのコールバック
  final VoidCallback onTextMenuTap;

  /// 「絵文字選択」がタップされたときのコールバック
  final VoidCallback onEmojiMenuTap;

  /// 「画像選択」がタップされたときのコールバック
  final VoidCallback onImageMenuTap;

  /// 「レイヤ編集」がタップされたときのコールバック
  final VoidCallback onLayerMenuTap;

  /// 「キャプチャ」がタップされたときのコールバック
  final VoidCallback onCaptureMenuTap;

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      onClosing: () {},
      builder: (context) => Wrap(
        children: [
          //  テキスト追加
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: const Text('テキスト追加'),
            onTap: onTextMenuTap,
          ),

          //  絵文字選択
          ListTile(
            leading: const Icon(Icons.emoji_emotions),
            title: const Text('絵文字選択'),
            onTap: onEmojiMenuTap,
          ),

          //  画像選択
          ListTile(
            leading: const Icon(Icons.photo),
            title: const Text('画像選択'),
            onTap: onImageMenuTap,
          ),

          //  レイヤ編集
          ListTile(
            leading: const Icon(Icons.layers),
            title: const Text('レイヤ編集'),
            onTap: onLayerMenuTap,
          ),

          //  キャプチャ
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: const Text('キャプチャ'),
            onTap: onCaptureMenuTap,
          ),
        ],
      ),
    );
  }
}
