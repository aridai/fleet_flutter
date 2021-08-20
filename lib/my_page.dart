import 'package:flutter/material.dart';

class MyPage extends StatelessWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FleetFlutter')),
      body: const Center(
        child: Text('Hello World!'),
      ),
    );
  }
}
