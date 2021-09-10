import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:fleet_flutter/platform_view.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart';

class NativeEmojiView extends StatelessWidget {
  const NativeEmojiView({
    Key? key,
    required this.emoji,
    this.capturable = true,
    this.size = null,
  }) : super(key: key);

  static const _defaultSize = 256.0;

  final String emoji;
  final bool capturable;
  final double? size;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return UnsupportedNativeEmojiView(
        emoji: emoji,
        size: size ?? _defaultSize,
      );
    }

    return capturable
        ? _CapturableNativeEmojiView(emoji: emoji, size: size ?? _defaultSize)
        : _NativeEmojiView(emoji: emoji, size: size ?? _defaultSize);
  }
}

//  絵文字用のView
class _NativeEmojiView extends StatefulWidget {
  const _NativeEmojiView({
    Key? key,
    required this.emoji,
    required this.size,
  }) : super(key: key);

  final String emoji;
  final double size;

  @override
  State<_NativeEmojiView> createState() => _NativeEmojiViewState();
}

class _NativeEmojiViewState extends State<_NativeEmojiView> {
  static const viewType = 'NATIVE_EMOJI_VIEW_TYPE';

  //  HtmlElementの保持用Map
  //  (HtmlElementViewがViewに登録されてから、
  //  onPlatformViewCreated()が呼ばれるまでの間、
  //  HtmlElementを保持するために使用する。)
  static HashMap<int, HtmlElement>? elementMap = null;

  @override
  void initState() {
    super.initState();

    //  全体を通して一度のみ初期化を掛ける。
    //  全体を通して一度のみ初期化を掛ける。
    if (elementMap == null) {
      elementMap = HashMap<int, HtmlElement>();

      registerViewFactory(viewType, (id) {
        final element = DivElement()
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.textAlign = 'center'
          ..style.verticalAlign = 'middle'
          ..style.backgroundColor = 'blue';
        elementMap![id] = element;

        return element;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: HtmlElementView(
        viewType: viewType,
        onPlatformViewCreated: (id) {
          final element = elementMap![id]!;
          elementMap!.remove(id);

          final size = '${widget.size}px';
          final span = '<span style="width: $size; height: $size; line-height: $size; position: absolute; left: 0; top: 0; font: $size emoji;">${widget.emoji}</span>';
          element.style.width = size;
          element.style.height = size;
          //element.style.font = '$size emoji';
          //element.setInnerHtml(span);
          element.append(
            SpanElement()
              ..style.position = 'absolute'
              ..style.left = '0'
              ..style.top = '0'
              ..style.width = '${widget.size}px'
              ..style.height = '${widget.size}px'
              //..style.lineHeight = '${widget.size}px'
              ..style.font = '${widget.size}px emoji'
              ..text = widget.emoji
              //..styleMap!.append('line-height', '${widget.size}px'),
          );
        },
      ),
    );
  }
}

//  キャプチャ可能な絵文字用のView
//  (HTMLのCanvasで描画されたBase64画像をFlutterのImageで描画する。)
class _CapturableNativeEmojiView extends StatefulWidget {
  const _CapturableNativeEmojiView({
    Key? key,
    required this.emoji,
    required this.size,
  }) : super(key: key);

  final String emoji;
  final double size;

  @override
  State<_CapturableNativeEmojiView> createState() =>
      _CapturableNativeEmojiViewState();
}

class _CapturableNativeEmojiViewState
    extends State<_CapturableNativeEmojiView> {
  static const viewType = 'CAPTURABLE_NATIVE_EMOJI_VIEW_TYPE';

  //  CanvasElementの保持用Map
  //  (HtmlElementViewがViewに登録されてから、
  //  onPlatformViewCreated()が呼ばれるまでの間、
  //  CanvasElementを保持するために使用する。)
  static HashMap<int, CanvasElement>? elementMap = null;

  //  絵文字の画像データ
  //  (絵文字のCanvasへの描画が完了したタイミングでセットされる。)
  Uint8List? image = null;

  @override
  void initState() {
    super.initState();

    //  全体を通して一度のみ初期化を掛ける。
    if (elementMap == null) {
      elementMap = HashMap<int, CanvasElement>();

      registerViewFactory(viewType, (id) {
        final element = CanvasElement(width: 280, height: 280)
          ..style.width = '280px'
          ..style.height = '280px';
        elementMap![id] = element;

        return element;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Visibility(
            visible: false,
            maintainState: true,
            child: HtmlElementView(
              viewType: viewType,
              onPlatformViewCreated: onPlatformViewCreated,
            ),
          ),
          if (image != null) Image.memory(image!),
        ],
      ),
    );
  }

  //  CanvasElementが生成されたとき。
  void onPlatformViewCreated(int id) {
    //  保持していたCanvasElementを取り出す。
    final canvas = elementMap![id]!;
    elementMap!.remove(id);

    drawEmoji(canvas, widget.emoji);
  }

  //  絵文字を描画する。
  void drawEmoji(CanvasElement canvas, String emoji) {
    final context = canvas.context2D;
    final width = canvas.width!;
    final height = canvas.height!;
    context.clearRect(0, 0, width, height);
    context.textAlign = 'center';
    context.textBaseline = 'middle';
    context.font = '256px emoji';
    context.fillText(emoji, width / 2, height / 2, width);

    //  絵文字の画像データを生成してWidgetを更新する。
    const metaPrefix = 'data:image/png;base64,';
    final base64Emoji = canvas.toDataUrl().substring(metaPrefix.length);
    final imageBytes = base64Decode(base64Emoji);
    setState(() {
      image = imageBytes;
    });
  }
}

//  未サポートのプラットフォーム用のView
class UnsupportedNativeEmojiView extends StatelessWidget {
  const UnsupportedNativeEmojiView({
    Key? key,
    required this.emoji,
    required this.size,
  }) : super(key: key);

  final String emoji;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Text(emoji),
      ),
    );
  }
}
