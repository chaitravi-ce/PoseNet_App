// @dart=2.9

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'screens/HomePage.dart';

List<CameraDescription> cameras;

Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error: $e.code\nError Message: $e.message');
  }
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PoseNet detection',
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: HomePage(cameras),
      // routes: {
      //   //Camera.routeName: (ctx) => Camera();
      // },
    );
  }
}


