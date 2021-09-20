import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:fleet_flutter/platform_view.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart';

/// 出力画像を表示するView
/// (Webだとimgタグで表示され、iOS/Androidだと長押しで共有ができる画像で表示される。)
class OutputView extends StatelessWidget {
  const OutputView({
    Key? key,
    required this.imageBytes,
    required this.width,
    required this.height,
  }) : super(key: key);

  final Uint8List imageBytes;
  final int width;
  final int height;

  @override
  Widget build(BuildContext context) {
    //  Webアプリ向け
    if (kIsWeb) {
      return WebOutputView(
        imageBytes: imageBytes,
        width: width,
        height: height,
      );
    }

    //  ネイティブアプリ向け
    else {
      return MobileOutputView(
        imageBytes: imageBytes,
        width: width,
        height: height,
      );
    }
  }
}

/// Web実行時の出力用View
/// (imgタグを使って表示する。)
class WebOutputView extends StatefulWidget {
  const WebOutputView({
    Key? key,
    required this.imageBytes,
    required this.width,
    required this.height,
  }) : super(key: key);

  static const _viewType = 'OUTPUT_VIEW';
  static late final ImageElement _element;

  final Uint8List imageBytes;
  final int width;
  final int height;

  /// 初期化処理を行う。
  /// (アプリ起動時に一度のみ行う。)
  static void init() {
    //  TODO: 実装方法を変更
    //  > Height of Platform View type: [OUTPUT_VIEW] may not be set. Defaulting to `height: 100%`.
    //  > Set `style.height` to any appropriate value to stop this message.
    //  > Width of Platform View type: [OUTPUT_VIEW] may not be set. Defaulting to `width: 100%`.
    //  > Set `style.width` to any appropriate value to stop this message.

    if (kIsWeb) {
      _element = ImageElement();
      registerViewFactory(_viewType, (id) => _element);
    }
  }

  /// imgタグの設定を行う。
  static void setImage(String src, int width, int height) {
    _element.src = src;
    _element.width = width;
    _element.height = height;
  }

  @override
  _WebOutputViewState createState() => _WebOutputViewState();
}

class _WebOutputViewState extends State<WebOutputView> {
  //  imgタグ用のHtmlElementView
  //  (ネイティブアプリ向けにビルドした際にエラーとなるため、constを指定しないようにする。)
  //  ignore: prefer_const_constructors
  static final htmlElementView = HtmlElementView(
    viewType: WebOutputView._viewType,
  );

  @override
  void initState() {
    super.initState();

    final src = 'data:image/png;base64,${base64Encode(widget.imageBytes)}';
    WebOutputView.setImage(src, widget.width, widget.height);
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.width / widget.height,
      child: htmlElementView,
    );
  }
}

/// iOS/Androidのネイティブアプリ実行時の出力用View
class MobileOutputView extends StatefulWidget {
  const MobileOutputView({
    Key? key,
    required this.imageBytes,
    required this.width,
    required this.height,
  }) : super(key: key);

  final Uint8List imageBytes;
  final int width;
  final int height;

  @override
  _MobileOutputViewState createState() => _MobileOutputViewState();
}

class _MobileOutputViewState extends State<MobileOutputView> {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.width / widget.height,
      child: InkWell(
        onTap: () => _shareImage(),
        child: Image.memory(widget.imageBytes),
      ),
    );
  }

  //  画像の共有を行う。
  Future<void> _shareImage() async {
    final dir = await getTemporaryDirectory();
    final file = io.File('${dir.path}/image.png');
    await file.writeAsBytes(widget.imageBytes);

    await Share.shareFiles(
      [file.path],
      mimeTypes: const ['image/png'],
      subject: 'Fleet画像を共有',
    );
  }
}
