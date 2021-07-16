// @dart=2.9

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:posenet_app/screens/ResultScreen.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;
import 'package:video_player/video_player.dart';

typedef void Callback(List<dynamic> list, int h, int w);

class Camera extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Callback setRecognitions;

  Camera({this.cameras, this.setRecognitions});

  @override
  _CameraState createState() => new _CameraState();
}

class _CameraState extends State<Camera> {

  VideoPlayerController _videoPlayerController;
  Future<void> _initializeVideo;
  CameraController controller;
  bool isDetecting = false;
  final List<dynamic> finalR = [];

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.asset(
      "assets/LamberginiVideo.mp4"
    );
    _initializeVideo = _videoPlayerController.initialize();
    _videoPlayerController.setLooping(true);
    _videoPlayerController.setVolume(1.0);
    if (widget.cameras == null || widget.cameras.length < 1) {
      print('No camera is found');
    } else {
      controller = new CameraController(
        widget.cameras[1],
        ResolutionPreset.high,
      );
      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});

        controller.startImageStream((CameraImage img) {
          if (!isDetecting) {
            isDetecting = true;

            int startTime = new DateTime.now().millisecondsSinceEpoch;

            Tflite.runPoseNetOnFrame(
              bytesList: img.planes.map((plane) {
                return plane.bytes;
              }).toList(),
              imageHeight: img.height,
              imageWidth: img.width,
              //numResults: 2,
              numResults: 1,
              rotation: -90,
              threshold: 0.1,
              nmsRadius: 10,
            ).then((recognitions) {
              int endTime = new DateTime.now().millisecondsSinceEpoch;
              print("Detection took ${endTime - startTime}");

              widget.setRecognitions(recognitions, img.height, img.width);
              //print(recognitions);
              if(recognitions!=null){
                finalR.add(recognitions);
              }
              //print(finalR);
              isDetecting = false;
            });
          }
        });
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unnecessary_null_comparison
    if (controller == null || !controller.value.isInitialized) {
      return Container();
    }

    var tmp = MediaQuery.of(context).size;
    var screenH = math.max(tmp.height, tmp.width);
    var screenW = math.min(tmp.height, tmp.width);
    tmp = controller.value.previewSize;
    var previewH = math.max(tmp.height, tmp.width);
    var previewW = math.min(tmp.height, tmp.width);
    var screenRatio = screenH / screenW;
    var previewRatio = previewH / previewW;
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;

    return Stack(
      children: [
        Column(
          children: [
            Stack(
              children: [
                Container(
                  height: size.height*0.4,
                  child: FutureBuilder(
                    future: _initializeVideo,
                    // ignore: missing_return
                    builder: (context, snapshot){
                      if(snapshot.connectionState == ConnectionState.done){
                        return AspectRatio(
                          aspectRatio: _videoPlayerController.value.aspectRatio,
                          child: VideoPlayer(_videoPlayerController),
                        );
                      }else{
                        return Container(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                ),
                Container(
                  child: Column(
                    children: [
                      SizedBox(height: size.height*0.25,),
                      FloatingActionButton(
                        onPressed: () {
                          setState(() {
                            if (_videoPlayerController.value.isPlaying) {
                              _videoPlayerController.pause();
                            } else {
                              _videoPlayerController.play();
                            }
                          });
                        },
                        backgroundColor: Colors.black,
                        child: Icon(_videoPlayerController.value.isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              height: size.height*0.5,
              child: Transform.scale(
                scale: controller.value.aspectRatio / deviceRatio,
                child: OverflowBox(
                  maxHeight:
                      screenRatio > previewRatio ? screenH / 1.8 : screenW / 1.8 * previewW * previewH,
                  maxWidth:
                      screenRatio > previewRatio ? screenH / previewH * previewW : screenW,
                  child: CameraPreview(controller),
                ),
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.bottomCenter,
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
                    print(finalR.length);
                    print(finalR);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => ResultScreen(finalData: finalR))
                    );
                  },
                  child: const Text('Get Results'),
                ),
              ]
            )
          )
        )
      ],
    );
  }
}