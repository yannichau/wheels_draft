import 'package:flutter/material.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<KMBBBIAPI> fetchKMBBBIAPI(String route, String bound) async {
  String url =
      "http://search.kmb.hk/KMBWebSite/Function/FunctionRequest.ashx/?action=getbbiforroute&route=" +
          route +
          "&bound=" +
          bound;
  final response = await http.get(url);
  print(url);

  if (response.statusCode == 200) {
    return KMBBBIAPI.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load information');
  }
}

class KMBBBIAPI {
  KMBBBIAPIData data;

  KMBBBIAPI({this.data});

  factory KMBBBIAPI.fromJson(Map<String, dynamic> json) {
    return new KMBBBIAPI(
      data: KMBBBIAPIData.fromJson(json["data"]),
    );
  }
}

class KMBBBIAPIData {
  List<KMBBBIAPIInfo> bbiList;

  KMBBBIAPIData({this.bbiList});

  factory KMBBBIAPIData.fromJson(Map<String, dynamic> json) {
    var list = json["BBIs"] as List;
    List<KMBBBIAPIInfo> amendedList =
        list.map((i) => KMBBBIAPIInfo.fromJson(i)).toList();

    return new KMBBBIAPIData(
      bbiList: amendedList,
    );
  }
}

class KMBBBIAPIInfo {
  //String Direction
  //String route1;
  //String destEN;
  //String fare1Limit;
  String route2;
  String fare2Limit;
  String discountType;
  String discount;
  String destTC;

  KMBBBIAPIInfo({
    this.destTC,
    this.discount,
    this.discountType,
    this.fare2Limit,
    this.route2,
  });

  KMBBBIAPIInfo.fromJson(Map<String, dynamic> json) {
    route2 = json["Route2"];
    fare2Limit = json["Fare2Limit"];
    discountType = json["DiscountType"];
    discount = json["Discount"];
    destTC = json["Destination_CHI"];
  }
}

class KMBBBI extends StatefulWidget {
  final String route;
  final String bound;

  KMBBBI({
    @required this.route,
    @required this.bound,
    Key key,
  }) : super(key: key);

  @override
  _KMBBBIState createState() => _KMBBBIState();
}

class _KMBBBIState extends State<KMBBBI> {
  Future<KMBBBIAPI> futureKMBBBI;

  @override
  void initState() {
    super.initState();
    futureKMBBBI = fetchKMBBBIAPI(widget.route, widget.bound);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<KMBBBIAPI>(
        future: futureKMBBBI,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<KMBBBIAPIInfo> list = snapshot.data.data.bbiList;
            ListView myList = new ListView.builder(
                shrinkWrap: true,
                itemCount: list.length,
                itemBuilder: (context, index) {
                  print(widget.bound);
                  if (list[index].discountType.contains("5")) {
                    //return Card(
                      return ListTile(
                        title: Text("往" + list[index].destTC),
                        subtitle: Text("總額 \$" + list[index].discount),
                        trailing: Text("轉乘" + list[index].route2),
                      );
                    //);
                  } else if (list[index].discountType.contains("1") &&
                      list[index].destTC.contains("機場")) {
                    //return Card(
                      return ListTile(
                        title: Text("往" + list[index].destTC),
                        subtitle: Text("第二程扣減 \$" + list[index].discount),
                        trailing: Text("轉乘" + list[index].route2),
                      );
                    //);
                  } else {
                    return Container();
                  }
                });
            return myList;
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return LinearProgressIndicator(
            backgroundColor: Colors.red,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          );
        });
  }
}
