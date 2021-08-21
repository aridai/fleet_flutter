import 'dart:ui';

import 'package:fleet_flutter/fleet_canvas.dart';
import 'package:fleet_flutter/fleet_element.dart';
import 'package:fleet_flutter/my_page_bloc.dart';
import 'package:fleet_flutter/output_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final _key = GlobalKey();

  late final MyPageBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = MyPageBloc();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FleetFlutter')),
      body: Center(
        child: SizedBox(
          width: 720 / 2.5,
          height: 1280 / 2.5,
          child: RepaintBoundary(
            key: _key,
            child: _buildContent(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.photo_camera),
        onPressed: () => _capture(),
      ),
    );
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  //  メインコンテンツを生成する。
  Widget _buildContent() {
    return StreamBuilder<List<FleetElement>>(
      initialData: const [],
      stream: bloc.elements,
      builder: (context, snapshot) {
        final elements = snapshot.requireData;

        return StreamBuilder<int?>(
          initialData: null,
          stream: bloc.focusedIndex,
          builder: (context, snapshot) {
            final focusedIndex = snapshot.data;

            return FleetCanvas(
              elements: elements,
              focusedIndex: focusedIndex,
              onFocusRequested: bloc.onFocusRequested,
              onInteracted: bloc.onInteracted,
            );
          },
        );
      },
    );
  }

  //  Fleet描画部分をキャプチャする。
  Future<void> _capture() async {
    final boundary =
        _key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    //  とりあえずダイアログで表示させてみる。
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('キャプチャ結果'),
          content: OutputView(
            imageBytes: bytes,
            width: image.width,
            height: image.height,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
