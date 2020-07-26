import 'package:flutter/material.dart';

import 'nwfb_stop.dart';
import 'nwfb_eta.dart';
import 'nwfb_list_stops_model.dart';
import 'main_fav_model.dart';

class NWFBListStops extends StatefulWidget {
  final String route;
  final String bound;
  final String oriTC;
  final String destTC;
  final String operatorHK;

  NWFBListStops({
    @required this.route,
    @required this.bound,
    @required this.oriTC,
    @required this.destTC,
    @required this.operatorHK,
    Key key,
  }) : super(key: key);

  final GlobalKey<ScaffoldState> _scaffoldKey =
      new GlobalKey<ScaffoldState>(); //WARNING about global key

  @override
  _NWFBListStopsState createState() => _NWFBListStopsState();
}

class _NWFBListStopsState extends State<NWFBListStops> {
  //NEW STUFF
  NWFBAPI nwfbLS;
  NWFBLSService service = NWFBLSService();
  Exception e;

  void _loadNWFBLS(String route, String bound, String operatorHK) async {
    print("route:" + route + ", bound:" + bound + ", operator:" + operatorHK);
    try {
      String boundMod;
      if (bound == '1') {
        boundMod = "outbound";
      } else if (bound == '2') {
        boundMod = "inbound";
      }

      NWFBAPI thenwfbLS = await service.getNWFBLS(route, boundMod, operatorHK);
      setState(() {
        nwfbLS = thenwfbLS;
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
    _loadNWFBLS(widget.route, widget.bound, widget.operatorHK);
  }

  ///////// DECLARE TEMPORARY LOCAL VARIABLES //////////
  String nwfbRoute;
  String nwfbStopCode;
  String nwfbOperator;
  String nwfbDirection;
  num nwfbSeq;

  Widget _listStops() {
    if (nwfbLS == null) {
      if (widget.operatorHK == "ctb") {
        return LinearProgressIndicator(
          backgroundColor: Colors.red,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow[600]),
        );
      } else {
        return LinearProgressIndicator(
          backgroundColor: Colors.orange,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        );
      }
    }
    return ListView.builder(
      key: widget._scaffoldKey,
      itemCount: nwfbLS.routeStopsList.length,
      itemBuilder: (context, index) {
        //ASIGN VALUES FROM FUTURE
        nwfbRoute = nwfbLS.routeStopsList[index].route;
        nwfbStopCode = nwfbLS.routeStopsList[index].stop;
        nwfbOperator = nwfbLS.routeStopsList[index].co;
        nwfbDirection = nwfbLS.routeStopsList[index].dir;
        nwfbSeq = nwfbLS.routeStopsList[index].seq;

        return Card(
          child: ExpansionTile(
            leading: Text("${index + 1}"),
            title: NWFBStop(stopID: nwfbStopCode),
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
                              id: nwfbOperator +
                                  nwfbRoute +
                                  nwfbDirection +
                                  nwfbLS.routeStopsList[index].co +
                                  "${nwfbLS.routeStopsList[index].seq}",
                              operatorHK: nwfbOperator,
                              route: nwfbRoute,
                              bound: nwfbDirection, //hmmmm
                              seq: "${nwfbLS.routeStopsList[index].seq}",
                              stopCode: nwfbLS.routeStopsList[index].stop,
                              cName: nwfbLS.routeStopsList[index]
                                  .stop, //pass stopcode as cName for NWFB
                              serviceType: "null",
                              oriTC: nwfbLS.routeStopsList[0].stop,
                              destTC: nwfbLS
                                  .routeStopsList[
                                      nwfbLS.routeStopsList.length - 1]
                                  .stop,
                            );
                            DBProvider.db.createFavstop(currentStop);
                            print(
                                "added ${nwfbLS.routeStopsList[index].stop} favourite to database");
                            print(nwfbOperator);
                            print("bound: " + nwfbDirection);
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    );
                  },
                );
              },
            ),
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 55.0, bottom: 30.0),
                child: NWFBETA(
                  route: nwfbRoute,
                  operatorHK: nwfbOperator,
                  stopID: nwfbStopCode,
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _listStops();
  }
}
