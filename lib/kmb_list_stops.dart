import 'package:flutter/material.dart';
import 'dart:async' show Future;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'kmb_eta.dart';

Future<ListStops> fetchListStops(String route, String serviceType, String bound) async {
  final response = await http.get(
      "http://search.kmb.hk/KMBWebSite/Function/FunctionRequest.ashx?action=getstops&route=" +
          route +
          "&bound=" +
          bound +
          "&serviceType=" +
          serviceType);

  if (response.statusCode == 200) {
    return ListStops.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load information');
  }
}

class ListStops {
  Data data;

  ListStops({this.data});

  //var amendedData = Data.fromJson(i);

  factory ListStops.fromJson(Map<String, dynamic> json) {
    return new ListStops(
      data: Data.fromJson(json["data"]),
    );
  }
}

class Data {
  BasicInfo basicInfo;
  List<RouteStops> routeStopsList;

  Data({this.routeStopsList, this.basicInfo});

  factory Data.fromJson(Map<String, dynamic> json) {
    var list = json["routeStops"] as List;
    print(list.runtimeType);

    List<RouteStops> amendedList =
        list.map((i) => RouteStops.fromJson(i)).toList();

    return new Data(
      routeStopsList: amendedList,
      basicInfo: BasicInfo.fromJson(json["basicInfo"]),
    );
  }
}

class BasicInfo {
  String destEName;
  String destCName;
  String oriCName;
  String oriEName;

  BasicInfo({this.destCName, this.destEName, this.oriCName, this.oriEName});

  factory BasicInfo.fromJson(Map<String, dynamic> json) {
    return new BasicInfo(
      destCName: json["DestCName"] as String,
      destEName: json["DestEName"] as String,
      oriCName: json["OriCName"] as String,
      oriEName: json["OriEName"] as String,
    );
  }
}

class RouteStops {
  String cName;
  //num y;
  //num eLocation;
  //num x;
  //num airFare; //add this back later
  //String eName;
  //String sCName;
  String serviceType;
  String cLocation;
  String bsiCode;
  String seq;
  //String sCLocation;
  String direction;
  String bound;
  String route;

  RouteStops(
      {this.cName,
      this.cLocation,
      this.bound,
      this.seq,
      this.direction,
      this.route,
      this.serviceType});
  //this.y, this.x, this.airFare,

  RouteStops.fromJson(Map<String, dynamic> json) {
    cName = json["CName"];
    //y = json["Y"];
    //x = json["X"];
    //airFare = json["AirFare"];
    cLocation = json["CLocation"];
    bsiCode = json["BSICode"];
    seq = json["Seq"];
    direction = json["Direction"];
    bound = json["Bound"];
    route = json["Route"];
    serviceType = json["ServiceType"];
  }
}

class KMBListStops extends StatefulWidget {
  final String route;
  final String bound;
  final String serviceType;

  KMBListStops({
    @required this.route,
    @required this.serviceType,
    @required this.bound,
    Key key,
  }) : super(key: key);

  @override
  _KMBListStopsState createState() => _KMBListStopsState();
}

class _KMBListStopsState extends State<KMBListStops> {
  Future<ListStops> _futureListStops;

  @override
  void initState() {
    super.initState();
    _futureListStops = fetchListStops(widget.route, widget.serviceType, widget.bound);
  }

  /*
  Widget _appBarTitle(){
    String oriCName;
    String destCName;
    return Container(
      child: FutureBuilder<ListStops>(
        future: futureListStops,
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            oriCName = snapshot.data.data.basicInfo.oriCName;
            destCName = snapshot.data.data.basicInfo.destCName;
            return Text(widget.route + " " + oriCName + " → " + destCName);
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return LinearProgressIndicator(); 
        }
      ),
    ); 
  }
  */

  Text _removeUnknown(String stop) {
    print(stop);
    if (stop.contains('')) {
      if (stop.contains('深水')) {
        stop.replaceFirst(RegExp(''), '埗');
      } else if (stop.contains('交')) {
        stop.replaceFirst(RegExp(''), '匯');
      } else {
        stop.replaceFirst(RegExp(''), '邨');
      }
    }
    print(stop);
    return Text(stop);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ListStops>(
        future: _futureListStops,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<RouteStops> list = snapshot.data.data.routeStopsList;
            ListView myList = new ListView.builder(
                shrinkWrap: true,
                itemCount: list.length,
                //itemExtent: 25,
                itemBuilder: (context, index) {
                  return Card(
                      child: ExpansionTile(
                    leading: Text(list[index].seq),
                    //title: new Text(list[index].cName,),
                    title: _removeUnknown(list[index].cName),
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 55.0, bottom: 30.0),
                        child: KMBETA(
                          route: list[index].route,
                          bound: list[index].bound,
                          serviceType: list[index].serviceType,
                          stopCode: list[index].bsiCode,
                          seq: list[index].seq,
                        ),
                      )
                    ],
                  ));
                });
            return myList;
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return LinearProgressIndicator(
            backgroundColor: Colors.red,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          );
        });
  }
}
