import 'dart:convert';

import 'package:fleet_flutter/fleet/fleet_element.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'fleet_dto.g.dart';

/// FleetデータのDTO
@JsonSerializable()
class FleetDto {
  FleetDto(this.elements);

  /// JSONから変換する。
  factory FleetDto.fromJson(Map<String, dynamic> json) =>
      _$FleetDtoFromJson(json);

  /// JSON文字列から変換する。
  factory FleetDto.fromJsonString(String jsonStr) =>
      FleetDto.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);

  /// Fleet要素のDTOのリスト
  final List<_FleetElementDto> elements;

  /// JSONに変換する。
  Map<String, dynamic> toJson() => _$FleetDtoToJson(this);

  /// JSON文字列に変換する。
  String toJsonStr() => jsonEncode(toJson());

  /// Fleet要素のリストに変換する。
  List<FleetElement> toFleetElements() {
    return elements.map((e) => e.toFleetElement()).toList();
  }

  /// Fleet要素のリストからDTOに変換する。
  static FleetDto from(List<FleetElement> elements) {
    final convertedElements =
        elements.map((e) => _FleetElementDto.from(e)).toList();

    return FleetDto(convertedElements);
  }
}

//  Fleet要素の種類
enum _FleetElementType { text, emoji, image }

//  Fleet要素のDTO
@JsonSerializable()
class _FleetElementDto {
  _FleetElementDto(
    this.id,
    this.type,
    this.value,
    this.x,
    this.y,
    this.scale,
    this.angle,
  );

  //  JSONから変換する。
  factory _FleetElementDto.fromJson(Map<String, dynamic> json) =>
      _$FleetElementDtoFromJson(json);

  //  Fleet要素のID
  final int id;

  //  Fleet要素種類
  final _FleetElementType type;

  //  そのFleet要素のもつ値
  //  * テキスト要素: テキスト
  //  * 絵文字要素: 絵文字
  final String value;

  //  X座標
  final double x;

  //  Y座標
  final double y;

  //  拡大率
  final double scale;

  //  角度
  final double angle;

  //  JSONに変換する。
  Map<String, dynamic> toJson() => _$FleetElementDtoToJson(this);

  FleetElement toFleetElement() {
    switch (type) {
      case _FleetElementType.text:
        return FleetElement.text(id, value, Offset(x, y), scale, angle);

      case _FleetElementType.emoji:
        return FleetElement.emoji(id, value, Offset(x, y), scale, angle);

      case _FleetElementType.image:
        throw UnsupportedError('画像要素は未対応です。');
    }
  }

  //  Fleet要素からDTOに変換する。
  static _FleetElementDto from(FleetElement element) {
    return element.map(
      text: (text) => _FleetElementDto(
        text.id,
        _FleetElementType.text,
        text.text,
        text.pos.dx,
        text.pos.dy,
        text.scale,
        text.angleInRad,
      ),
      emoji: (emoji) => _FleetElementDto(
        emoji.id,
        _FleetElementType.emoji,
        emoji.emoji,
        emoji.pos.dx,
        emoji.pos.dy,
        emoji.scale,
        emoji.angleInRad,
      ),
      image: (image) => throw UnsupportedError('画像要素は未対応です。'),
    );
  }
}
