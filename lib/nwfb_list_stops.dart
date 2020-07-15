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
  final String operator;

  NWFBListStops({
    @required this.route,
    @required this.bound,
    @required this.oriTC,
    @required this.destTC,
    @required this.operator,
    Key key,
  }) : super(key: key);

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>(); //WARNING about global key

  @override
  _NWFBListStopsState createState() => _NWFBListStopsState();
}

class _NWFBListStopsState extends State<NWFBListStops> {

  //NEW STUFF
  NWFBAPI nwfbLS;
  NWFBLSService service = NWFBLSService();
  Exception e;

  void _loadNWFBLS(String route, String bound, String operator) async {
    print("route:" + route + ", bound:" + bound + ", operator:" + operator);
    try {

      String boundMod;
      if (bound == '1') {
        boundMod = "outbound";
      } else if (bound == '2') {
        boundMod = "inbound";
      }

      NWFBAPI thenwfbLS = await service.getNWFBLS(route, boundMod, operator);
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
            trailing: new IconButton(
              icon: new Icon(Icons.favorite),
              onPressed: () {
                 FavStop currentStop = FavStop(
                    id: nwfbLS.routeStopsList[index].co+nwfbLS.routeStopsList[index].route+nwfbLS.routeStopsList[index].dir+nwfbLS.routeStopsList[index].stop+"${nwfbLS.routeStopsList[index].seq}",
                    operator:nwfbLS.routeStopsList[index].co,
                    route: nwfbLS.routeStopsList[index].route,
                    bound: nwfbLS.routeStopsList[index].dir,
                    seq: "${nwfbLS.routeStopsList[index].seq}",
                    stopCode: nwfbLS.routeStopsList[index].stop,
                    cName: nwfbLS.routeStopsList[index].stop,
                    serviceType: "null",
                  );
                  DBProvider.db.createFavstop(currentStop);
                  print("added ${nwfbLS.routeStopsList[index].stop} favourite to database");
                  print(nwfbLS.routeStopsList[index].co);
              }, 
            ),
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
