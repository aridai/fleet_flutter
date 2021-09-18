import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:fleet_flutter/emoji/emoji_cache_store.dart';
import 'package:fleet_flutter/platform_view.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

/// 絵文字を実行環境のフォントで描画するView
class NativeEmojiView extends StatelessWidget {
  const NativeEmojiView({
    Key? key,
    required this.emoji,
    this.capturable = true,
    this.size = null,
  }) : super(key: key);

  //  描画サイズのデフォルト値
  static const _defaultSize = 256.0;

  /// 絵文字
  final String emoji;

  /// キャプチャ可能な描画方法を行うかどうか。
  final bool capturable;

  /// 描画サイズ
  final double? size;

  //  描画サイズ (未指定の場合はデフォルト値)
  double get _size => size ?? _defaultSize;

  @override
  Widget build(BuildContext context) {
    //  Web以外のプラットフォームの場合
    if (!kIsWeb) return _UnsupportedNativeEmojiView(emoji: emoji, size: _size);

    return capturable
        ? _CapturableNativeEmojiView(emoji: emoji, size: _size)
        : _NativeEmojiView(emoji: emoji, size: _size);
  }
}

//  絵文字用のView
//  (軽量であるが、キャプチャを行うことができない。)
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
  static final validator = html.NodeValidatorBuilder.common()
    ..allowInlineStyles();

  //  HtmlElementの保持用Map
  //  (HtmlElementViewがViewに登録されてから、
  //  onPlatformViewCreated()が呼ばれるまでの間、
  //  HtmlElementを保持するために使用する。)
  static HashMap<int, html.HtmlElement>? elementMap = null;

  @override
  void initState() {
    super.initState();

    //  全体を通して一度のみ初期化を掛ける。
    //  全体を通して一度のみ初期化を掛ける。
    if (elementMap == null) {
      elementMap = HashMap<int, html.HtmlElement>();

      registerViewFactory(viewType, (id) {
        final element = html.DivElement()
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.textAlign = 'center'
          ..style.verticalAlign = 'middle';
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
        onPlatformViewCreated: onPlatformViewCreated,
      ),
    );
  }

  //  HTML要素が生成されたとき。
  void onPlatformViewCreated(int id) {
    final element = elementMap![id]!;
    elementMap!.remove(id);

    //  spanタグを文字列で設定する。
    //  (SpanElementをappend()する設定方法では、
    //  line-heightスタイル属性が正しく設定できなかったため。)
    final size = '${widget.size}px';
    final styles = {
      'width': size,
      'height': size,
      'line-height': '$size !important',
      'position': 'absolute',
      'left': '0',
      'top': '0',
      'font': '$size emoji',
    };
    final styleAttr =
        styles.entries.map((e) => '${e.key}: ${e.value};').join(' ');
    final span = '<span style="$styleAttr">${widget.emoji}</span>';
    element.style.width = size;
    element.style.height = size;
    element.setInnerHtml(span, validator: validator);
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
  static const canvasSize = 300;
  static const canvasFontSize = 256;
  static const applePlatforms = ['iPhone', 'iPod', 'iPad', 'Mac'];
  static const emojiFonts = '"apple color emoji", '
      '"segoe ui emoji", '
      '"noto color emoji", '
      '"android emoji", '
      '"emojisymbols", '
      '"emojione mozilla", '
      '"twemoji mozilla", '
      '"segoe ui symbol"';
  static final cacheStore = EmojiCacheStore();
  static late final bool isApplePlatform = applePlatforms
      .any((p) => html.window.navigator.platform?.contains(p) ?? false);

  //  CanvasElementの保持用Map
  //  (HtmlElementViewがViewに登録されてから、
  //  onPlatformViewCreated()が呼ばれるまでの間、
  //  CanvasElementを保持するために使用する。)
  static HashMap<int, html.CanvasElement>? elementMap = null;

  //  絵文字の画像データ
  //  (絵文字のCanvasへの描画が完了したタイミングでセットされる。)
  Uint8List? image = null;

  @override
  void initState() {
    super.initState();

    //  全体を通して一度のみ初期化を掛ける。
    if (elementMap == null) {
      elementMap = HashMap<int, html.CanvasElement>();

      registerViewFactory(viewType, (id) {
        final element =
            html.CanvasElement(width: canvasSize, height: canvasSize)
              ..style.width = '${canvasSize}px'
              ..style.height = '${canvasSize}px';
        elementMap![id] = element;

        return element;
      });
    }

    //  キャッシュに存在する画像データの取得を試みる。
    //  (存在しない場合はnullのままとなる。)
    image = cacheStore.get(widget.emoji);
  }

  @override
  Widget build(BuildContext context) {
    //  絵文字の画像データが存在する場合はImageで描画し、
    //  存在しない場合はHTMLのCanvasでの描画を行う。
    final child = image != null
        ? Image.memory(image!)
        : HtmlElementView(
            viewType: viewType,
            onPlatformViewCreated: onPlatformViewCreated,
          );

    return SizedBox(width: widget.size, height: widget.size, child: child);
  }

  //  CanvasElementが生成されたとき。
  void onPlatformViewCreated(int id) {
    //  保持していたCanvasElementを取り出す。
    final canvas = elementMap![id]!;
    elementMap!.remove(id);

    drawEmoji(canvas, widget.emoji);
    captureEmojiImage(canvas);
  }

  //  絵文字を描画する。
  void drawEmoji(html.CanvasElement canvas, String emoji) {
    final context = canvas.context2D;
    final width = canvas.width!;
    final height = canvas.height!;
    context.clearRect(0, 0, width, height);
    context.textAlign = 'center';
    context.textBaseline = 'middle';
    context.font =
        '${canvasFontSize}px ${isApplePlatform ? 'emoji' : emojiFonts}';
    context.fillText(emoji, width / 2, height / 2, width);
  }

  //  絵文字の画像データを生成してWidgetを更新する。
  void captureEmojiImage(html.CanvasElement canvas) {
    const metaPrefix = 'data:image/png;base64,';
    final base64Emoji = canvas.toDataUrl().substring(metaPrefix.length);
    final imageBytes = base64Decode(base64Emoji);
    setState(() {
      image = imageBytes;
      cacheStore.save(widget.emoji, imageBytes);
    });
  }
}

//  未サポートのプラットフォーム用のView
class _UnsupportedNativeEmojiView extends StatelessWidget {
  const _UnsupportedNativeEmojiView({
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
