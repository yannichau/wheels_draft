import 'package:flutter/material.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

Future<KMBannounceAPI> fetchKMBannounceAPI(String route, String bound) async {
  String url =
      "http://search.kmb.hk/KMBWebSite/Function/FunctionRequest.ashx/?action=getannounce&route=" +
          route +
          "&bound=" +
          bound;
  final response = await http.get(url);
  print(url);

  if (response.statusCode == 200) {
    return KMBannounceAPI.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load information');
  }
}

class KMBannounceAPI {
  List<KMBannounceAPIdata> announcelist;

  KMBannounceAPI({this.announcelist});

  factory KMBannounceAPI.fromJson(Map<String, dynamic> json) {
    var list = json["data"] as List;
    List<KMBannounceAPIdata> amendedList =
        list.map((i) => KMBannounceAPIdata.fromJson(i)).toList();

    return new KMBannounceAPI(
      announcelist: amendedList,
    );
  }
}

class KMBannounceAPIdata {
  //String kpiTitle;
  String kpiReferenceNo;
  //StringkrbpiidRouteNo;
  String kpiNoticeImageUrl;
  //String krbpiidBoundNo;
  String krbpiid;
  String kpiTitleTC;

  KMBannounceAPIdata({
    this.kpiNoticeImageUrl,
    this.kpiReferenceNo,
    this.kpiTitleTC,
    this.krbpiid,
  });

  KMBannounceAPIdata.fromJson(Map<String, dynamic> json) {
    kpiReferenceNo = json["kpi_referenceno"];
    kpiNoticeImageUrl = json["kpi_noticeimageurl"];
    krbpiid = json["krbpiid"];
    kpiTitleTC = json["kpi_title_chi"];
  }
}

class KMBAnnouncement extends StatefulWidget {
  final String route;
  final String bound;

  KMBAnnouncement({
    @required this.route,
    @required this.bound,
    Key key,
  }) : super(key: key);

  @override
  _KMBAnnouncementState createState() => _KMBAnnouncementState();
}

class _KMBAnnouncementState extends State<KMBAnnouncement> with AutomaticKeepAliveClientMixin{

 _launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url, forceWebView: true);
  } else {
    throw 'Could not launch $url';
  }
}


  Future<KMBannounceAPI> futureKMBannounceAPI;

  @override
  void initState() {
    super.initState();
    futureKMBannounceAPI = fetchKMBannounceAPI(widget.route, widget.bound);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<KMBannounceAPI>(
        future: futureKMBannounceAPI,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<KMBannounceAPIdata> list = snapshot.data.announcelist;
            ListView myList = new ListView.builder(
              shrinkWrap: true,
              itemCount: list.length,
              itemBuilder: (context, index) {
                if (list.length != 0) {
                  return Card(
                    child: ListTile(
                      title:Text(list[index].kpiTitleTC),
                      subtitle: Text(list[index].kpiReferenceNo + " , " + list[index].krbpiid),
                      onTap: () {
                        setState(() {
                          _launchURL("http://search.kmb.hk/KMBWebSite/AnnouncementPicture.ashx?url=" + list[index].kpiNoticeImageUrl);
                        });
                      },
                    )
                  );
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
        });
  }

  @override
  bool get wantKeepAlive => true;
}
