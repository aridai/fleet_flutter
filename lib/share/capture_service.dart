import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// キャプチャ処理
class CaptureService {
  /// 画面をキャプチャする。
  Future<CapturedImage> capture(GlobalKey key) async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    return CapturedImage(image.width, image.height, bytes);
  }
}

/// キャプチャされた画像
class CapturedImage {
  const CapturedImage(this.width, this.height, this.imageBytes);

  /// 横幅
  final int width;

  /// 高さ
  final int height;

  /// 画像データ
  final Uint8List imageBytes;
}
