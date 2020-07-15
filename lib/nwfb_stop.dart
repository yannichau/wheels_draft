import 'dart:async' show Future;
import 'dart:convert';
import 'package:localstorage/localstorage.dart';
//import 'package:flutter/services.dart' show rootBundle;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NWFBStopService {
  static LocalStorage storage = new LocalStorage("nwfbStops");
  //var stopwatch = new Stopwatch()..start();

  void saveNWFBStops(String stopID, NWFBStopAPI nwfbStop) async {
    await storage.ready;
    storage.setItem("nwfbstop"+stopID, nwfbStop);
    print("saved item as " + "nwfbstop"+stopID);
  }

  Future<NWFBStopAPI> getNWFBStops(String stopID) async {
    NWFBStopAPI nwfbStop = await getNWFBStopsFromCache(stopID);
    if (nwfbStop == null) {
      nwfbStop = await getNWFBStopsFromAPI(stopID);
    }
    return nwfbStop;
    //how bout trying differentiating the 2 variables?
  }

  Future<NWFBStopAPI> getNWFBStopsFromAPI(String stopID) async {
    print("call from nwfbstop api");
    NWFBStopAPI nwfbStop = await fetchNWFBStopAPI(stopID);
    nwfbStop.fromCache = false;
    //Future.delayed(Duration(milliseconds: 100));
    saveNWFBStops(stopID, nwfbStop);
    return nwfbStop;  
  }

  Future<NWFBStopAPI> getNWFBStopsFromCache(String stopID) async {
    print("call from nwfbstop cache");
    await storage.ready;
    Map <String, dynamic> data = storage.getItem("nwfbstop"+stopID);
    print(data);
    if (data == null) {
      return null;
    }
    NWFBStopAPI nwfbStop = NWFBStopAPI.fromJson(data);
    nwfbStop.fromCache = true;
    print("loaded item as " + "nwfbstop"+stopID);
    return nwfbStop;
  }

  Future<NWFBStopAPI> fetchNWFBStopAPI(String stopID) async {
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
}

class NWFBStopAPI {
  //String type;
  //String version;
  //String genTimeStamp;
  NWFBStopData data;
  bool fromCache;

  NWFBStopAPI ({this.data, this.fromCache});

  factory NWFBStopAPI.fromJson(Map<String,dynamic> json) {
    return new NWFBStopAPI(
      data: NWFBStopData.fromJson(json["data"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "data": data.toJson(),
  };

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

  Map<String, dynamic> toJson() => {
    "name_en": nameEN,
    "name_tc": nameTC,
  };

}

class NWFBStop extends StatefulWidget {
  final String stopID;
  NWFBStop({ this.stopID, Key key,}): super(key: key);
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>(); //WARNING

  @override
  _NWFBStopState createState() => _NWFBStopState();
}

class _NWFBStopState extends State<NWFBStop> with AutomaticKeepAliveClientMixin{


  NWFBStopAPI nwfbStop;
  NWFBStopService service = NWFBStopService();
  Exception e;

  void _loadNWFBStops(String stopID) async {
    print("stopID:" + stopID);
    try {
      NWFBStopAPI thenwfbStop = await service.getNWFBStops(stopID);
      setState(() {
        nwfbStop = thenwfbStop;
      });
    } catch (err) {
      setState(() {
        e = err;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadNWFBStops(widget.stopID);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    if (nwfbStop != null) {
      String stopNameTC = nwfbStop.data.nameTC;
      return Text(
        stopNameTC
      );
    } 
    return Container();
  }



}