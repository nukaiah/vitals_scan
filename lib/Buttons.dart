import 'package:flutter/material.dart';
import 'package:vitals_scan/MeasurmentView.dart';

Widget fillButton(context,
    {required bool load, required String title, required onTap}) {
  Size size = MediaQuery.of(context).size;
  return InkWell(
    hoverColor: Colors.transparent,
    focusColor: Colors.transparent,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    onTap: load ? null : onTap,
    child: AnimatedContainer(
      alignment: Alignment.center,
      height: 50,
      width: load ? 50 : size.width,
      duration: const Duration(milliseconds: 300),
      decoration:
      BoxDecoration(color: btnClr, borderRadius: BorderRadius.circular(10)),
      child: load
          ? CircularProgressIndicator(color: bgClr1)
          : Text(title),
    ),
  );
}

Widget Cflatbtn({required title,required onTap,color}){
  return MaterialButton(
    color: color,
    onPressed: onTap,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10)),
    child: Text(title),
  );
}