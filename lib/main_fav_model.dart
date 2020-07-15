import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
//import 'package:dio/dio.dart';

List<FavStop> favStopListFromJson(String str) =>
    List<FavStop>.from(json.decode(str).map((x) => FavStop.fromJson(x)));

String favStopListToJson(List<FavStop> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class FavStop {
  String id; //operatorHK+route+bound+stopcode+serviceType
  String operatorHK;
  String route;
  String bound;
  String stopCode;
  String cName;
  String serviceType;
  String seq;

  FavStop({
    this.id,
    this.operatorHK,
    this.route,
    this.bound,
    this.seq,
    this.stopCode,
    this.cName,
    this.serviceType
  });

  FavStop.fromJson(Map<String, dynamic> json) {
    id = json["ID"];
    operatorHK = json["OperatorHK"];
    route = json["Route"];
    bound = json["Bound"];
    seq = json["Seq"];
    stopCode = json["StopCode"];
    cName = json["Name_TC"];
    serviceType = json["ServiceType"];
  }

  Map<String, dynamic> toJson() => {
    "ID": id,
    "OperatorHK": operatorHK,
    "Route": route,
    "Bound": bound,
    "Seq": seq,
    "StopCode": stopCode,
    "Name_TC": cName, //is stopID for NWFB routes
    "ServiceType": serviceType,
  };
}


class DBProvider {
  static Database _database;
  static final DBProvider db = DBProvider._();

  DBProvider._();

  Future<Database> get database async {
    // If database exists, return database
    if (_database != null) return _database;

    // If database don't exists, create one
    _database = await initDB();

    return _database;
  }

  // Create the database and the FavStops table
  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'fav_stops.db');

    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute('CREATE TABLE FavStop('
          'ID TEXT PRIMARY KEY,'
          'OperatorHK TEXT,'
          'Route TEXT,'
          'Bound TEXT,'
          'Seq TEXT,'
          'StopCode TEXT,'
          'Name_TC TEXT,'
          'ServiceType TEXT'
      ')');
    });
  }

  // Insert employee on database
  createFavstop(FavStop newFavStop) async {
    //await deleteAllFavStops();
    final db = await database;
    final res = await db.insert('FavStop', newFavStop.toJson());

    return res;
  }

  // Delete all employees
  Future<int> deleteAllFavStops() async {
    final db = await database;
    final res = await db.rawDelete('DELETE FROM FavStop');

    //await db.delete('FavStop');

    return res;
  }

  Future<List<FavStop>> getAllFavStops() async {
    final db = await database;
    final res = await db.rawQuery("SELECT * FROM FAVSTOP");

    List<FavStop> list =
        res.isNotEmpty ? res.map((c) => FavStop.fromJson(c)).toList() : [];

    return list;
  }

    Future<void> deleteFavStop(String id) async {
    final db = await database;
    await db.delete(
      'FavStop',
      where: "ID = ?",
      whereArgs: [id],
    );
    print("deleted");
  }
}





