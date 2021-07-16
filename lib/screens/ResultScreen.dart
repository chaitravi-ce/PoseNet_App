// @dart=2.9

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';
import 'package:ml_linalg/vector.dart';
import 'package:ml_linalg/distance.dart';
import 'package:progress_indicators/progress_indicators.dart';

class ResultScreen extends StatefulWidget {

  final List<dynamic> finalData;

  const ResultScreen({this.finalData});

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {

  bool _isLoading = false;
  var fireData = [];
  int score = 0;

  @override
  void initState() {
    super.initState();
    print(widget.finalData.length);
    getFirebaseData().then((data){
      fireData = data;
    });
  }

  Future<dynamic> getFirebaseData()async{
    _isLoading = true;
    final List<List<List<dynamic>>> finalD = [];
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
            final Map<int, dynamic> mapF = {};
            final List<List<dynamic>> ls = []; 
            for(var item in v){
              var i = item.split(" ");
              if(i.length >1){
                double i3 = double.parse(i[3])/336;
                double i5 = double.parse(i[5])/336;
                ls.add([i[1], i3, i5]);
                //mapF[i[1]] = [i[3], i[5]];
              }
            }
            //print(mapF);
            finalD.add(ls);
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
      fireData = finalD;
      //print(values[keys]);
      getResults();
    });
    return finalD;

  }

  void getResults(){
    var camData = widget.finalData;
    var tmp2 = fireData;
    print(fireData.length);
    int c = 0;
    int min = 0;
    print(camData.length);
    if(fireData.length < camData.length){
      min = fireData.length;
    }else{
      min = camData.length;
    }
    if(c < min){
      for(var item in camData){
        c++;
        var temp = item[0]['keypoints'];
        //print(temp.runtimeType);
        //print(item[0]['keypoints'][15]);
        List<double> ls1 = [temp[5]['x'], temp[5]['y'], temp[6]['x'], temp[6]['y'], temp[7]['x'], temp[7]['y'],
          temp[8]['x'], temp[8]['y'], temp[9]['x'], temp[9]['y'], temp[10]['x'], temp[10]['y'], temp[11]['x'], 
          temp[11]['y'], temp[12]['x'], temp[12]['y'], temp[13]['x'], temp[13]['y'], temp[14]['x'], temp[14]['y']];
        List<double> ls2 = [tmp2[c][5][1], tmp2[c][5][2], tmp2[c][6][1], tmp2[c][6][2], tmp2[c][7][1], tmp2[c][7][2],
          tmp2[c][8][1], tmp2[c][8][2], tmp2[c][9][1], tmp2[c][9][2], tmp2[c][10][1], tmp2[c][10][2], 
          tmp2[c][11][1], tmp2[c][11][2], tmp2[c][12][1], tmp2[c][12][2], tmp2[c][13][1], tmp2[c][13][2], tmp2[c][14][1], 
          tmp2[c][14][2]];
        print(ls1);
        print(ls2);
        print(c);
        final vector1 = Vector.fromList(ls1);
        final vector2 = Vector.fromList(ls2);
        final result = vector1.distanceTo(vector2, distance: Distance.cosine);
        final cosineSim = 1 - result;
        print(cosineSim);
        if(cosineSim > 0.8){
          score++;
        }
      }
      setState(() {
        _isLoading = false;
      });
      print("==================");
      print(score);
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Results"),),
      body: _isLoading ? 
      Center(child: JumpingDotsProgressIndicator(fontSize: 40, color: Colors.white,)) 
      : Center(
        child: Container(
          child: Text("Your Score is ${score}",
            style: TextStyle(fontSize: 20),
          ),
        ),
      )
    );
  }
}