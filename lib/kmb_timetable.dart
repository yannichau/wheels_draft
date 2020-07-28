import 'package:flutter/material.dart';
import 'dart:async' show Future;
//import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<KMBTimetableAPI> fetchKMBTimetableAPI(String route, String bound) async {
  String url = "http://search.kmb.hk/KMBWebSite/Function/FunctionRequest.ashx/?action=getschedule&route=" + route + "&bound=" + bound;
  final response = await http.get(url);
  print(url);

  if (response.statusCode == 200) {
    return KMBTimetableAPI.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load information');
  }
}

class KMBTimetableAPI{
  KMBTimetableAPIData data;

  KMBTimetableAPI({this.data});

  factory KMBTimetableAPI.fromJson(Map<String, dynamic> json) {
    return new KMBTimetableAPI(
      data: KMBTimetableAPIData.fromJson(json["data"]),
    );
  }
}

class KMBTimetableAPIData {
  List<KMBTimetableAPIInfo> normalSchedule;
  List<KMBTimetableAPIInfo> specialSchedule;

  KMBTimetableAPIData({this.normalSchedule, this.specialSchedule});

  factory KMBTimetableAPIData.fromJson(Map<String, dynamic> json) {
    var list1 = json["01"] as List;
     
    List<KMBTimetableAPIInfo> amendedList1 =
        list1.map((i) => KMBTimetableAPIInfo.fromJson(i)).toList();

    if (json["02"] != null) {
      var list2 = json["02"] as List;
      List<KMBTimetableAPIInfo> amendedList2 = list2.map((i) => KMBTimetableAPIInfo.fromJson(i)).toList();
      return new KMBTimetableAPIData(
        normalSchedule: amendedList1,
        specialSchedule: amendedList2,
      );
    } else {
      return new KMBTimetableAPIData(
        normalSchedule: amendedList1,
      );
    }
  }
}

class KMBTimetableAPIInfo {
  //bound 1: origin to destination
  //bound 2: destination to origin
  String dayType;
  String boundTime1;
  String boundText1;
  String boundTime2;
  String boundText2;  
  String originTC;
  String destTC;
  //String originEN;
  //String destEN;
  String serviceType;
  //String serviceTypeEN;
  String serviceTypeTC;
  //num orderSeq;
  String routeNo;

  KMBTimetableAPIInfo({
    this.dayType,
    this.boundText1,
    this.boundTime1,
    this.boundTime2,
    this.boundText2,
    this.originTC,
    this.destTC,
    this.serviceType,
    this.serviceTypeTC,
    //this.orderSeq,
    this.routeNo,
  });

  KMBTimetableAPIInfo.fromJson(Map<String, dynamic> json) {
    dayType = json["DayType"];
    boundTime1 = json["BoundTime1"];
    boundText1 = json["BoundText1"];
    boundTime2 = json["BoundTime2"];
    boundText2 = json["BoundText2"];
    originTC = json["Origin_Chi"];
    destTC = json["Destination_Chi"];
    serviceType = json["ServiceType"];
    serviceTypeTC = json["ServiceType_Chi"];
    //orderSeq = json["OrderSeq"];
    routeNo = json["Route"];   
  }

}

class KMBTimetable extends StatefulWidget {

  final String route;
  final String bound;

  KMBTimetable({
    @required this.route, 
    @required this.bound,
    Key key,
  }): super(key: key);

  @override
  _KMBTimetableState createState() => _KMBTimetableState();
}

class _KMBTimetableState extends State<KMBTimetable> with AutomaticKeepAliveClientMixin{

  Future<KMBTimetableAPI> futureKMBTT;

  Text _routeType(String routeType) {
    if (routeType.contains("MF")) {
      return Text("平日");
    } else if (routeType.contains("S")) {
      return Text("星期六");
    } else if (routeType.contains("H")) {
      return Text("星期日及紅日");
    }
  }

  @override
  void initState() {
    super.initState();
    futureKMBTT = fetchKMBTimetableAPI(widget.route, widget.bound);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        Card(
          child: ExpansionTile(
            title: Text("星期一至五"),
            //initiallyExpanded: true,
            children:[
              FutureBuilder<KMBTimetableAPI>(
              future: futureKMBTT,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<KMBTimetableAPIInfo> list = snapshot.data.data.normalSchedule; //MF
                  ListView myList = new ListView.builder(
                    shrinkWrap: true,
                    itemCount: list.length,
                    //itemExtent: 25,
                    itemBuilder: (context, index) {
                      print(widget.bound);
                      if (list[index].dayType.contains("MF")) {
                        if (widget.bound == "1") {
                          return ListTile(
                            visualDensity: VisualDensity.compact,
                            title: Text(list[index].boundText1),
                            trailing: Text("每" + list[index].boundTime1 + "分鐘一班"),
                          );
                        } else {
                          return ListTile(
                            visualDensity: VisualDensity.compact,
                            title: Text(list[index].boundText2),
                            trailing: Text("每" + list[index].boundTime2 + "分鐘一班"),
                          );
                        }
                      } else {
                        return Container();
                      }               
                    }
                  );
                  return myList;
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                return LinearProgressIndicator(
                  backgroundColor: Colors.red,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                );
              }
            ),
            ]
          ),
        ),
        Card(
          child: ExpansionTile(
            title: Text("星期六"),
            //initiallyExpanded: true,
            children:[
              FutureBuilder<KMBTimetableAPI>(
              future: futureKMBTT,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<KMBTimetableAPIInfo> list = snapshot.data.data.normalSchedule; //S
                  ListView myList = new ListView.builder(
                    shrinkWrap: true,
                    itemCount: list.length,
                    //itemExtent: 25,
                    itemBuilder: (context, index) {
                      print(widget.bound);
                      if (list[index].dayType.contains("S")) {
                        if (widget.bound == "1") {
                          return ListTile(
                            visualDensity: VisualDensity.compact,
                            title: Text(list[index].boundText1),
                            trailing: Text("每" + list[index].boundTime1 + "分鐘一班"),
                          );
                        } else {
                          return ListTile(
                            visualDensity: VisualDensity.compact,
                            title: Text(list[index].boundText2),
                            trailing: Text("每" + list[index].boundTime2 + "分鐘一班"),
                          );
                        }
                      } else {
                        return Container();
                      }               
                    }
                  );
                  return myList;
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                return LinearProgressIndicator(
                  backgroundColor: Colors.red,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                );
              }
            ),
            ]
          ),
        ),
        Card(
          child: ExpansionTile(
            title: Text("星期日及公眾假期"),
            //initiallyExpanded: true,
            children:[
              FutureBuilder<KMBTimetableAPI>(
              future: futureKMBTT,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<KMBTimetableAPIInfo> list = snapshot.data.data.normalSchedule; //MF
                  ListView myList = new ListView.builder(
                    shrinkWrap: true,
                    itemCount: list.length,
                    //itemExtent: 25,
                    itemBuilder: (context, index) {
                      print(widget.bound);
                      if (list[index].dayType.contains("H")) {
                        if (widget.bound == "1") {
                          return ListTile(
                            visualDensity: VisualDensity.compact,
                            title: Text(list[index].boundText1),
                            trailing: Text("每" + list[index].boundTime1 + "分鐘一班"),
                          );
                        } else {
                          return ListTile(
                            visualDensity: VisualDensity.compact,
                            title: Text(list[index].boundText2),
                            trailing: Text("每" + list[index].boundTime2 + "分鐘一班"),
                          );
                        }
                      } else {
                        return Container();
                      }               
                    }
                  );
                  return myList;
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                return LinearProgressIndicator(
                  backgroundColor: Colors.red,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                );
              }
            ),
            ]
          ),
        ),
        Card(
          child: ExpansionTile(
            title: Text("特別班次"),
            //initiallyExpanded: true,
            children:[
              FutureBuilder<KMBTimetableAPI>(
              future: futureKMBTT,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<KMBTimetableAPIInfo> list = snapshot.data.data.specialSchedule; //MF
                  if (list != null) {
                    ListView myList = new ListView.builder(
                      shrinkWrap: true,
                      itemCount: list.length,
                      //itemExtent: 25,
                      itemBuilder: (context, index) {
                        print(widget.bound);
                          if (widget.bound == "1") {
                            return ListTile(
                              leading: _routeType(list[index].dayType),
                              title: Text(list[index].boundText1),
                              subtitle: Text(list[index].serviceTypeTC),
                            );
                          } else {
                            return ListTile(
                              leading: _routeType(list[index].dayType),
                              title: Text(list[index].boundText2),
                              subtitle: Text(list[index].serviceTypeTC),
                            );
                          }             
                      }
                    );
                    return myList;
                  }                  
                } 
                return Padding(
                  padding: const EdgeInsets.only(bottom:20),
                  child: Text("沒有特別班次資料"),
                );
              }
            ),
            ]
          ),
        ),
      ]
    );
  }

  @override
  bool get wantKeepAlive => true;
}