//import 'all_route_index.dart';
import 'package:flutter/material.dart';
//import 'dart:async' show Future;
//import 'dart:convert';
//import 'package:http/http.dart' as http;
import 'kmb_eta.dart';
import 'kmb_list_stops_model.dart';
import 'main_fav_model.dart';

///////// DATABASE PACKAGES /////////
//import 'dart:io';
//import 'package:path_provider/path_provider.dart';
//import 'package:path/path.dart';
//import 'package:localstorage/localstorage.dart';

class KMBListStops extends StatefulWidget {
  final String route;
  final String bound;
  final String serviceType;
  final bool islwb;

  KMBListStops({
    @required this.route,
    @required this.serviceType,
    @required this.bound,
    @required this.islwb,
    Key key,
  }) : super(key: key);

  final GlobalKey<ScaffoldState> _scaffoldKey =
      new GlobalKey<ScaffoldState>(); //WARNING

  @override
  _KMBListStopsState createState() => _KMBListStopsState();
}

class _KMBListStopsState extends State<KMBListStops>
    with AutomaticKeepAliveClientMixin {
  ///////// STORAGE FIR ROUTES//////////
  ListStops kmbLS;
  KMBLSService kmbLSService = KMBLSService();
  Exception e;

  void _loadKMBLS(String route, String serviceType, String bound) async {
    print(
        "route:" + route + ", serviceType:" + serviceType + ", bound:" + bound);
    try {
      ListStops thekmbLS =
          await kmbLSService.getKMBLS(route, serviceType, bound);
      setState(() {
        kmbLS = thekmbLS;
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
    _loadKMBLS(widget.route, widget.serviceType, widget.bound);
  }

  Text _removeUnknown(String stop) {
    //TODO: Not working!
    //print(stop);
    // '埗' '匯' '邨'
    var estate = '\ue473';
    if (stop.contains(estate)) {
      //print("wow");
      stop.replaceAll("\ue473", '邨');
    }
    //print(stop);
    return Text(stop);
  }

  String parseOperator() {
    if (widget.islwb) {
      return "lwb";
    }
    return "kmb";
  }

  ///////// DECLARE TEMPORARY LOCAL VARIABLES //////////
  String kmbRoute;
  String kmbBSI;
  String kmbSeq;
  String kmbBound;
  String kmbServiceType;
  String kmbStopCName;
  String kmbStopCLocation;

  @override
  Widget build(BuildContext context) {
    if (kmbLS == null) {
      return LinearProgressIndicator(
        backgroundColor: Colors.red,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
      );
    }
    return ListView.builder(
      key: widget._scaffoldKey,
      itemCount: kmbLS.data.routeStopsList.length,
      itemBuilder: (context, index) {
        // ASSIGN FUTURE VALUES TO VARIABLES
        kmbRoute = kmbLS.data.routeStopsList[index].route;
        kmbBSI = kmbLS.data.routeStopsList[index].bsiCode;
        kmbSeq = kmbLS.data.routeStopsList[index].seq;
        kmbBound = kmbLS.data.routeStopsList[index].bound;
        kmbServiceType = kmbLS.data.routeStopsList[index].serviceType;
        kmbStopCName = kmbLS.data.routeStopsList[index].cName;
        kmbStopCLocation = kmbLS.data.routeStopsList[index].cLocation;

        return Card(
          child: ExpansionTile(
              leading: Text("${index + 1}"),
              title: _removeUnknown(kmbStopCName), // why is this not working?
              subtitle: Text(
                kmbStopCLocation,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 13, 
                ),
              ),
              trailing: new IconButton(
                icon: new Icon(Icons.favorite),
                onPressed: () {
                  return showDialog(
                    context: context,
                    barrierDismissible:
                        false, // user must tap button for close dialog!
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('加到我的最愛？'),
                        content: const Text('你會喺「我的最愛」搵到我。'),
                        actions: <Widget>[
                          FlatButton(
                            child: const Text('取消'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          FlatButton(
                            child: const Text('確認'),
                            onPressed: () {
                              FavStop currentStop = FavStop(
                                id: kmbRoute + 
                                    kmbBound +
                                    kmbLS.data.routeStopsList[index].bsiCode +
                                    kmbServiceType,
                                operatorHK: parseOperator(),
                                route: kmbRoute,
                                bound: kmbBound,
                                seq: kmbLS.data.routeStopsList[index].seq,
                                stopCode: kmbLS.data.routeStopsList[index].bsiCode,
                                cName: kmbLS.data.routeStopsList[index].cName,
                                serviceType: kmbServiceType,
                                oriTC: kmbLS.data.routeStopsList[0].cName,
                                destTC: kmbLS.data.routeStopsList[kmbLS.data.routeStopsList.length-1].cName,
                              );
                              setState(() {
                                DBProvider.db.createFavstop(currentStop);
                              });
                              print(
                                  "added ${kmbLS.data.routeStopsList[index].bsiCode} favourite to database");
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      );
                    },
                  );
                },
              )),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
