import 'package:fleet_flutter/my_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FleetFlutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: kIsWeb ? 'KosugiMaru' : null,
      ),
      home: const MyPage(),
    );
  }
}
