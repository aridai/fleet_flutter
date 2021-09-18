import 'package:fleet_flutter/fleet_element.dart';
import 'package:fleet_flutter/layer/layer_cell.dart';
import 'package:fleet_flutter/layer/layer_dialog_bloc.dart';
import 'package:fleet_flutter/layer/layer_settings.dart';
import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';

/// レイヤダイアログ
class LayerDialog extends StatefulWidget {
  const LayerDialog({
    Key? key,
    required this.settings,
  }) : super(key: key);

  /// レイヤ設定 (変更前)
  final LayerSettings settings;

  @override
  State<LayerDialog> createState() => _LayerDialogState();
}

class _LayerDialogState extends State<LayerDialog> {
  late final LayerDialogBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = LayerDialogBloc(widget.settings);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('レイヤ編集'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            children: [
              buildOrderPinningSwitch(),
              const Divider(),
              Expanded(child: buildList()),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, bloc.currentSettings),
          child: const Text('適用'),
        ),
      ],
      insetPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
    );
  }

  //  並び順固定スイッチを生成する。
  Widget buildOrderPinningSwitch() {
    return StreamBuilder<bool>(
      initialData: bloc.initialIsLockEnabled,
      stream: bloc.isLockEnabled,
      builder: (context, snapshot) {
        final isEnabled = snapshot.requireData;
        final text = 'フォーカス時に最前面に移動${isEnabled ? 'されません。' : 'されます。'}';

        return SwitchListTile(
          title: const Text('並び順固定'),
          subtitle: Text(text),
          secondary: const Icon(Icons.push_pin),
          value: isEnabled,
          onChanged: bloc.onOrderPinningSwitchChanged,
        );
      },
    );
  }

  //  リスト部分を生成する。
  //  (Streamの購読)
  Widget buildList() {
    return StreamBuilder<int?>(
      initialData: bloc.initialFocusedId,
      stream: bloc.focusedId,
      builder: (context, snapshot) {
        final focusedId = snapshot.data;

        return StreamBuilder<List<FleetElement>>(
          initialData: bloc.initialList,
          stream: bloc.list,
          builder: (context, snapshot) {
            final list = snapshot.requireData;

            return buildReorderableList(list, focusedId);
          },
        );
      },
    );
  }

  //  リスト部分を生成する。
  //  (UIの生成)
  Widget buildReorderableList(List<FleetElement> list, int? focusedId) {
    //  リストの並び順を反転してリストを描画させる。
    //  (リスト後部のものが前面に描画されるため。)
    final children = List.generate(list.length, (invIndex) {
      final index = list.length - invIndex - 1;
      final element = list[index];

      return LayerCell(
        key: ValueKey(element.id),
        element: element,
        isFocused: focusedId == element.id,
        onTap: () => bloc.onLayerCellTapped(element),
      );
    });

    return ReorderableColumn(
      children: children,
      onReorder: (invOldIndex, invNewIndex) {
        final oldIndex = list.length - invOldIndex - 1;
        final newIndex = list.length - invNewIndex - 1;

        bloc.onReorder(oldIndex, newIndex);
      },
    );
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }
}
