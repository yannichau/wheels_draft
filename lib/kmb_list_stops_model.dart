//import 'all_route_index.dart';

///////// DATA FETCHING PACKAGES /////////
import 'dart:async' show Future;
import 'dart:convert';
//import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';

///////// DATABASE PACKAGES /////////
//import 'dart:io';
//import 'package:path_provider/path_provider.dart';
//import 'package:sqflite/sqflite.dart';
//import 'package:path/path.dart';

class KMBLSService {
  static LocalStorage storage = new LocalStorage("kmbRoutes");
  //var stopwatch = new Stopwatch()..start();

  void saveKMBLS(String route, String serviceType, String bound, ListStops kmbLS) async {
    await storage.ready;
    storage.setItem("kmbroute"+route+"bound"+bound+"serviceType"+serviceType, kmbLS);
    print("saved item as " + "kmbroute"+route+"bound"+bound+"serviceType"+serviceType);
  }

  void deleteKMBLS() async {
    await storage.ready;
    storage.clear();
    print("deleted entire KMBLS");
  }

  Future<ListStops> getKMBLS(String route, String serviceType, String bound) async {
    ListStops kmbLS = await getKMBLSFromCache(route, serviceType, bound);
    if (kmbLS == null) {
      kmbLS = await getKMBLSFromAPI(route, serviceType, bound);
    }
    return kmbLS;
    //how bout trying differentiating the 2 variables?
  }

  Future<ListStops> getKMBLSFromAPI(String route, String serviceType, String bound) async {
    print("call from api");
    ListStops kmbLS;
    kmbLS = await fetchListStops(route, serviceType, bound); 
    kmbLS.fromCache = false;
    saveKMBLS(route, serviceType, bound, kmbLS);
    return kmbLS; 
  }

  Future<ListStops> getKMBLSFromCache(String route, String serviceType, String bound) async {
    print("call from cache");
    await storage.ready;
    Map <String, dynamic> data = storage.getItem("kmbroute"+route+"bound"+bound+"serviceType"+serviceType);
    print(data);
    if (data == null) {
      return null;
    }
    ListStops kmbLS = ListStops.fromJson(data);
    kmbLS.fromCache = true;
    print("loaded item as " + "kmbroute"+route+"bound"+bound+"serviceType"+serviceType);
    return kmbLS;
  }

  Future<ListStops> fetchListStops(String route, String serviceType, String bound) async {
    final link = "http://search.kmb.hk/KMBWebSite/Function/FunctionRequest.ashx?action=getstops&route=" + 
            route + "&bound=" + bound + "&serviceType=" + serviceType;
    print(link);
    final response = await http.get(link);

    if (response.statusCode == 200) {
      return ListStops.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load information');
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


