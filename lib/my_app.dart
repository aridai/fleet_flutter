import 'package:fleet_flutter/fleet/fleet_page.dart';
import 'package:fleet_flutter/fleet/fleet_page_args.dart';
import 'package:fleet_flutter/share/share_link_generator.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// アプリ
class MyApp extends StatelessWidget {
  const MyApp(this._shareLinkGenerator, {Key? key}) : super(key: key);

  //  使用する同梱フォント名
  static const _fontName = 'KosugiMaru';

  //  共有リンクの生成ロジック
  final ShareLinkGenerator _shareLinkGenerator;

  //  フォントファミリ名
  //  (Web実行時のみ指定)
  String? get _fontFamily => kIsWeb ? _fontName : null;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FleetFlutter',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: _fontFamily),
      onGenerateRoute: _onGenerateRoute,
    );
  }

  //  ルーティングを生成する。
  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    final uri = Uri.tryParse(settings.name ?? '');

    //  ページのURIをパースして、Fleetページのモードを決定する。
    final dto = _shareLinkGenerator.parsePageQuery(uri);
    final args = dto != null
        ? FleetPageArgs.edit(existingElements: dto.toFleetElements())
        : const FleetPageArgs.newly();

    return MaterialPageRoute<void>(
      builder: (context) => FleetPage(args: args),
    );
  }
}
