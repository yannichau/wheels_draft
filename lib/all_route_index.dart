import 'package:flutter/material.dart';
import 'package:wheels_draft/kmb_tab_controller.dart';
import 'nwfb_tab_controller.dart';
import 'home_drawer.dart';

import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'dart:core';
import 'package:url_launcher/url_launcher.dart';

class RouteFile {
  List<AllRoute> allRouteList;

  RouteFile({this.allRouteList});

  factory RouteFile.fromJson(Map<String, dynamic> json) {
    var list = json["routes"] as List;
    print(list.runtimeType);

    List<AllRoute> amendedList = list.map((i) =>
      AllRoute.fromJson(i)). toList();

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

  AllRoute({this.routeNo,this.oriTC, this.directionSym, this.destTC, this.remarksTC, this.fareDollar, this.routeType, this.lantauTag, this.operatorHK, this.tagSpecial});

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

class _AllRouteIndexState extends State<AllRouteIndex> {
  
  //////////DEFINE VARIABLES//////////
  List<AllRoute> _routesForDisplay = List<AllRoute>();
  List<AllRoute> _routesUnfiltered = List<AllRoute>();
  Future<RouteFile> _futureRouteFile;
  static final GlobalKey<ScaffoldState> scaffoldKey =  new GlobalKey<ScaffoldState>();

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
    } else {
      return 'images/joint.png';
    }
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

  void _returnStops(String route, String serviceType, String bound, String operator, String oriTC, String destTC) {
    print("operator: " + operator);
    if (operator == "kmb" || operator == "lwb") {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => KMBTabs(
                route: route, serviceType: serviceType, bound: bound, oriTC: oriTC, destTC: destTC,)),
      );
    } else if (operator == "ctb" || operator == "nwfb") {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NWFBTabs(
                route: route, bound: bound, oriTC: oriTC, destTC: destTC, operator: operator,
            )
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => KMBTabs(
                route: route, serviceType: serviceType, bound: bound, oriTC: oriTC, destTC: destTC,)),
      );
    }
  }

///////////FOR SEARCH QUERIES//////////
  
  _buildSearchBar() {
    return TextField(
        showCursor: true,
        keyboardType: TextInputType.numberWithOptions(),
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
            _routesForDisplay = _routesUnfiltered.where( (note) { 
                var routeNumber = note.routeNo.toUpperCase();
                return routeNumber.contains(text);
            }).toList();
          });
        },
      );
  }

  void _startSearch() {
    print("open search box");

    ModalRoute
        .of(context)
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
        padding: const EdgeInsets.only(right:8.0),
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
  String prevRoute;
  String currentRoute;
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
      body: FutureBuilder<RouteFile> (
        future: _futureRouteFile,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            //_routesForDisplay = snapshot.data.allRouteList;
            //_routes = _routesForDisplay;
            ListView myList = new ListView.builder(
              shrinkWrap: true,
              itemCount: _routesForDisplay.length,// + 1,
              itemBuilder: (context, index) {
                //return index == 0 ? _buildSearchBar() : 
                return _listItem(index);// - 1);
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
        }
      ),
    );
  }

  _listItem(index) {
    currentRoute = _routesForDisplay[index].routeNo;
    if (currentRoute == prevRoute) {
      serviceType += 1;
    } else {
      serviceType = 1;
    }
    prevRoute = currentRoute;
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
          Align(
              child: Column(children: [
            _availableDestinations(
                _routesForDisplay[index].routeType,
                _routesForDisplay[index].oriTC,
                _routesForDisplay[index].destTC,
                _routesForDisplay[index].directionSym,
                serviceType,
                _routesForDisplay[index].routeNo,
                _routesForDisplay[index].operatorHK,)
          ])),
        ],
        trailing: _setTagIcon(_routesForDisplay[index].tagSpecial,
            _routesForDisplay[index].lantauTag),
      ),
    );
  }

  Column _availableDestinations(String type, String org, String dest, String direction, num serviceType, String route, String operator) {
    print(type);
    print(org);
    print(dest);
    print(direction);
    if (type == "one_way" || type == "circular") {
      return Column(children: [
        OutlineButton(
          child: Text(org + " " + direction + " " + dest),
          onPressed: () => _returnStops(route, "${serviceType}", "1", operator, org, dest),
        ),
      ]);
    } else if (type == "bidirectional") {
      return Column(children: [
        OutlineButton(
          child: Text(org + " → " + dest),
          onPressed: () => _returnStops(route, "${serviceType}", "1", operator, org, dest),
        ),
        OutlineButton(
          child: Text(dest + " → " + org),
          onPressed: () => _returnStops(route, "${serviceType}", "2", operator, org, dest),
        ),
      ]);
    }
    return Column();
  }

  
}
