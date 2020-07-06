import 'package:flutter/material.dart';

import 'nwfb_stop.dart';
import 'nwfb_eta.dart';
import 'nwfb_list_stops_model.dart';

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
  }) : super(key: key);

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  _NWFBListStopsState createState() => _NWFBListStopsState();
}

class _NWFBListStopsState extends State<NWFBListStops> {
  /*
  Future<NWFBAPI> futureListStops;

  @override
  void initState() {
    super.initState();
    futureListStops = fetchListStops(widget.route, widget.bound, widget.operator);
  }
  */

  //NEW STUFF
  NWFBAPI nwfbLS;
  NWFBLSService service = NWFBLSService();
  Exception e;

  void _loadNWFBLS(String route, String bound, String operator) async {
    print("route:" + route + ", bound:" + bound + ", operator:" + operator);
    try {
      NWFBAPI thenwfbLS = await service.getNWFBLS(route, bound, operator);
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
    _loadNWFBLS(widget.route, widget.bound, widget.operator);
  }

  Widget _listStops() {
    /*
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
    */
    if (nwfbLS == null) {
      return LinearProgressIndicator(
        backgroundColor: Colors.orange,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
      );
    }
    return ListView.builder(
      key: widget._scaffoldKey,
      itemCount: nwfbLS.routeStopsList.length,
      itemBuilder: (context, index) {
        return Card(
          child: ExpansionTile(
            leading: Text("${index + 1}"),
            title: NWFBStop(stopID: nwfbLS.routeStopsList[index].stop),
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 55.0, bottom: 30.0),
                child: NWFBETA(
                  route: nwfbLS.routeStopsList[index].route,
                  operator: nwfbLS.routeStopsList[index].co,
                  stopID: nwfbLS.routeStopsList[index].stop,
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
