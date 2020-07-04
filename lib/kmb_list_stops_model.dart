//import 'all_route_index.dart';

///////// DATA FETCHING PACKAGES /////////
import 'dart:async' show Future;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';

///////// DATABASE PACKAGES /////////
import 'dart:io';
import 'package:path_provider/path_provider.dart';
//import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class KMBLSService {
  static LocalStorage storage = new LocalStorage("kmbRoutes");
  //var stopwatch = new Stopwatch()..start();

  Future<ListStops> getKMBLS(String route, String serviceType, String bound) async {
    var kmbLS = await getKMBLSFromCache(route, serviceType, bound);
    if (kmbLS == null) {
      return getKMBLSFromAPI(route, serviceType, bound);
    }
    return kmbLS;
    //how bout trying differentiating the 2 variables?
  }

  Future<ListStops> getKMBLSFromAPI(String route, String serviceType, String bound) async {
    print("call from api");
    ListStops kmbLS = await fetchListStops(route, serviceType, bound);
    kmbLS.fromCache = false;
    saveKMBLS(route, serviceType, bound, kmbLS);
    return kmbLS;
  }

  Future<ListStops> getKMBLSFromCache(String route, String serviceType, String bound) async {
    print("call from cache");
    await storage.ready;
    Map <String, dynamic> data = storage.getItem("kmbroute"+route+serviceType+bound);
    print(data);
    if (data == null) {
      return null;
    }
    ListStops kmbLS = ListStops.fromJson(data);
    kmbLS.fromCache = true;
    print("loaded item as " + "kmbroute"+route+serviceType+bound);
    return kmbLS;
  }

  void saveKMBLS(String route, String serviceType, String bound, ListStops kmbLS) async {
    await storage.ready;
    storage.setItem("kmbroute"+route+serviceType+bound, kmbLS);
    print("saved item as " + "kmbroute"+route+serviceType+bound);
  }

  Future<ListStops> fetchListStops(String route, String serviceType, String bound) async {
    final response = await http.get(
        "http://search.kmb.hk/KMBWebSite/Function/FunctionRequest.ashx?action=getstops&route=" +
            route +
            "&bound=" +
            bound +
            "&serviceType=" +
            serviceType);

    if (response.statusCode == 200) {
      return ListStops.fromJson(json.decode(response.body));
    } else {
      //throw Exception('Failed to load information');
    }
  }
}

class ListStops {

  Data data;
  bool fromCache = false;

  ListStops({this.data, this.fromCache});

  //var amendedData = Data.fromJson(i);

  factory ListStops.fromJson(Map<String, dynamic> json) {
    return new ListStops(
      data: Data.fromJson(json["data"]),
    );
  }

  Map<String, dynamic> toJson() => { //hmmmm?
    "data": data.toJson(),
  };

}

class Data {
  BasicInfo basicInfo;
  List<RouteStops> routeStopsList;

  Data({this.routeStopsList, this.basicInfo});

  factory Data.fromJson(Map<String, dynamic> json) {
    var list = json["routeStops"] as List;
    print(list.runtimeType);

    List<RouteStops> amendedList =
        list.map((i) => RouteStops.fromJson(i)).toList();

    return new Data(
      routeStopsList: amendedList,
      basicInfo: BasicInfo.fromJson(json["basicInfo"]),
    );
  }

  Map<String, dynamic> toJson() => { //hmmmm?
    "basicInfo": basicInfo.toJson(),
    "routeStops": new List<dynamic>.from(routeStopsList.map((x) => x.toJson())),
  };
  
}

class BasicInfo {
  String destEName;
  String destCName;
  String oriCName;
  String oriEName;

  BasicInfo({this.destCName, this.destEName, this.oriCName, this.oriEName});

  factory BasicInfo.fromJson(Map<String, dynamic> json) {
    return new BasicInfo(
      destCName: json["DestCName"] as String,
      destEName: json["DestEName"] as String,
      oriCName: json["OriCName"] as String,
      oriEName: json["OriEName"] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    "DestCName": destEName,
    "DestEName": destCName,
    "OriCName": oriCName,
    "OriEName": oriEName,
  };
}

class RouteStops {
  String cName;
  //num y;
  //num eLocation;
  //num x;
  //num airFare; //add this back later
  //String eName;
  //String sCName;
  String serviceType;
  String cLocation;
  String bsiCode;
  String seq;
  //String sCLocation;
  String direction;
  String bound;
  String route;

  RouteStops(
      {this.cName,
      this.cLocation,
      this.bound,
      this.seq,
      this.direction,
      this.route,
      this.serviceType});
  //this.y, this.x, this.airFare,

  RouteStops.fromJson(Map<String, dynamic> json) {
    cName = json["CName"];
    //y = json["Y"];
    //x = json["X"];
    //airFare = json["AirFare"];
    cLocation = json["CLocation"];
    bsiCode = json["BSICode"];
    seq = json["Seq"];
    direction = json["Direction"];
    bound = json["Bound"];
    route = json["Route"];
    serviceType = json["ServiceType"];
  }

  Map<String, dynamic> toJson() => {
    "CName": cName,
    "CLocation": cLocation,
    "BSICode": bsiCode,
    "Seq": seq,
    "Direction": direction,
    "Bound": bound,
    "Route": route,
    "ServiceType": serviceType,
  };
}

/*

class KMBRouteStopDBProvider {

      // This is the actual database filename that is saved in the docs directory.
      static final _databaseName = "KMBRouteStopsDataBase.db";
      // Increment this version when you need to change the schema.
      static final _databaseVersion = 1;

      // Make this a singleton class.
      KMBRouteStopDBProvider._privateConstructor();
      static final KMBRouteStopDBProvider instance = KMBRouteStopDBProvider._privateConstructor();

      // Only allow a single open connection to the database.
      static Database _database;
      Future<Database> get database async {
        if (_database != null) return _database;
        _database = await _initDatabase();
        return _database;
      }

      // open the database
      _initDatabase() async {
        // The path_provider plugin gets the right directory for Android or iOS.
        Directory documentsDirectory = await getApplicationDocumentsDirectory();
        String path = join(documentsDirectory.path, _databaseName);
        // Open the database. Can also add an onUpdate callback parameter.
        return await openDatabase(
          path,
          version: _databaseVersion,
          onCreate: _onCreate
        );
      }

      // SQL string to create the database 
      Future _onCreate(Database db, int version) async {
        await db.execute(
          'CREATE TABLE RouteStop('
          'BSICode INTEGER PRIMARY KEY,'
          'CName TEXT,'
          'CLocation TEXT,'
          'Seq TEXT,'
          'Direction TEXT'
          'Bound TEXT'
          'Route TEXT'
          'ServiceType TEXT'
          ')'
        );
      }

      // Database helper methods:
      Future<int> insert(ListStops route) async {
        Database db = await database;
        int id = await db.insert("Route", route.toJson()); //not RouteStops (should be routes?)
        return id;
      }

      Future<ListStops> queryWord(int id) async {
        Database db = await database;
        List<Map> maps = await db.query(tableWords,
            columns: [columnId, columnWord, columnFrequency],
            where: '$columnId = ?',
            whereArgs: [id]);
        if (maps.length > 0) {
          return Word.fromMap(maps.first);
        }
        return null;
      }

}

*/


