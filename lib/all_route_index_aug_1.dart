import 'package:flutter/material.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'dart:core';
//import 'package:vector_math/vector_math.dart' show radians;
//import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:wheels_draft/kmb_tab_controller.dart';
import 'nwfb_tab_controller.dart';
import 'kmb_list_stops_model.dart';
import 'nwfb_list_stops_model.dart';
import 'circular_filter_button.dart';

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
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  //////////DEFINE VARIABLES//////////
  List<AllRoute> _routesForDisplay = List<AllRoute>();
  List<AllRoute> _routesUnfiltered = List<AllRoute>();
  List<AllRoute> _routesPrev = List<AllRoute>();
  Future<RouteFile> _futureRouteFile;
  static final GlobalKey<ScaffoldState> scaffoldKey =
      new GlobalKey<ScaffoldState>();
  KMBLSService kmbLSService = KMBLSService();
  NWFBLSService nwfblsService = NWFBLSService();
  int operatorState =
      0; //0 for all, 1 for kmb, 2 for lwb, 3 for nwfb, 4 for nwfb
  bool operatorFilter;

  ////////// ANIMATION VARIABLES //////////
  AnimationController animationController;
  Animation degOneTranslationAnimation;
  Animation rotationAnimation;

  //////////FUNCTIONS FOR RENDERING EXPANDING LIST TILES//////////
  String _setImage(String operator, String lantauTag) {
    if (operator == "lwb") {
      return 'images/lwb.png';
    } else if (operator == "kmb") {
      return 'images/kmb.png';
    } else if (operator == "nwfb") {
      return 'images/nwfb.png';
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

///////////FOR SEARCH QUERIES//////////

  _buildSearchBar() {
    return TextField(
      showCursor: true,
      keyboardType: TextInputType.number,
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
      onChanged: (searchText) {
        searchText = searchText.toUpperCase();
        setState(() {
          if (searchText == "") {
            _routesForDisplay = _routesUnfiltered;
          } else {
            _routesForDisplay = _routesUnfiltered.where((note) {
              //previously _routesUnfiltered here
              var routeNumber = note.routeNo.toUpperCase();
              return routeNumber.contains(searchText);
            }).toList();
            _routesPrev = _routesForDisplay;
          }
        });
      },
    );
  }

  void _startSearch() {
    print("open search box");

    ModalRoute.of(context)
        .addLocalHistoryEntry(new LocalHistoryEntry(onRemove: _stopSearching));

    setState(() {
      _routesPrev = _routesUnfiltered;
      _isSearching = true;
    });
  }

  void _stopSearching() {
    setState(() {
      _isSearching = false;
      _routesPrev = _routesUnfiltered;
      _routesForDisplay = _routesUnfiltered;
      operatorState = 0;
    });
  }

  List<Widget> filterButton(
      String displayName, String containsName, int newOpState) {
    return [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: OutlineButton(
          textColor: Colors.white,
          borderSide: BorderSide(color: Colors.white),
          child: Text(displayName),
          onPressed: () {
            setState(() {
              operatorState = newOpState;
              _routesForDisplay = _routesPrev.where((note) {
                var busOperator = note.operatorHK.toLowerCase();
                return busOperator.contains(containsName);
              }).toList();
            });
          },
        ),
      ),
    ];
  }

  List<Widget> _buildActions() {
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

    if (_isSearching) {
      String dropdownValue;
      return [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: DropdownButton<String>(
            value: dropdownValue,
            icon: Icon(Icons.tune, color: Colors.white),
            iconSize: 24,
            elevation: 16,
            style: TextStyle(color: Colors.indigo),
            focusColor: Colors.white,
            underline: Container(
              height: 0,
              color: Colors.white,
            ),
            onChanged: (String newValue) {
              String newValueEng;
              var tempState;
              if (newValue == '所有') {
                newValueEng = 'all';
                tempState = 0;
              } else if (newValue == '九巴') {
                newValueEng = 'kmb';
                tempState = 1;
              } else if (newValue == '城巴') {
                newValueEng = 'ctb';
                tempState = 2;
              } else if (newValue == '新巴') {
                newValueEng = 'nwfb';
                tempState = 3;
              } else {
                newValueEng = 'lwb'; //fix later
                tempState = 4;
              }
              setState(() {
                operatorState = tempState;
                if (newValueEng == 'all') {
                  _routesForDisplay = _routesPrev;
                } else {
                  _routesForDisplay = _routesPrev.where((note) {
                    var busOperator = note.operatorHK.toLowerCase();
                    return busOperator.contains(newValueEng);
                  }).toList();
                }
              });
            },
            items: <String>[
              '所有',
              '九巴',
              '城巴',
              '新巴',
              '龍運',
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ];
    }
  }

  _buildFilterButton(
      String operatorHK, Color color, double imageHeight, int opState) {
    if (operatorHK == "all") {
      return Container(
        height: 60,
        width: 60,
        child: FloatingActionButton(
            backgroundColor: color,
            shape: CircleBorder(),
            child: Icon(Icons.close, color: Colors.white),
            onPressed: () {
              setState(() {
                _routesForDisplay = _routesPrev;
              });
            }),
      );
    }
    return Container(
      height: 60,
      width: 60,
      child: FloatingActionButton(
        backgroundColor: color,
        child: Image(
          image: new AssetImage(_setImage(operatorHK, "null")),
          height: imageHeight,
        ),
        shape: CircleBorder(),
        onPressed: () {
          setState(() {
            //buttonEnabled = false;
            _routesForDisplay = _routesPrev.where((note) {
              var busOperator = note.operatorHK.toLowerCase();
              return busOperator.contains(operatorHK);
            }).toList();
          });
        },
      ),
    );
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
      this._routesPrev = _routesForDisplay;
    });
    return routeFile;
  }

  Widget refreshList() {
    return IconButton(
        icon: Icon(Icons.refresh),
        onPressed: () {
          return showDialog(
            context: context,
            barrierDismissible: false, // user must tap button for close dialog!
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
        });
  }

  Widget bottomFilterAction() {
    /*
    return Container(
      child: FabCircularMenu(
        ringColor: Colors.teal,
        fabColor: Colors.teal,
        fabOpenIcon: Icon(Icons.tune, color: Colors.white),
        fabMargin: EdgeInsets.all(50),
        fabElevation: 300.0,
        alignment: Alignment.bottomRight,
        children: <Widget>[
        IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              print('Home');
            }),
        IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              print('Favorite');
            })
      ]),
    );
    */
  }

  radToDeg(double degrees) {
    return degrees * 3.141592654 / 180;
  }

  filterRoutes(String operatorHK) {
    var tempState;
    if (operatorHK == 'all') {
      tempState = 0;
    } else if (operatorHK == 'kmb') {
      tempState = 1;
    } else if (operatorHK == 'ctb') {
      tempState = 2;
    } else if (operatorHK == 'nwfb') {
      tempState = 3;
    } else {
      tempState = 4;
    }
    setState(() {
      operatorState = tempState;
      if (operatorHK == 'all') {
        _routesForDisplay = _routesPrev;
      } else {
        _routesForDisplay = _routesPrev.where((note) {
          var busOperator = note.operatorHK.toLowerCase();
          return busOperator.contains(operatorHK);
        }).toList();
      }
    });
  }

  //////////MAIN//////////
  @override
  void initState() {
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    degOneTranslationAnimation =
        Tween(begin: 0.0, end: 1.0).animate(animationController);
    rotationAnimation = Tween(begin: 180.0, end: 0.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeOut));
    super.initState();
    _futureRouteFile = _loadRouteList();
    animationController.addListener(() {
      setState(() {});
    });
  }

  bool _isSearching = false;

  //Identifying routes with multiple serviceTypeS
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
        leading: _isSearching ? const BackButton() : refreshList(),
        title: _isSearching ? _buildSearchBar() : _buildTitle(),
        actions: _buildActions(),
      ),
      floatingActionButton: bottomFilterAction(),
      body: Stack(
        children: [
          /*
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFilterButton("kmb", Colors.white, 18, 1),
                _buildFilterButton("ctb", Colors.white, 25, 2),
                _buildFilterButton("nwfb", Colors.white, 25, 3),
                _buildFilterButton("lwb", Colors.white, 25, 4),
                _buildFilterButton("all", Colors.teal, 25, 0),
              ],
            ),
          ),
          */
          Expanded(
            child: FutureBuilder<RouteFile>(
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
          ),
          /*
          Positioned(
            right: 30,
            bottom: 30,
            child: Stack(
              children: [
                Transform.translate(
                  offset: Offset.fromDirection(
                      radToDeg(180), degOneTranslationAnimation.value * 70),
                  child: Transform(
                    transform:
                        Matrix4.rotationZ(radToDeg(rotationAnimation.value)),
                    alignment: Alignment.center,
                    child: CircularFilterButton(
                      width: 60,
                      height: 60,
                      iconImage: FloatingActionButton(
                        backgroundColor: Colors.brown[100],
                        onPressed: () {filterRoutes("kmb");},
                        child: Image(
                          image: new AssetImage(_setImage("kmb", null)),
                          height: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset.fromDirection(
                      radToDeg(180), degOneTranslationAnimation.value * 140),
                  child: Transform(
                    transform:
                        Matrix4.rotationZ(radToDeg(rotationAnimation.value)),
                    alignment: Alignment.center,
                    child: CircularFilterButton(
                      width: 60,
                      height: 60,
                      iconImage: FloatingActionButton(
                        backgroundColor: Colors.orange[100],
                        onPressed: () {filterRoutes("lwb");},
                        child: Image(
                          image: new AssetImage(_setImage("lwb", null)),
                          height: 25,
                        ),
                      ),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset.fromDirection(
                      radToDeg(270), degOneTranslationAnimation.value * 70),
                  child: Transform(
                    transform:
                        Matrix4.rotationZ(radToDeg(rotationAnimation.value)),
                    alignment: Alignment.center,
                    child: CircularFilterButton(
                      width: 60,
                      height: 60,
                      iconImage: FloatingActionButton(
                        backgroundColor: Colors.yellow[400],
                        onPressed: () {filterRoutes("ctb");},
                        child: Image(
                          image: new AssetImage(_setImage("ctb", null)),
                          height: 25,
                        ),
                      ),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset.fromDirection(
                      radToDeg(270), degOneTranslationAnimation.value * 140),
                  child: Transform(
                    transform:
                        Matrix4.rotationZ(radToDeg(rotationAnimation.value)),
                    alignment: Alignment.center,
                    child: CircularFilterButton(
                      width: 60,
                      height: 60,
                      iconImage: FloatingActionButton(
                        backgroundColor: Colors.white,
                        onPressed: () {filterRoutes("nwfb");},
                        child: Image(
                          image: new AssetImage(_setImage("nwfb", null)),
                          height: 25,
                        ),
                      ),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset.fromDirection(
                      radToDeg(180), degOneTranslationAnimation.value * 210),
                  child: Transform(
                    transform:
                        Matrix4.rotationZ(radToDeg(rotationAnimation.value)),
                    alignment: Alignment.center,
                    child: CircularFilterButton(
                      width: 60,
                      height: 60,
                      iconImage: FloatingActionButton(
                        backgroundColor: Colors.indigo,
                        onPressed: () {filterRoutes("all");},
                        child: Icon(Icons.close, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Transform(
                  transform:
                      Matrix4.rotationZ(radToDeg(rotationAnimation.value)),
                  alignment: Alignment.center,
                  child: CircularFilterButton(
                    width: 60,
                    height: 60,
                    iconImage: FloatingActionButton(
                      backgroundColor: Colors.teal,
                      onPressed: () {
                        if (animationController.isCompleted) {
                          animationController.reverse();
                        } else {
                          animationController.forward();
                        }
                      },
                      child: Icon(Icons.tune, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          */
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
