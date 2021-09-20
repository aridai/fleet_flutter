import 'dart:convert';

import 'package:fleet_flutter/fleet/fleet_element.dart';
import 'package:fleet_flutter/share/fleet_dto.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;

/// 共有リンクの生成ロジック
class ShareLinkGenerator {
  //  クエリパラメタ名
  static const _paramName = 'fleet';

  //  Base64URLエンコードのコーデック
  late final _codec = utf8.fuse(base64Url);

  /// 共有リンクが使用可能かどうかを判定する。
  /// (画像要素などが含まれる場合は共有できないため。)
  bool isShareLinkAvailable(List<FleetElement> elements) {
    if (!kIsWeb) return false;

    final hasAnyImageElements = elements.any((e) => e is FleetImageElement);
    final isAvailable = !hasAnyImageElements;

    return isAvailable;
  }

  /// 共有リンクを生成する。
  /// (生成できない場合はnullを返す。)
  String? generate(List<FleetElement> elements) {
    if (!isShareLinkAvailable(elements)) return null;

    //  DTOのJSON文字列に変換する。
    final dto = FleetDto.from(elements);
    final jsonStr = dto.toJsonStr();
    final encodedJsonStr = _codec.encode(jsonStr);

    //  URLを組み立てる。
    //  (参考: https://stackoverflow.com/a/5817559)
    final location = html.window.location;
    final url = location.href.replaceAll(location.search ?? '', '');
    final urlWithQuery = '$url?$_paramName=$encodedJsonStr';

    return urlWithQuery;
  }

  /// ページのクエリパラメタをパースしてFleetのDTOに変換する。
  /// (有効なパラメタが指定されていない場合はnullを返す。)
  FleetDto? parsePageQuery(Uri? uri) {
    //  Uriからパラメタを取得する。
    final param = (uri?.queryParameters ?? const {})[_paramName];
    if (param == null) return null;

    //  パラメタ値文字列をデコードしてDTOに変換する。
    final jsonStr = _codec.decode(param);
    final dto = FleetDto.fromJsonString(jsonStr);

    return dto;
  }
}
