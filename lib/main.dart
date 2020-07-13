import 'package:flutter/material.dart';
import 'package:wheels_draft/main_controller.dart';

//import 'kmb_list_stops.dart';
//import 'all_route_index.dart';


void main() async {

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> { //only want to modify myappstate within this scope.
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: Colors.indigo,
      ),
      home: MainTabs(), 
        //body: KMBListStops(stops: _stops),
    );
  }
}
