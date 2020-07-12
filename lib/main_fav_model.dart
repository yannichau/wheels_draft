//import 'package:flutter/material.dart';
import 'dart:async' show Future;
//import 'dart:collection';
import 'dart:convert';
//import 'package:flutter/widgets.dart';
import 'package:localstorage/localstorage.dart';

class FavStopsService {
  static LocalStorage storage = new LocalStorage("favStops");
  //var stopwatch = new Stopwatch()..start();

  void saveFav(String route, String bound, String operator, String stopCode, String seq, String serviceType, FavStopsCache favList) async {
    await storage.ready;
    storage.setItem("favRoute"+route+"bound"+bound+"operator"+operator+"stopCode"+stopCode+"seq"+seq+"serviceType"+serviceType, favList);
    print("saved item as " + "favRoute"+route+"bound"+bound+"operator"+operator+"stopCode"+stopCode+"seq"+seq+"serviceType"+serviceType);
  }

  Future<FavStopsCache> getFavListFromCache(String route, String bound, String operator, String stopCode, String seq, String serviceType) async {
    print("call from nwfbroute cache");
    await storage.ready;
    Map <String, dynamic> data = storage.getItem("favRoute"+route+"bound"+bound+"operator"+operator+"stopCode"+stopCode+"seq"+seq+"serviceType"+serviceType);
    print(data);
    if (data == null) {
      return null;
    }
    FavStopsCache favList = FavStopsCache.fromJson(data);
    favList.fromCache = true;
    print("loaded item as " + "favRoute"+route+"bound"+bound+"operator"+operator+"stopCode"+stopCode+"seq"+seq+"serviceType"+serviceType);
    return favList;
  }

  Future <FavStopsCache> readAllFav() async {
    try {
      print("read all favourites");
      await storage.ready;
      String jsonString = storage.toString();
      print("readString");
      final jsonMap = jsonDecode(jsonString);
      print("decodedFavString");
      FavStopsCache favs = jsonMap.map((parsedJson) => FavStopsCache.fromJson(parsedJson));
      print("parsedJSONasobject");
      return favs;
    } catch(e) {
      print ("can't fetch from favourites storage!");
    }
    return null;
  }

}

class FavStopsCache {
  List<FavStops> favStopsList;
  bool fromCache;

  FavStopsCache({this.favStopsList, this.fromCache});

  factory FavStopsCache.fromJson(Map<String, dynamic> json) {
    //print("start API");
    var list = json["data"] as List;
    print(list.runtimeType);

    List<FavStops> amendedList = list.map((i) =>
      FavStops.fromJson(i)). toList();

    return new FavStopsCache(
      favStopsList: amendedList,
    );
  }

  Map<String, dynamic> toJson() => { 
    "data": new List<dynamic>.from(favStopsList.map((x) => x.toJson())),
  };

}

class FavStops {
  String operator;
  String route;
  String bound;
  String stopCode;
  String serviceType;
  String seq;

  FavStops({this.operator, this.route, this.bound, this.seq, this.stopCode, this.serviceType});

  FavStops.fromJson(Map<String, dynamic> json) {
    operator = json["operator"];
    route = json["route"];
    bound = json["bound"];
    stopCode = json["stopCode"];
    serviceType = json["serviceType"];
    seq = json["seq"];
  }

  Map<String, dynamic> toJson() => {
    "operator": operator,
    "route": route,
    "bound": bound,
    "seq": seq,
    "stopCode": stopCode,
    "serviceType": serviceType,
  };

}
