import 'package:flutter/material.dart';
import 'nwfb_list_stops.dart' as first;
import 'nwfb_timetable.dart' as second;

class NWFBTabs extends StatefulWidget {

  final String route;
  final String bound;
  final String oriTC;
  final String destTC;
  final String operator;

  NWFBTabs({
    @required this.route, 
    @required this.bound, 
    @required this.oriTC,
    @required this.destTC,
    @required this.operator,
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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.purple,
        title: new Text(widget.route + " " + widget.oriTC + " → " + widget.destTC),
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
          new first.NWFBListStops(route: widget.route, bound: widget.bound, oriTC: widget.oriTC, destTC: widget.destTC, operator: widget.operator),
          new second.NWFBTimetable(),
        ],
      )
    );
  }
}