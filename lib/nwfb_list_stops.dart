import 'package:flutter/material.dart';
import 'dart:async' show Future;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'nwfb_stop.dart';
import 'nwfb_eta.dart';

Future<NWFBAPI> fetchListStops(String route, String bound, String operator) async {
  operator.toUpperCase();
  String boundMod;
  if (bound == '1') {
    boundMod = "outbound";
  } else if (bound == '2') {
    boundMod = "inbound";
  }
  String link = "https://rt.data.gov.hk/v1/transport/citybus-nwfb/route-stop/" + operator + "/" + route + "/" + boundMod;
  print(link);
  final response = await http.get(link);

  var jsonresponse = json.decode(response.body);
  if (response.statusCode == 200) {
    print("get response");
    return NWFBAPI.fromJson(jsonresponse);
  } else {
    throw Exception('Failed to load information');
  }
}

class NWFBAPI {
  List<NWFBRouteStops> routeStopsList;

  NWFBAPI({this.routeStopsList});

  factory NWFBAPI.fromJson(Map<String, dynamic> json) {
    print("start API");
    var list = json["data"] as List;
    print(list.runtimeType);

    List<NWFBRouteStops> amendedList = list.map((i) =>
      NWFBRouteStops.fromJson(i)). toList();

    return new NWFBAPI(
      routeStopsList: amendedList,
    );
  }
}

class NWFBRouteStops {
  String co;
  String route;
  String dir;
  num seq;
  String stop;
  String dataTimeStamp;

  NWFBRouteStops({this.co, this.route, this.dir, this.seq, this.stop, this.dataTimeStamp});

  /*
  factory NWFBRouteStops.fromJson(Map<String, dynamic> json) {
    return new NWFBRouteStops(
      co: json["co"] as String,
      route: json["route"] as String,
      dir: json["dir"] as String,
      seq: json["seq"] as String,
      stop: json["stop"] as String,
      dataTimeStamp: json["data_timestamp"] as String,
    );
  }
  */
  NWFBRouteStops.fromJson(Map<String, dynamic> json) {
    co = json["co"];
    route = json["route"];
    dir = json["dir"];
    seq = json["seq"];
    stop = json["stop"];
    dataTimeStamp = json["data_timestamp"];
  }
}

class NWFBListStops extends StatefulWidget {

  final String route;
  final String bound;
  final String oriTC;
  final String destTC;
  final String operator;

  NWFBListStops({
    @required this.route, 
    @required this.bound, 
    @required this.oriTC,
    @required this.destTC,
    @required this.operator,
    Key key,
  }): super(key: key);

  @override
  _NWFBListStopsState createState() => _NWFBListStopsState();
}

class _NWFBListStopsState extends State<NWFBListStops> {

  Future<NWFBAPI> futureListStops;

  @override
  void initState() {
    super.initState();
    futureListStops = fetchListStops(widget.route, widget.bound, widget.operator);
  }
  
  Widget _listStops() {
    return new FutureBuilder<NWFBAPI>(
            future: futureListStops,
            builder: (context, snapshot) {
            if (snapshot.hasData) {
                print("pre-initialise");
                List<NWFBRouteStops> list = snapshot.data.routeStopsList;
                ListView myList = new ListView.builder(
                  shrinkWrap: true,
                  itemCount: list.length,
                  //itemExtent: 25,
                  itemBuilder: (context, index) {
                    print("stop: " + list[index].stop);
                    return Card (
                      child: ExpansionTile(
                        leading: Text("${list[index].seq}"),
                        title: NWFBStop(stopID: list[index].stop),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left:55.0, bottom: 30.0),
                            child: NWFBETA(
                              route: list[index].route,
                              operator: list[index].co,
                              stopID: list[index].stop,
                            ),
                          )
                        ],
                      )
                    );
                  }
                );
                return myList;
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              return LinearProgressIndicator(
                backgroundColor: Colors.orange,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              );
            }
        );
  }
  
  @override
  Widget build(BuildContext context) {
    return _listStops();
  }
}