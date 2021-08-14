import 'package:flutter/material.dart';

import 'package:wheels_draft/main_controller.dart';

void main() async {

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> { 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: Colors.indigo,
      ),
      home: MainTabs(), 
    );
  }
}
