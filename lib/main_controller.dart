import 'package:flutter/material.dart';

import 'all_route_index_aug_1.dart' as second; //alternative
import 'all_route_fav.dart' as first;
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

  ////////// DETERMINES THE SELECTED TAB /////////
  tapped(int tappedIndex) {
    setState(() {
      index = tappedIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length:2,
      child: Scaffold(
        drawer: HomeDrawer(),
        body: TabBarView(
          children: [
            first.AllRouteFav(),
            second.AllRouteIndex(),
          ],
        ),
        /*
        bottomNavigationBar: new TabBar(
          indicatorColor: Colors.indigo,
          labelColor: Colors.indigo,
          tabs: [
            SafeArea(child: Tab(icon: new Icon(Icons.favorite), text:'我的最愛')),
            SafeArea(child: Tab(icon: new Icon(Icons.directions_bus), text:'路線')),
          ],
        ),
        */
      ),
    );
  }
}
