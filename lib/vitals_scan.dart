library vitals_scan;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vitals_scan/ConfigModels.dart';
import 'package:vitals_scan/MeasurmentView.dart';
import 'package:vitals_scan/measurement_model.dart';


openMeasure(BuildContext context,{required ConfigurationModel configurationModel}){
  return ChangeNotifierProvider(create: (_)=>MeasurementModel(),child: MeasurementScreen(configurationModel: configurationModel,),);
}