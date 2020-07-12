import 'package:flutter/material.dart';
import 'home_drawer.dart';
import 'main_fav_model.dart';

class AllRouteFav extends StatefulWidget {
  @override
  _AllRouteFavState createState() => _AllRouteFavState();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>(); //WARNING
}

class _AllRouteFavState extends State<AllRouteFav> {

  FavStopsCache favStopsInterface;
  FavStopsService favStopsListService = FavStopsService();
  Exception fE;

  void _loadFavList() async {
    print("Load Fav List");
    try {
      FavStopsCache thefavStopsInterface = await favStopsListService.readAllFav();
      setState(() {
        favStopsInterface = thefavStopsInterface;
      });
    } catch(err) {
      setState(() {
        fE = err;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadFavList();
  }


  @override
  Widget build(BuildContext context) {
    if (favStopsInterface == null) {
      return LinearProgressIndicator(
        backgroundColor: Colors.indigo,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
      );
    }
    return ListView.builder(
        key:widget._scaffoldKey,
        itemCount: favStopsInterface.favStopsList.length,
        itemBuilder: (context, index) {
          return Card(
            child: ExpansionTile(
              title: Text(favStopsInterface.favStopsList[index].stopCode),
            ),
          );
        },
    );
  }
}
