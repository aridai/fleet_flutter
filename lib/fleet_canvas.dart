import 'package:collection/collection.dart';
import 'package:fleet_flutter/fleet_element.dart';
import 'package:fleet_flutter/fleet_element_view.dart';
import 'package:flutter/material.dart';

/// Fleet要素のフォーカス要求を通知するコールバック
typedef FocusRequestedCallback = void Function(int? index);

/// Fleet要素に対する操作のコールバック
typedef InteractionCallback = void Function(
  int index,
  Offset translationDelta,
  double scaleDelta,
  double rotationDelta,
);

/// Fleetの描画領域
class FleetCanvas extends StatefulWidget {
  const FleetCanvas({
    Key? key,
    required this.elements,
    required this.focusedIndex,
    required this.onFocusRequested,
    required this.onInteracted,
  }) : super(key: key);

  final List<FleetElement> elements;
  final int? focusedIndex;
  final FocusRequestedCallback onFocusRequested;
  final InteractionCallback onInteracted;

  @override
  _FleetCanvasState createState() => _FleetCanvasState();
}

class _FleetCanvasState extends State<FleetCanvas> {
  double? _scale = null;
  double? _rotation = null;
  Offset? _focalPoint = null;

  @override
  Widget build(BuildContext context) {
    final children = widget.elements.mapIndexed(
      (index, element) {
        return FleetElementView(
          element: element,
          isFocused: widget.focusedIndex == index,
          onFocusRequested: () => widget.onFocusRequested(index),
        );
      },
    ).toList(growable: false);

    return GestureDetector(
      onTap: _onTap,
      onScaleStart: _onScaleStart,
      onScaleUpdate: _onScaleUpdate,
      onScaleEnd: _onScaleEnd,
      child: Container(
        color: Colors.grey.withOpacity(0.5),
        child: Stack(children: children),
      ),
    );
  }

  //  タップ時
  void _onTap() {
    //  要素以外の部分をタップした場合はフォーカスを外させる。
    widget.onFocusRequested(null);
  }

  //  スケール開始時
  void _onScaleStart(ScaleStartDetails details) {
    _scale = 1.0;
    _rotation = 0.0;
    _focalPoint = details.focalPoint;
  }

  //  スケール更新時
  void _onScaleUpdate(ScaleUpdateDetails details) {
    //  前回のフレームからの差分を更新通知するようにする。
    final scaleDelta = details.scale / _scale!;
    final rotationDelta = details.rotation - _rotation!;
    final dragDelta = details.focalPoint - _focalPoint!;

    //  フォーカス中であれば、コールバックで通知を行う。
    final index = widget.focusedIndex;
    if (index != null) {
      widget.onInteracted(index, dragDelta, scaleDelta, rotationDelta);
    }

    //  値を記録しておく。
    _scale = details.scale;
    _rotation = details.rotation;
    _focalPoint = details.focalPoint;
  }

  //  スケール終了時
  void _onScaleEnd(ScaleEndDetails details) {
    _scale = null;
    _rotation = null;
    _focalPoint = null;
  }
}
