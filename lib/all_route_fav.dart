import 'package:flutter/material.dart';
import 'home_drawer.dart';

class AllRouteFav extends StatefulWidget {
  @override
  _AllRouteFavState createState() => _AllRouteFavState();
}

class _AllRouteFavState extends State<AllRouteFav> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("我的最愛"),
      ),
      body: Center(
        child: Text("Favourites Placeholder")
      ),
    );
  }
}
