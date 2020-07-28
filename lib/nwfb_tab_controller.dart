import 'package:flutter/material.dart';

import 'package:wheels_draft/nwfb_stop.dart';
import 'nwfb_list_stops.dart' as first;
import 'nwfb_timetable.dart' as second;

class NWFBTabs extends StatefulWidget {

  final String route;
  final String bound;
  final String oriTC;
  final String destTC;
  final String operatorHK;
  final bool isSearching;

  NWFBTabs({
    @required this.route, 
    @required this.bound, 
    @required this.oriTC,
    @required this.destTC,
    @required this.operatorHK,
    @required this.isSearching,
    Key key,
  }): super(key: key);

  @override
  _NWFBTabsState createState() => _NWFBTabsState();
}

class _NWFBTabsState extends State<NWFBTabs> with SingleTickerProviderStateMixin {

  TabController nwfbController;

  @override
  void initState() {
    super.initState();
    nwfbController = new TabController(vsync: this, length: 2);
  }

  @override
  void dispose(){
    nwfbController.dispose();
    super.dispose();
  }

  bool isNumeric(String s) {
  if(s == null) {
    return false;
  }
  return double.parse(s, (e) => null) != null;
  }

  Widget nwfbAppBar(String oriTC, String destTC) {
    Widget origin;
    Widget destination;
    if (isNumeric(oriTC) && isNumeric(destTC)) {
      origin = NWFBStop(stopID: oriTC);
      destination = NWFBStop(stopID: destTC);
      return Row(children: [
        Text(widget.route + " "),
        origin,
        Text(" → "),
        destination
      ],);
    }
    return Text(widget.route + " " + widget.oriTC + " → " + widget.destTC);
  }

  Color getColor(String operatorHK) {
    if (operatorHK == "CTB" || operatorHK == "ctb" ) {
      return Colors.blue[600];
    } else {
      return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        leading: new IconButton(
          icon: new BackButtonIcon(),
          onPressed: () {
             Navigator.pop(context);
             if (widget.isSearching) {
              Navigator.pop(context);
             }
          },
        ),
        backgroundColor: getColor(widget.operatorHK),
        title: nwfbAppBar(widget.oriTC, widget.destTC),
        bottom: TabBar(
          controller: nwfbController,
          tabs: <Tab>[
            new Tab(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(Icons.directions_bus),
                  Text("到站預報"),
                ],
              )
            ),
            new Tab(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,                
                children: [
                  Icon(Icons.access_time),
                  Text("時間表"),
                ],
              )
            )
          ],
        ),
      ),
      body: new TabBarView (
        controller: nwfbController,
        children: <Widget>[
          new first.NWFBListStops(route: widget.route, bound: widget.bound, oriTC: widget.oriTC, destTC: widget.destTC, operatorHK: widget.operatorHK),
          new second.NWFBTimetable(),
        ],
      )
    );
  }
}