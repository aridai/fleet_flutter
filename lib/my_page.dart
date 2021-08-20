import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FleetFlutter')),
      body: Center(
        child: SizedBox(
          width: 320,
          height: 280,
          child: RepaintBoundary(
            key: _key,
            child: Container(
              color: Colors.blue,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Hello'),
                    SizedBox(height: 16),
                    FlutterLogo(size: 32),
                    SizedBox(height: 16),
                    Text('🍣'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.photo_camera),
        onPressed: () => _capture(),
      ),
    );
  }

  Future<void> _capture() async {
    final boundary =
        _key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('キャプチャ結果'),
          content: Image.memory(bytes),
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
