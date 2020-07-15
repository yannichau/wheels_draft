import 'dart:async' show Future;
import 'dart:convert';
//import 'package:flutter/services.dart' show rootBundle;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<NWFBETAAPI> fetchNWFBETA(String operatorHK, String stopID, String route) async {
  String link = "https://rt.data.gov.hk/v1/transport/citybus-nwfb/eta/" + operatorHK + "/" + stopID + "/" + route;
  print(link);
  final response = await http.get(link);

  var jsonresponse = json.decode(response.body);
  if (response.statusCode == 200) {
    print("getting response");
    return NWFBETAAPI.fromJson(jsonresponse);
  } else {
    throw Exception('Failed to load information');
  }
}

class NWFBETAAPI {
  //String type;
  //String version;
  //String genTimeStamp;
  List<NWFBETAData> data;
  NWFBETAAPI({this.data});

  factory NWFBETAAPI.fromJson(Map<String, dynamic> json) {
    print("start API");
    var list = json["data"] as List;
    print(list.runtimeType);

    List<NWFBETAData> amendedList = list.map((i) =>
      NWFBETAData.fromJson(i)). toList();

    return new NWFBETAAPI(
      data: amendedList,
    );
  }
}

class NWFBETAData {
  //String co;
  //String route;
  //String dir;
  //num seq;
  //String stopID;
  //String destTC;
  //STring destEN;
  String eta;
  String remarkTC;
  num etaSeq;
  //String remarkTC;
  //String dataTimeStamp;

  NWFBETAData({this.eta, this.remarkTC, this.etaSeq});

  NWFBETAData.fromJson(Map<String, dynamic> json) {
    eta = json["eta"];
    remarkTC = json["rmk_tc"];
    etaSeq = json["eta_seq"];
  }

}

class NWFBETA extends StatefulWidget {
  final String operatorHK;
  final String stopID;
  final String route;

  NWFBETA({ this.operatorHK, this.stopID, this.route, Key key,}): super(key: key);

  @override
  _NWFBETAState createState() => _NWFBETAState();
}

class _NWFBETAState extends State<NWFBETA> {

  Future<NWFBETAAPI> futureNWFBETAAPI;

  @override
  void initState() {
    super.initState();
    futureNWFBETAAPI = fetchNWFBETA(widget.operatorHK, widget.stopID, widget.route);
  }

  Text _etaMod(String eta) {
    return Text(eta.substring(11,16));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder<NWFBETAAPI>(
            future: futureNWFBETAAPI,
            builder: (context, snapshot) {
  
              if (snapshot.hasData) {
                  List<NWFBETAData> list = snapshot.data.data;
                    ListView myList = new ListView.builder(
                      shrinkWrap: true,
                      itemCount: list.length,
                      itemExtent: 25,
                      itemBuilder: (context, index) {
                      return new ListTile(
                        leading: Icon(Icons.departure_board),
                        title: _etaMod(list[index].eta),
                      );
                    });
                    return myList;
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              return Padding(
                padding: const EdgeInsets.only(right:55.0),
                child: LinearProgressIndicator(
                  backgroundColor: Colors.orange,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              );
            }
        )
      ]
    );
  }
}