import 'package:flutter/material.dart';
import 'kmb_list_stops.dart' as first;
import 'kmb_timetable.dart' as second;
import 'kmb_bbi.dart' as third;
import 'kmb_announcement.dart' as fourth;

class KMBTabs extends StatefulWidget {

  final String route;
  final String bound;
  final String oriTC;
  final String destTC;
  final String serviceType;
  final bool isSearching;
  final bool isCircular;

  KMBTabs({
    @required this.route, 
    @required this.serviceType,
    @required this.bound, 
    @required this.oriTC,
    @required this.destTC,
    @required this.isSearching,
    @required this.isCircular,
    Key key,
  }): super(key: key);

  @override
  _KMBTabsState createState() => _KMBTabsState();
}

class _KMBTabsState extends State<KMBTabs> with SingleTickerProviderStateMixin {

  TabController kmbController;

  @override
  void initState() {
    super.initState();
    kmbController = new TabController(vsync: this, length: 4);
  }

  @override
  void dispose(){
    kmbController.dispose();
    super.dispose();
  }

  String _returnSymbol(bool isCircular) {
    if (isCircular) {
      return " ↺ ";
    }
    return " → ";
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
        backgroundColor: Colors.red,
        title: new Text(widget.route + " " + widget.oriTC + _returnSymbol(widget.isCircular) + widget.destTC),
        bottom: TabBar(
          controller: kmbController,
          tabs: <Tab>[
            new Tab(text:"到站預報"),
            new Tab(text:"時間表"),
            new Tab(text:"轉乘優惠"),
            new Tab(text:"特別資訊"),       
          ],
        ),
      ),
      body: new TabBarView (
        controller: kmbController,
        children: <Widget>[
          new first.KMBListStops(route: widget.route, bound: widget.bound, serviceType: widget.serviceType),
          new second.KMBTimetable(route: widget.route, bound:widget.bound),
          new third.KMBBBI(route: widget.route, bound:widget.bound),
          new fourth.KMBAnnouncement(route: widget.route, bound:widget.bound),
        ],
      )
    );
  }
}