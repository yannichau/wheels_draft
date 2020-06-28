import 'dart:async' show Future;
import 'dart:convert';
//import 'package:flutter/services.dart' show rootBundle;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<NWFBStopAPI> fetchListStops(String stopID) async {
  String link = "https://rt.data.gov.hk/v1/transport/citybus-nwfb/stop/" + stopID;
  print(link);
  final response = await http.get(link);

  var jsonresponse = json.decode(response.body);
  if (response.statusCode == 200) {
    print("getting response");
    return NWFBStopAPI.fromJson(jsonresponse);
  } else {
    throw Exception('Failed to load information');
  }
}

class NWFBStopAPI {
  //String type;
  //String version;
  //String genTimeStamp;
  NWFBStopData data;

  NWFBStopAPI ({this.data});

  factory NWFBStopAPI.fromJson(Map<String,dynamic> json) {
    return new NWFBStopAPI(
      data: NWFBStopData.fromJson(json["data"]),
    );
  }
}

class NWFBStopData {
  //String stopID;
  String nameEN;
  String nameTC;
  //num lat; 
  //num long;
  //String dataTimeStamp;

  NWFBStopData.fromJson(Map<String, dynamic> json) {
    nameEN = json["name_en"];
    nameTC = json["name_tc"];
  }

}

class NWFBStop extends StatefulWidget {
  final String stopID;
  NWFBStop({ this.stopID, Key key,}): super(key: key);

  @override
  _NWFBStopState createState() => _NWFBStopState();
}

class _NWFBStopState extends State<NWFBStop> with AutomaticKeepAliveClientMixin{

  Future<NWFBStopAPI> futureNWFBStopAPI;

  @override
  void initState() {
    super.initState();
    futureNWFBStopAPI = fetchListStops(widget.stopID);
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder<NWFBStopAPI> (
      future: futureNWFBStopAPI,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
            String stopNameTC = snapshot.data.data.nameTC;
            return Text(stopNameTC);
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return Container();
      },
    );
  }

  @override
  bool get wantKeepAlive => true;

}