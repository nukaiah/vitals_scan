library vitals_scan;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vitals_scan/ConfigModels.dart';
import 'package:vitals_scan/MeasurmentView.dart';


OpenScan(context,{required ConfigurationModel configurationModel}){
  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_)=>MeasurementScreen(configurationModel: configurationModel)), (route)=>false);
}
