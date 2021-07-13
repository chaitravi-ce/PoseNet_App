// @dart=2.9

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'dart:math';

import '../services/Camera.dart';
import './RenderData.dart';

class CameraScreen extends StatefulWidget {

  final List<CameraDescription> cameras;

  const CameraScreen({this.cameras});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {

  List<dynamic> _data;
  int _imageHeight = 0;
  int _imageWidth = 0;
  int x = 1;
  List<dynamic> res = [];

  @override
  void initState() {
    super.initState();
    var res = loadModel();
    print('Model Response: ' + res.toString());
  }
  _setRecognitions(data, imageHeight, imageWidth) {
    if (!mounted) {
      return;
    }
    setState(() {
      _data = data;
      // print("==================================data============================");
      // print(data);
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  loadModel() async {
    return await Tflite.loadModel(model: "assets/posenet_mv1_075_float_from_checkpoints.tflite");
  }


  @override
  Widget build(BuildContext context) {

    Size screen = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(title: Text("Cam View"),),
      body: Stack(
        children: <Widget>[
          Camera(
            cameras: widget.cameras,
            setRecognitions: _setRecognitions,
          ),
          RenderData(
            data: _data == null ? [] : _data,
            previewH: max(_imageHeight, _imageWidth),
            previewW: min(_imageHeight, _imageWidth),
            screenH: screen.height,
            screenW: screen.width,
            res: res
          ),
        ],
      ),
    );
  }
}