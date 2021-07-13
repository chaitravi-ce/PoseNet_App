// @dart=2.9

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class TestScreen extends StatefulWidget {

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {

  void getResults(){

    final List<Map<String, dynamic>> finalD = [];
    DatabaseReference refData = FirebaseDatabase.instance.reference().child("posenet-6a4c4-default-rtdb").child("Lamborghini");

    refData.once().then((DataSnapshot dataSnapshot){

      print(dataSnapshot.value);
      var keys = dataSnapshot.value.keys;
      var values = dataSnapshot.value;
      print(keys);
      for(var key in keys){
        var t = values[key]["Lambergini"];
        //print(t);
        t = json.decode(t);
        final regExp = new RegExp(r'(?:\[)?(\[[^\]]*?\](?:,?))(?:\])?');
        final input = t;
        final result = regExp.allMatches(input).map((m) => m.group(1))
          .map((String item) => item.replaceAll(new RegExp(r'[\[\],]'), ''))
          .map((m) => [m])
          .toList();
        print(result.runtimeType);
        for(var frames in result){
          for(var res in frames){
            var v = res.split("{");
            final Map<String, dynamic> mapF = {};
            for(var item in v){
              var i = item.split(" ");
              if(i.length >1){
                mapF[i[1]] = [i[3], i[5]];
              }
            }
            //print(mapF);
            finalD.add(mapF);
            print(finalD.length);
            // var finalRes = res.split(" ");
            // print(finalRes);
            // for(var item in finalRes){
            //   print(item);
            // }
          }
        }
      }
      //var values = dataSnapshot.value;

      //print(values[keys]);
      print("================================End");
      print(finalD);
      return finalD;
    });
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
      body: TextButton(
        child: Text("Test"),
        onPressed: (){
          getResults();
        },
      )
    );
  }
}