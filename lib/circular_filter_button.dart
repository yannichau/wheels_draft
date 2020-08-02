import 'package:flutter/material.dart';

class CircularFilterButton extends StatelessWidget {

  final double width;
  final double height;
  final Widget iconImage;
  final Function onClick;

  CircularFilterButton({this.width, this.height, this.iconImage, this.onClick});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      child: iconImage,
    );
  }
}