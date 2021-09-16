import 'dart:typed_data';
import 'dart:ui';

import 'package:fleet_flutter/emoji/emoji_picker.dart';
import 'package:fleet_flutter/fleet_canvas.dart';
import 'package:fleet_flutter/fleet_element.dart';
import 'package:fleet_flutter/fleet_element_factory.dart';
import 'package:fleet_flutter/my_page_bloc.dart';
import 'package:fleet_flutter/output_view.dart';
import 'package:fleet_flutter/text/text_input_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';

class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final _key = GlobalKey();

  static final picker = ImagePicker();
  late final MyPageBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = MyPageBloc(FleetElementFactory());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: RepaintBoundary(
          key: _key,
          child: _buildContent(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showBottomSheet(),
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
              onInteracted: bloc.onElementInteracted,
            );
          },
        );
      },
    );
  }

  //  BottomSheetを表示する。
  void _showBottomSheet() {
    //  (仮)
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => BottomSheet(
        onClosing: () {},
        builder: (context) => Wrap(
          children: [
            //  テキスト追加
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: const Text('テキスト追加'),
              onTap: () async {
                final navigator = Navigator.of(context);
                navigator.pop();

                //  テキスト入力ダイアログを開く。
                final text = await showDialog<String>(
                  context: context,
                  builder: (context) => const TextInputDialog(),
                );

                //  正常に入力された場合
                if (text != null) bloc.onTextEntered(null, text);
              },
            ),

            //  絵文字選択
            ListTile(
              leading: const Icon(Icons.emoji_emotions),
              title: const Text('絵文字選択'),
              onTap: () async {
                final navigator = Navigator.of(context);
                navigator.pop();

                //  絵文字選択 (仮) を開く。
                final emoji = await navigator.push(
                  MaterialPageRoute<String>(
                    builder: (context) => EmojiPicker(),
                  ),
                );

                //  絵文字が選択された場合
                if (emoji != null) bloc.onEmojiPicked(emoji);
              },
            ),

            //  画像選択
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('画像選択'),
              onTap: () async {
                Navigator.pop(context);

                //  画像を選択させる。
                final image =
                    await picker.pickImage(source: ImageSource.gallery);

                //  画像が選択されたとき。
                if (image != null) {
                  final bytes = await image.readAsBytes();
                  bloc.onImagePicked(image.name, bytes);
                }
              },
            ),

            //  キャプチャ
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('キャプチャ'),
              onTap: () async {
                Navigator.of(context).pop();

                //  キャンバスをキャプチャする。
                final image = await _capture();

                //  とりあえずダイアログで表示させてみる。
                await showDialog<void>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('キャプチャ結果'),
                      content: OutputView(
                        imageBytes: image.imageBytes,
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
              },
            ),
          ],
        ),
      ),
    );
  }

  //  Fleet描画部分をキャプチャする。
  Future<CapturedImage> _capture() async {
    final boundary =
        _key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    return CapturedImage(image.width, image.height, bytes);
  }
}

//  キャプチャされた画像
class CapturedImage {
  const CapturedImage(this.width, this.height, this.imageBytes);

  final int width;
  final int height;
  final Uint8List imageBytes;
}
