import 'package:flutter/material.dart';
import 'all_route_index.dart' as first;
import 'all_route_fav.dart' as second;
import 'home_drawer.dart';

class MainTabs extends StatefulWidget {
  @override
  _MainTabsState createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs>
    with SingleTickerProviderStateMixin {
  TabController mainController;
  int index = 0;

  @override
  void initState() {
    super.initState();
    mainController = new TabController(vsync: this, length: 4);
  }

  @override
  void dispose() {
    mainController.dispose();
    super.dispose();
  }

  tapped(int tappedIndex) {
    setState(() {
      index = tappedIndex;
    });
  }

  List<Widget> _widgets = [
    first.AllRouteIndex(),
    second.AllRouteFav(),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length:2,
      child: Scaffold(
        drawer: HomeDrawer(),
        body: TabBarView(
          children: [
            first.AllRouteIndex(),
            second.AllRouteFav(),
          ],
        ),
        bottomNavigationBar: new TabBar(
          indicatorPadding: EdgeInsets.only(bottom:80),
          indicatorColor: Colors.indigo,
          indicatorWeight: 5.0,
          labelColor: Colors.indigo,
          //elevation: 10.0,
          //fixedColor: Colors.white,
          //unselectedItemColor: Colors.grey[300],
          //backgroundColor: Colors.indigo,
          //currentIndex: index,
          //onTap: tapped,
          tabs: [
            Padding(
              padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
              child: Tab(
                  icon: new Icon(Icons.directions_bus), text:'路線'),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
              child: Tab(
                  icon: new Icon(Icons.favorite), text:'我的最愛'),
            ),
          ],
        ),
      ),
    );
  }
}
