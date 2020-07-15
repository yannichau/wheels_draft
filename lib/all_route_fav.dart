import 'package:flutter/material.dart';
import 'home_drawer.dart';
import 'main_fav_model.dart';
import 'nwfb_stop.dart';

class AllRouteFav extends StatefulWidget {
  @override
  _AllRouteFavState createState() => _AllRouteFavState();
  final GlobalKey<ScaffoldState> _scaffoldKey =
      new GlobalKey<ScaffoldState>(); //WARNING
}

class _AllRouteFavState extends State<AllRouteFav> {
  String _setImage(String operator) {
    if (operator == "lwb") {
      return 'images/lwb.png';
    } else if (operator == "kmb") {
      return 'images/kmb.png';
    } else if (operator == "NWFB") {
      return 'images/nwfb.jpg';
    } else if (operator == "CTB") {
      return 'images/ctb.png';
    } else {
      return 'images/joint.png';
    }
  }

  Widget stopTitle(String operator, String cName) {
    if (operator == "kmb" || operator == "lwb") {
      return Text(cName);
    } else if (operator == "CTB" || operator == "NWFB") {
      return NWFBStop(stopID:cName);
    } else {
      return Text(cName);
    }
  }

  Widget loadETA(String operator, String stopID, String route, String bound, String serviceType, String stopCode, String seq) {
    
  }



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
                  itemCount: snapshot.data.length, 
                  itemBuilder: (context, index) {
                    return Card(
                      child: ExpansionTile(
                        leading: Container(
                          width: 60,
                          child: Column(
                            children: [
                              Image(
                                image: new AssetImage(
                                    _setImage(snapshot.data[index].operator)),
                                height: 25,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: Text(snapshot.data[index].route,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    )),
                              )
                            ],
                          ),
                        ),
                        title: stopTitle(snapshot.data[index].operator, snapshot.data[index].cName),
                        subtitle: Text(snapshot.data[index].id),
                        children: [
                          Text("ETA Placeholder"),
                          IconButton(
                            icon: new Icon(Icons.delete),
                            onPressed: () {
                              DBProvider.db.deleteAllFavStops();
                            },
                          )
                        ],
                        trailing: IconButton (
                          icon: Icon(Icons.keyboard_arrow_right),
                          onPressed: () {
                            
                          },
                        )
                      ),
                    );
                  },
                );
              }
            }));
  }
}
