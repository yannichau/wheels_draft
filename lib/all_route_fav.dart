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
  String _setImage(String operatorHK) {
    if (operatorHK == "lwb") {
      return 'images/lwb.png';
    } else if (operatorHK == "kmb") {
      return 'images/kmb.png';
    } else if (operatorHK == "NWFB") {
      return 'images/nwfb.jpg';
    } else if (operatorHK == "CTB") {
      return 'images/ctb.png';
    } else {
      return 'images/joint.png';
    }
  }

  Widget stopTitle(String operatorHK, String cName) {
    if (operatorHK == "kmb" || operatorHK == "lwb") {
      return Text(cName);
    } else if (operatorHK == "CTB" || operatorHK == "NWFB") {
      return NWFBStop(stopID: cName);
    } else {
      return Text(cName);
    }
  }

  Widget loadETA(String operatorHK, String stopID, String route, String bound,
      String serviceType, String stopCode, String seq) {}

  ////////// TEMPORARY LOCAL VARIABLES ////////////
  String favID;
  String favOperatorHK;
  String favRoute;
  String favBound;
  String favStopCode;
  String favCName;
  String favServiceType;
  String favSeq;
  String favKeyID;

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
                return LinearProgressIndicator(
                  backgroundColor: Colors.teal,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
                );
              } else {
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    //ASSIGN VALUES TO TEMPORARY VARIABLES
                    favID = snapshot.data[index].id;
                    favOperatorHK = snapshot.data[index].operatorHK;
                    favRoute = snapshot.data[index].route;
                    favBound = snapshot.data[index].bound;
                    favStopCode = snapshot.data[index].stopCode;
                    favCName = snapshot.data[index].cName;
                    favServiceType = snapshot.data[index].serviceType;
                    favSeq = snapshot.data[index].seq;

                    return Card(
                      child: ExpansionTile(
                          leading: Container(
                            width: 60,
                            child: Column(
                              children: [
                                Image(
                                  image:
                                      new AssetImage(_setImage(favOperatorHK)),
                                  height: 25,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5.0),
                                  child: Text(favRoute,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      )),
                                )
                              ],
                            ),
                          ),
                          title: stopTitle(favOperatorHK, favCName),
                          subtitle: Text(favID),
                          children: [
                            Text("ETA Placeholder"),
                            IconButton(
                              icon: new Icon(Icons.delete),
                              onPressed: () {
                                return showDialog(
                                  context: context,
                                  barrierDismissible:false, // user must tap button for close dialog!
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('刪除？'),
                                      content: const Text('這會令此車站從「我的最愛」介面消失。'),
                                      actions: <Widget>[
                                        FlatButton(
                                          child: const Text('取消'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        FlatButton(
                                          child: const Text('確認'),
                                          onPressed: () {
                                            setState(() {
                                              DBProvider.db
                                                  .deleteFavStop(favID);
                                            });
                                            Navigator.of(context).pop();
                                          },
                                        )
                                      ],
                                    );
                                  },
                                );
                              },
                            )
                          ],
                          trailing: IconButton(
                            icon: Icon(Icons.keyboard_arrow_right),
                            onPressed: () {
                              //TODO:  Bring to Liststop
                            },
                          )),
                    );
                  },
                );
              }
            }));
  }
}
