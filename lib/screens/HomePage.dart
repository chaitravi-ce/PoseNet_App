// @dart=2.9

import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:camera/camera.dart';
import 'package:posenet_app/main.dart';
import './CameraScreen.dart';

class HomePage extends StatefulWidget {

  final List<CameraDescription> cameras;

  HomePage(this.cameras);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pose Estimation"),),
      body: Center(
        child: TextButton(
          child: Text("Tap Me"), 
          onPressed: (){
            print("tap");
            Navigator.push(context, MaterialPageRoute(builder: (context) => CameraScreen(cameras: cameras,)));
          },
        ),
      )
    );
  }
}