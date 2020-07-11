//import 'all_route_index.dart';
import 'package:flutter/material.dart';
//import 'dart:async' show Future;
//import 'dart:convert';
//import 'package:http/http.dart' as http;
import 'kmb_eta.dart';
import 'kmb_list_stops_model.dart';

///////// DATABASE PACKAGES /////////
//import 'dart:io';
//import 'package:path_provider/path_provider.dart';
//import 'package:path/path.dart';
//import 'package:localstorage/localstorage.dart';

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

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>(); //WARNING

  @override
  _KMBListStopsState createState() => _KMBListStopsState();
}

class _KMBListStopsState extends State<KMBListStops> with AutomaticKeepAliveClientMixin{

  //////////LOCAL STORAGE/////////
  //Future<ListStops> _futureListStops;


  //NEW STUFF
  ListStops kmbLS;
  KMBLSService service = KMBLSService();
  Exception e;

  void _loadKMBLS(String route, String serviceType, String bound) async {
    print("route:" + route + ", serviceType:" + serviceType + ", bound:" + bound);
    try {
      ListStops thekmbLS = await service.getKMBLS(route, serviceType, bound);
      setState(() {
        kmbLS = thekmbLS;
      });
    } catch(err) {
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


  Text _removeUnknown(String stop) { //TODO: Not working!
    //print(stop);
    // '埗' '匯' '邨'
    var estate = '\ue473';
    if (stop.contains(estate)) {
      //print("wow");
      stop.replaceAll("\ue473",'邨');
    }
    //print(stop);
    return Text(stop);
  }

  @override
  Widget build(BuildContext context) {
    if (kmbLS == null) {
      return LinearProgressIndicator(
        backgroundColor: Colors.red,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
      );
    }
    return ListView.builder(
        key:widget._scaffoldKey,
        itemCount: kmbLS.data.routeStopsList.length,
        itemBuilder: (context, index) {
          return Card(
            child: ExpansionTile(
              leading: Text("${index + 1}"),
              title: _removeUnknown(kmbLS.data.routeStopsList[index].cName), // why is this not working?
              trailing: new IconButton(
                icon: new Icon(Icons.favorite),
                onPressed: () { /* Your code */ }, //TODO:
              )
            ),
          );
        },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
