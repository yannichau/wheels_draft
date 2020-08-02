import 'package:flutter/material.dart';

//Currently unused

String _setImage(String operator, String lantauTag) {
    if (operator == "lwb") {
      return 'images/lwb.png';
    } else if (operator == "kmb") {
      return 'images/kmb.png';
    } else if (operator == "nwfb") {
      return 'images/nwfb.jpg';
    } else if (operator == "ctb") {
      return 'images/ctb.png';
    } else if (operator.contains("kmb") && operator.contains("ctb")) {
      return 'images/ctbkmb.png';
    }
    return 'images/kmbnwfb.png';
  }

  Icon _setTagIcon(String tag, String lantauTag) {
    if (lantauTag == "airport") {
      return Icon(
        Icons.flight_takeoff,
      );
    } else if (tag == "peak") {
      return Icon(Icons.directions_run);
    } else if (tag == "special") {
      return Icon(Icons.priority_high);
    } else if (tag == "racecourse") {
      return Icon(Icons.monetization_on);
    } else if (tag == "night") {
      return Icon(
        Icons.brightness_2,
        color: Colors.deepPurple,
      );
    } else if (tag == "border") {
      return Icon(Icons.leak_remove);
    } else if (tag == "school") {
      return Icon(Icons.school);
    } else if (tag == "hst") {
      return Icon(Icons.train);
    }
    return null;
  }

  String _setSubtitle(String remarks) {
    if (remarks != null) {
      return remarks;
    }
    return "";
  }