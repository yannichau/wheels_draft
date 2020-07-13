import 'package:flutter/material.dart';
import 'home_drawer.dart';
import 'main_fav_model.dart';

class AllRouteFav extends StatefulWidget {
  @override
  _AllRouteFavState createState() => _AllRouteFavState();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>(); //WARNING
}

class _AllRouteFavState extends State<AllRouteFav> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("我的最愛"),
        backgroundColor: Colors.indigo,
      ),
      body: FutureBuilder(
        future: DBProvider.db.getAllFavStops(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: LinearProgressIndicator(),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data.length, // what the hell?
              itemBuilder: (context, index) {
                return Card(
                  child: ExpansionTile(
                    title: Text(snapshot.data[index].stopCode),
                  ),
                );
              },
            );
          }
        }
      )
    );
  }
  
}
