import 'package:fleet_flutter/dependency.dart';
import 'package:fleet_flutter/emoji/emoji_picker.dart';
import 'package:fleet_flutter/fleet/fleet_canvas.dart';
import 'package:fleet_flutter/fleet/fleet_element.dart';
import 'package:fleet_flutter/fleet/fleet_page_args.dart';
import 'package:fleet_flutter/fleet/fleet_page_bloc.dart';
import 'package:fleet_flutter/fleet/fleet_page_bottom_sheet.dart';
import 'package:fleet_flutter/layer/layer_dialog.dart';
import 'package:fleet_flutter/layer/layer_settings.dart';
import 'package:fleet_flutter/share/share_dialog.dart';
import 'package:fleet_flutter/text/text_input_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rxdart/rxdart.dart';

/// Fleet機能のページ
class FleetPage extends StatefulWidget {
  const FleetPage({
    Key? key,
    required this.args,
  }) : super(key: key);

  /// 引数
  final FleetPageArgs args;

  @override
  _FleetPageState createState() => _FleetPageState();
}

class _FleetPageState extends State<FleetPage> {
  static final picker = ImagePicker();

  late final FleetPageBloc bloc;
  final _key = GlobalKey();
  final _compositeSubscription = CompositeSubscription();

  @override
  void initState() {
    super.initState();

    final existingElements = widget.args.maybeMap(
      edit: (edit) => edit.existingElements,
      orElse: () => null,
    );
    bloc = FleetPageBloc(
      existingElements,
      Dependency.resolve(),
      Dependency.resolve(),
      Dependency.resolve(),
    );

    bloc.layerDialogRequested
        .listen((settings) => _showLayerDialog(settings))
        .addTo(_compositeSubscription);
    bloc.shareDialogRequested
        .listen((args) => _showShareDialog(args))
        .addTo(_compositeSubscription);
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
    _compositeSubscription.dispose();
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
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => FleetPageBottomSheet(
        onTextMenuTap: () async {
          Navigator.pop(context);
          await _showTextInputDialog();
        },
        onEmojiMenuTap: () async {
          Navigator.pop(context);
          await _showEmojiPicker();
        },
        onImageMenuTap: () async {
          Navigator.pop(context);
          await _showImagePicker();
        },
        onLayerMenuTap: () {
          Navigator.pop(context);
          bloc.onLayerMenuTapped();
        },
        onCaptureMenuTap: () async {
          Navigator.of(context).pop();
          bloc.onCaptureMenuTapped(_key);
        },
      ),
    );
  }

  //  テキスト入力ダイアログを表示する。
  Future<void> _showTextInputDialog() async {
    final text = await showDialog<String>(
      context: context,
      builder: (context) => const TextInputDialog(),
    );

    //  正常に入力が行われた場合
    if (text != null) bloc.onTextEntered(null, text);
  }

  //  絵文字選択 (仮) を開く。
  Future<void> _showEmojiPicker() async {
    //  TODO: 正式実装?
    final emoji = await Navigator.of(context).push(
      MaterialPageRoute<String>(
        builder: (context) => EmojiPicker(),
      ),
    );

    //  絵文字が選択された場合
    if (emoji != null) bloc.onEmojiPicked(emoji);
  }

  //  画像選択を開く。
  Future<void> _showImagePicker() async {
    final image = await picker.pickImage(source: ImageSource.gallery);

    //  画像が選択された場合
    if (image != null) {
      final bytes = await image.readAsBytes();
      bloc.onImagePicked(image.name, bytes);
    }
  }

  //  レイヤダイアログを表示する。
  Future<void> _showLayerDialog(LayerSettings layerSettings) async {
    final result = await showDialog<LayerSettings>(
      context: context,
      builder: (context) => LayerDialog(settings: layerSettings),
    );

    //  レイヤ設定が更新された場合
    if (result != null) bloc.onLayerSettingsUpdated(result);
  }

  //  共有ダイアログを表示する。
  Future<void> _showShareDialog(ShareDialogArgs args) async {
    await showDialog<void>(
      context: context,
      builder: (context) => ShareDialog(args: args),
    );
  }
}
