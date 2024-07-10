import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sunglass_app/sunglass_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Permission.camera.request();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SunglassPage(),
    );
  }
}
