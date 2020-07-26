import 'package:flutter/material.dart';
import 'package:wheels_draft/kmb_tab_controller.dart';
import 'nwfb_tab_controller.dart';
import 'kmb_list_stops_model.dart';
import 'nwfb_list_stops_model.dart';

import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'dart:core';
//import 'package:url_launcher/url_launcher.dart';

class RouteFile {
  List<AllRoute> allRouteList;

  RouteFile({this.allRouteList});

  factory RouteFile.fromJson(Map<String, dynamic> json) {
    var list = json["routes"] as List;
    print(list.runtimeType);

    List<AllRoute> amendedList = list.map((i) => AllRoute.fromJson(i)).toList();

    return new RouteFile(
      allRouteList: amendedList,
    );
  }
}

class AllRoute {
  String routeNo;
  String oriTC;
  String directionSym;
  String destTC;
  String remarksTC;
  String fareDollar;
  String tagSpecial;
  String operatorHK;
  String routeType;
  String lantauTag;

  AllRoute(
      {this.routeNo,
      this.oriTC,
      this.directionSym,
      this.destTC,
      this.remarksTC,
      this.fareDollar,
      this.routeType,
      this.lantauTag,
      this.operatorHK,
      this.tagSpecial});

  AllRoute.fromJson(Map<String, dynamic> json) {
    routeNo = json["route_no"];
    oriTC = json["ori_tc"];
    directionSym = json["direction"];
    destTC = json["dest_tc"];
    remarksTC = json["remarks_tc"];
    fareDollar = json["fare"];
    tagSpecial = json["tag"];
    operatorHK = json["operator"];
    routeType = json["route_type"];
    lantauTag = json["lantau_tag"];
  }
}

class AllRouteIndex extends StatefulWidget {
  AllRouteIndex({Key key}) : super(key: key);

  @override
  _AllRouteIndexState createState() => _AllRouteIndexState();
}

class _AllRouteIndexState extends State<AllRouteIndex>
    with AutomaticKeepAliveClientMixin {
  //////////DEFINE VARIABLES//////////
  List<AllRoute> _routesForDisplay = List<AllRoute>();
  List<AllRoute> _routesUnfiltered = List<AllRoute>();
  Future<RouteFile> _futureRouteFile;
  static final GlobalKey<ScaffoldState> scaffoldKey =
      new GlobalKey<ScaffoldState>();
  KMBLSService kmbLSService = KMBLSService();
  NWFBLSService nwfblsService = NWFBLSService();

  //////////FUNCTIONS FOR RENDERING EXPANDING LIST TILES//////////
  String _setImage(String operator, String lantauTag) {
    if (operator == "lwb") {
      return 'images/lwb.png';
    } else if (operator == "kmb") {
      return 'images/kmb.png';
    } else if (operator == "nwfb") {
      return 'images/nwfb.jpg';
    } else if (operator == "ctb") {
      return 'images/ctb.png';
    } else if (operator.contains("kmb") && operator.contains("ctb")) {
      return 'images/ctbkmb.png';
    }
    return 'images/kmbnwfb.png';
  }

  Icon _setTagIcon(String tag, String lantauTag) {
    if (lantauTag == "airport") {
      return Icon(
        Icons.flight_takeoff,
      );
    } else if (tag == "peak") {
      return Icon(Icons.directions_run);
    } else if (tag == "special") {
      return Icon(Icons.priority_high);
    } else if (tag == "racecourse") {
      return Icon(Icons.monetization_on);
    } else if (tag == "night") {
      return Icon(
        Icons.brightness_2,
        color: Colors.deepPurple,
      );
    } else if (tag == "border") {
      return Icon(Icons.leak_remove);
    } else if (tag == "school") {
      return Icon(Icons.school);
    } else if (tag == "hst") {
      return Icon(Icons.train);
    }
    return null;
  }

  String _setSubtitle(String remarks) {
    if (remarks != null) {
      return remarks;
    }
    return "";
  }

  void _returnStops(String route, String serviceType, String bound,
      String operator, String oriTC, String destTC, bool isCircular) {
    String operatorMod;
    if (operator.contains("ctb")) {
      operatorMod = "ctb";
    } else {
      operatorMod = "nwfb";
    }
    if (operator == "kmb") {
      setState(() {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => KMBTabs(
                    route: route,
                    serviceType: serviceType,
                    bound: bound,
                    oriTC: oriTC,
                    destTC: destTC,
                    isSearching: _isSearching,
                    isCircular: isCircular,
                    islwb: false,
                  )),
        );
      });
    } else if (operator == "lwb") {
      setState(() {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => KMBTabs(
                  route: route,
                  serviceType: serviceType,
                  bound: bound,
                  oriTC: oriTC,
                  destTC: destTC,
                  isSearching: _isSearching,
                  isCircular: isCircular,
                  islwb: true)),
        );
      });
    } else if (operator == "ctb" || operator == "nwfb") {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NWFBTabs(
                  route: route,
                  bound: bound,
                  oriTC: oriTC,
                  destTC: destTC,
                  operatorHK: operatorMod,
                  isSearching: _isSearching,
                )),
      );
    } else {
      //jointly operated services
      setState(() {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => NWFBTabs(
                    route: route,
                    bound: bound,
                    oriTC: oriTC,
                    destTC: destTC,
                    operatorHK: operatorMod,
                    isSearching: _isSearching,
                  )),
        );
      });
    }
  }

///////////FOR SEARCH QUERIES//////////

  _buildSearchBar() {
    return TextField(
      showCursor: true,
      keyboardType: TextInputType.visiblePassword,
      cursorColor: Colors.teal,
      autofocus: true,
      style: const TextStyle(color: Colors.white, fontSize: 20.0),
      decoration: InputDecoration(
        //labelText: "尋找路線",
        hintText: "尋找路線",
        hintStyle: const TextStyle(color: Colors.white30),
        border: InputBorder.none,
        //prefixIcon: Icon(Icons.search),
        //border: OutlineInputBorder(
        //    borderRadius: BorderRadius.all(Radius.circular(0.0)))
      ),
      onChanged: (text) {
        text = text.toUpperCase();
        setState(() {
          _routesForDisplay = _routesUnfiltered.where((note) {
            var routeNumber = note.routeNo.toUpperCase();
            return routeNumber.startsWith(text);
          }).toList();
        });
      },
    );
  }

  void _startSearch() {
    print("open search box");

    ModalRoute.of(context)
        .addLocalHistoryEntry(new LocalHistoryEntry(onRemove: _stopSearching));

    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearching() {
    setState(() {
      _isSearching = false;
      _routesForDisplay = _routesUnfiltered;
    });
  }

  _buildActions() {
    /*
    if (_isSearching) {
      return <Widget>[
        new IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () { //TODO:
          },
        ),
      ];
    }
    */

    if (!_isSearching) {
      return <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: new IconButton(
            icon: const Icon(Icons.search),
            onPressed: _startSearch,
          ),
        ),
      ];
    }
  }

  _buildTitle() {
    return new InkWell(
      onTap: () => scaffoldKey.currentState.openDrawer(),
      child: new Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("路線搜尋"),
          ],
        ),
      ),
    );
  }

  Future<String> _loadRouteAsset() async {
    return await rootBundle.loadString('assets/all_routes.json');
  }

  Future<RouteFile> _loadRouteList() async {
    String jsonString = await _loadRouteAsset();
    final jsonResponse = json.decode(jsonString);
    RouteFile routeFile = new RouteFile.fromJson(jsonResponse);
    print("route file");
    print(routeFile);
    setState(() {
      _routesForDisplay = routeFile.allRouteList;
      this._routesUnfiltered = _routesForDisplay;
    });
    return routeFile;
  }

  //////////MAIN//////////
  @override
  void initState() {
    super.initState();
    _futureRouteFile = _loadRouteList();
  }

  bool _isSearching = false;

  //Identifyinh routes with multiple serviceTypeS
  String prevRoute = "kmb";
  String currentRoute;
  String prevOp = "1";
  String currentOp;
  num serviceType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        leading: _isSearching ? const BackButton() : null,
        title: _isSearching ? _buildSearchBar() : _buildTitle(),
        actions: _buildActions(),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.teal,
          child: Icon(Icons.refresh),
          onPressed: () {
            return showDialog(
              context: context,
              barrierDismissible:
                  false, // user must tap button for close dialog!
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('更新所有路線？'),
                  content: const Text('這會刪除所有已下載的路線。如果你現在沒有網絡，將無法載入任何新路線。'),
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
                        setState(() {
                          kmbLSService.deleteKMBLS();
                          nwfblsService.deleteNWFBLS();
                        });
                        Navigator.of(context).pop();
                        return showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                  title: Text("已更新路線！"),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: const Text('好'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ]);
                            });
                      },
                    )
                  ],
                );
              },
            );
          }),
      body: FutureBuilder<RouteFile>(
          future: _futureRouteFile,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              //_routesForDisplay = snapshot.data.allRouteList;
              //_routes = _routesForDisplay;
              ListView myList = new ListView.builder(
                shrinkWrap: true,
                itemCount: _routesForDisplay.length, // + 1,
                itemBuilder: (context, index) {
                  currentRoute = _routesForDisplay[index].routeNo;
                  currentOp = _routesForDisplay[index].operatorHK;
                  print("operator: " + prevOp + currentOp);
                  ////////// FIX SPECIAL ROUTES LATER //////////TODO:
                  if (currentRoute == prevRoute && currentOp == prevOp) {
                    print("servicetype incremented");
                    serviceType += 1;
                  } else {
                    serviceType = 1;
                  }
                  print("route: " + currentRoute);
                  print("serviceType: " + "${serviceType}");
                  prevRoute = currentRoute;
                  prevOp = currentOp;

                  return _listItem(index); // - 1);
                },
              );
              return myList;
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return LinearProgressIndicator(
              backgroundColor: Colors.teal,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.teal[50]),
            );
          }),
    );
  }

  Card _listItem(index) {
    return Card(
      child: ExpansionTile(
        leading: Container(
          width: 60,
          child: Column(
            children: [
              Image(
                image: new AssetImage(_setImage(
                    _routesForDisplay[index].operatorHK,
                    _routesForDisplay[index].lantauTag)),
                height: 25,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(_routesForDisplay[index].routeNo,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    )),
              )
            ],
          ),
        ),
        title: Text(
          _routesForDisplay[index].oriTC +
              " " +
              _routesForDisplay[index].directionSym +
              " " +
              _routesForDisplay[index].destTC,
        ),
        subtitle: Text(_setSubtitle(_routesForDisplay[index].remarksTC),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            )),
        children: <Widget>[
          Text("車費: " + _routesForDisplay[index].fareDollar),
          Align(
              child: Column(children: [
            _availableDestinations(
              _routesForDisplay[index].routeType,
              _routesForDisplay[index].oriTC,
              _routesForDisplay[index].destTC,
              _routesForDisplay[index].directionSym,
              serviceType,
              _routesForDisplay[index].routeNo,
              _routesForDisplay[index].operatorHK,
            )
          ])),
        ],
        trailing: _setTagIcon(_routesForDisplay[index].tagSpecial,
            _routesForDisplay[index].lantauTag),
      ),
    );
  }

  Column _availableDestinations(String type, String org, String dest,
      String direction, num serviceType, String route, String operator) {
    bool isCircular = false;
    if (direction == "↺") {
      isCircular = true;
    }
    print("type: " + type);

    if (type == "one_way" || type == "circular") {
      return Column(children: [
        OutlineButton(
          child: Text(org + " " + direction + " " + dest),
          onPressed: () => _returnStops(
              route, "${serviceType}", "1", operator, org, dest, isCircular),
        ),
      ]);
    } else if (type == "bidirectional") {
      print("Expanded for a bidirectional route");
      return Column(children: [
        OutlineButton(
          child: Text(org + " → " + dest),
          onPressed: () => _returnStops(
              route, "${serviceType}", "1", operator, org, dest, isCircular),
        ),
        OutlineButton(
          child: Text(dest + " → " + org),
          onPressed: () => _returnStops(route, "${serviceType}", "2", operator,
              dest, org, isCircular), //reversed direction here
        ),
      ]);
    }
    return Column();
  }

  @override
  bool get wantKeepAlive => true;
}
