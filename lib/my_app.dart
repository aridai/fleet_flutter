import 'package:fleet_flutter/my_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = kIsWeb
        ? Theme.of(context)
            .textTheme
            .withFallback(const ['SawarabiGothic', 'NotoColorEmoji'])
        : null;

    return MaterialApp(
      title: 'FleetFlutter',
      theme: ThemeData(primarySwatch: Colors.blue, textTheme: textTheme),
      home: const MyPage(),
    );
  }
}

extension TextThemeEx on TextTheme {
  TextTheme withFallback(List<String>? fallback) {
    return TextTheme(
      headline1: headline1?.copyWith(fontFamilyFallback: fallback),
      headline2: headline2?.copyWith(fontFamilyFallback: fallback),
      headline3: headline3?.copyWith(fontFamilyFallback: fallback),
      headline4: headline4?.copyWith(fontFamilyFallback: fallback),
      headline5: headline5?.copyWith(fontFamilyFallback: fallback),
      headline6: headline6?.copyWith(fontFamilyFallback: fallback),
      subtitle1: subtitle1?.copyWith(fontFamilyFallback: fallback),
      subtitle2: subtitle2?.copyWith(fontFamilyFallback: fallback),
      bodyText1: bodyText1?.copyWith(fontFamilyFallback: fallback),
      bodyText2: bodyText2?.copyWith(fontFamilyFallback: fallback),
      caption: caption?.copyWith(fontFamilyFallback: fallback),
      overline: overline?.copyWith(fontFamilyFallback: fallback),
    );
  }
}
