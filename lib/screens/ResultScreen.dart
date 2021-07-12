// @dart=2.9

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResultScreen extends StatefulWidget {

  final List<Map<String, List<double>>> finalData;

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
    final url = 'https://posenet-6a4c4-default-rtdb.firebaseio.com/Lamborghini';
    final response = await http.get(url);
    final extractedData = json.decode(response.body) as Map<String,dynamic>;
    print(extractedData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Results"),),
      body: Container(
        child: Text(""),
      )
    );
  }
}