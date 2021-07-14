// @dart=2.9

import 'package:flutter/material.dart';
import 'dart:convert';

class ResultScreen extends StatefulWidget {

  final List<dynamic> finalData;

  const ResultScreen({this.finalData});

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    print(widget.finalData.length);
    getResults();
  }

  void getResults()async{
    _isLoading = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Results"),),
      body: TextButton(
        child: Text("Test"),
        onPressed: (){
          var t = widget.finalData;
          for(var item in t){
            print(item[0]['keypoints'][18]);
          }
          // for(var item in widget.finalData){
          //   print(item["nose"]);
          // }
        },
      )
    );
  }
}