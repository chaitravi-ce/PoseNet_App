// @dart=2.9

import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:camera/camera.dart';
import 'package:posenet_app/main.dart';
import 'package:posenet_app/screens/TestScreen.dart';
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
        child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[
                          Colors.black,
                          Colors.black54,
                          Colors.black12
                        ],
                      ),
                    ),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 18),
                    primary: Colors.white,
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CameraScreen(cameras: cameras,)));
                  },
                  child: const Text('Tap to open Camera'),
                ),
              ]
            )
          )
            // TextButton(
            //   child: Text("Tap to Open Camera"), 
            //   onPressed: (){
            //     print("tap");
            //     Navigator.push(context, MaterialPageRoute(builder: (context) => CameraScreen(cameras: cameras,)));
            //   },
            // ),
      )
    );
  }
}