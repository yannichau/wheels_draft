import 'dart:async' show Future;
import 'dart:convert';
//import 'package:flutter/services.dart' show rootBundle;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<ETA> fetchETA(String route, String bound, String serviceType, String stopCode, String seq) async {
  print("route: " + route);
  print("bound: " + bound);
  print("serviceType: " + serviceType);
  print("stopcode: " + stopCode);
  print("seq: " + seq);
  print('http://etav3.kmb.hk/?action=geteta&lang=tc&route=' + route + '&bound=' + bound + '&stop='+ stopCode +'&stop_seq=' + seq);

  final response =
      await http.get('http://etav3.kmb.hk/?action=geteta&lang=tc&route=' + route + '&bound=' + bound + '&stop='+ stopCode +'&stop_seq=' + seq);

  if (response.statusCode == 200) {
    return ETA.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load ETA');
  }
}

class ETA {
  //int responseCode;
  List<Response> responses;
  //num updatedTime;
  //num generatedTime;

  ETA({this.responses});
  //this.responseCode, this.updatedTime, this.generatedTime,

  factory ETA.fromJson(Map<String,dynamic> json) {

    var list = json["response"] as List;
    print(list.runtimeType);

    List <Response> responseList = list.map((i) =>
      Response.fromJson(i)). toList();

    //print(responseList[0]);
    //print(responseList[1]);

    if ( json["response"] != null) {
    }

    return new ETA(
      //responseCode: json["responsecode"] as int,
      //updatedTime: json["updated"] as num,
      //generatedTime: json["generated"],
      responses: responseList,
      );
      
      /*
      if ( json["response"] != null) {
        responses = new List<Response>();
        json['response'].forEach((v) {
          responses.add(new Response.fromJson(v));
        });
      }
       */
    
  }

}

class Response {
  //String w;
  //String ex;
  //String eot;
  String t;
  //String ei;
  //num busServiceType; //num might be causing the issues here.
  //String wifi;
  //String ol;
  //String dis;

  Response({this.t,});
  //this.ei, this.busServiceType, this.wifi, this.ol, this.dis,this.w, this.ex, this.eot,

  Response.fromJson(Map<String, dynamic> json) {
    //w = json["w"];
    //ex = json["ex"];
    //eot = json["eot"];
    t = json["t"];
    //ei = json["Y"];
    //busServiceType = json["bus_service_type"];
    //wifi = json["wifi"];
    //ol = json["ol"];
    //dis = json["dis"];
  }
    
}

class KMBETA extends StatefulWidget {

  final String route;
  final String bound;
  final String serviceType;
  final String stopCode;
  final String seq;
  
  KMBETA({
    Key key, 
    @required this.stopCode, 
    @required this.seq, 
    @required this.route, 
    @required this.bound, 
    @required this.serviceType
  }): super(key: key);
  
  @override
  _KMBETAState createState() => _KMBETAState();
}

class _KMBETAState extends State<KMBETA> {
  Future<ETA> futureETA;

  @override
  void initState() {
    super.initState();
    print(widget.route);
    print(widget.bound);
    print(widget.serviceType);
    print(widget.stopCode);
    print(widget.seq);
    futureETA = fetchETA(widget.route, widget.bound, widget.serviceType, widget.stopCode, widget.seq);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder<ETA>(
            future: futureETA,
            builder: (context, snapshot) {
  
              if (snapshot.hasData) {
                  List<Response> list = snapshot.data.responses;
                    ListView myList = new ListView.builder(
                      shrinkWrap: true,
                      itemCount: list.length,
                      itemExtent: 25,
                      itemBuilder: (context, index) {
                      return new ListTile(
                        leading: Icon(Icons.departure_board),
                        title: new Text(
                          list[index].t,
                      ),
                      );
                    });
                    return myList;
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              return Padding(
                padding: const EdgeInsets.only(right:55.0),
                child: LinearProgressIndicator(
                  backgroundColor: Colors.red,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
              );
            }
        )
      ]
    );
  }
  
                  /*

                String eta1Time = responseList[0].t;
                String eta2Time = responseList[1].t;
                String eta3Time = responseList[2].t;

                return Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      Text(eta1Time),
                      Text(eta2Time),
                      Text(eta3Time),
                    ],

                    */

}