// @dart=2.9

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TestScreen extends StatefulWidget {

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {

  void getResults()async{
    final url = 'https://posenet-6a4c4-default-rtdb.firebaseio.com/Lamborghini';
    final response = await http.get(url);
    print(response);
    final data = json.encode(response.body);
    final extractedData = json.decode(data);
    print(extractedData);
  }

  @override
  void initState() {
    getResults();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Test"),),
    );
  }
}