import 'all_route_index.dart';
import 'package:flutter/material.dart';
import 'dart:async' show Future;
import 'dart:convert';
//import 'package:http/http.dart' as http;
import 'kmb_eta.dart';
import 'kmb_list_stops_model.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:localstorage/localstorage.dart';

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

class _KMBListStopsState extends State<KMBListStops> {

  //////////LOCAL STORAGE/////////
  //Future<ListStops> _futureListStops;


  //NEW STUFF
  ListStops kmbLS;
  KMBLSService service = KMBLSService();
  Exception e;

  void _loadKMBLS(String route, String serviceType, String bound) async {
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
    return ListView.builder(
      itemCount: kmbLS.data.routeStopsList.length,
      itemBuilder: (context, index) {
        return Card(
          child: ExpansionTile(
            leading: Text(kmbLS.data.routeStopsList[index].seq),
            title: Text(kmbLS.data.routeStopsList[index].cName)
          ),
        );
      },
    );
  }
}
