import 'package:flutter/material.dart';

import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'dart:core';
import 'package:url_launcher/url_launcher.dart';

class HomeDrawer extends StatefulWidget {
  @override
  _HomeDrawerState createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  final Uri _emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'yannichau@hotmail.com',
      queryParameters: {'subject': 'Wheels - Bug report'});

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wheels 🚌',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                    ),
                  ),
                  Text(
                    'Developed by cluelessyanni',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.teal,
            ),
          ),
          Card(
              child: ListTile(
            leading: Icon(Icons.settings),
            title: Text('設定'),
            subtitle: Text('English version coming soon ...'),
            onTap: () {
              // Update the state of the app.
              // ...
            },
          )),
          Card(
              child: ExpansionTile(
            leading: Icon(Icons.link),
            title: Text('連結'),
            subtitle: Text('各個巴士公司的網站'),
            children: [
              OutlineButton(
                  onPressed: () {
                    setState(() {
                      _launchURL("http://www.kmb.hk/tc/");
                    });
                  },
                  child: Text("九巴/龍運")),
              OutlineButton(
                  onPressed: () {
                    setState(() {
                      _launchURL("https://www.nwstbus.com.hk/home/default.aspx?intLangID=2");
                    });
                  },
                  child: Text("城巴/新巴")),
            ],
          )),
          Card(
              child: ListTile(
            leading: Icon(Icons.star),
            title: Text('I\'m feeling lucky'),
            subtitle: Text('Take on me!'),
            onTap: () {
              setState(() {
                _launchURL("https://www.chp.gov.hk/tc/index.html");
              });
            },
          )),
          Card(
              child: ListTile(
            leading: Icon(Icons.feedback),
            title: Text('Feedback'),
            subtitle: Text('歡迎轟炸我的 email！'),
            onTap: () {
              launch(_emailLaunchUri.toString());
              Navigator.pop(context);
            },
          )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text('聲明'),
              subtitle: Text(
                  '本 app 的資料庫及到站預報由九龍巴士（一九三三）有限公司及城巴/新巴（新創建集團成員）提供。如有任何資料配對錯漏，敬請原諒。誠邀您使用 feedback 功能匯報任何意見和 bug。謝謝！'),
            ),
          ),
        ],
      ),
    );
  }
}
