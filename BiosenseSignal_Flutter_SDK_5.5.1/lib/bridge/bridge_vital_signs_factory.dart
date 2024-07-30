import 'package:biosensesignal_flutter_sdk/vital_signs/confidence_level.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vital_sign_confidence.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vital_sign_types.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vitals/blood_pressure.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vitals/pns_zone.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vitals/rri.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vitals/sns_zone.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vitals/stress_level.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vitals/vital_sign.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vitals/vital_sign_blood_pressure.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vitals/vital_sign_respiration_rate.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vitals/vital_sign_pulse_rate.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vitals/vital_sign_hemoglobin.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vitals/vital_sign_hemoglobin_a1c.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vitals/vital_sign_lfhf.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vitals/vital_sign_mean_rri.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vitals/vital_sign_oxygen_saturation.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vitals/vital_sign_pns_index.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vitals/vital_sign_pns_zone.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vitals/vital_sign_prq.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vitals/vital_sign_rmssd.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vitals/vital_sign_rri.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vitals/vital_sign_sd1.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vitals/vital_sign_sd2.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vitals/vital_sign_sdnn.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vitals/vital_sign_sns_index.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vitals/vital_sign_sns_zone.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vitals/vital_sign_stress_index.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vitals/vital_sign_stress_level.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vitals/vital_sign_wellness_index.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vitals/vital_sign_wellness_level.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vital_signs_results.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vitals/wellness_level.dart';

Map<int, VitalSign Function(dynamic value, VitalSignConfidence? confidence)>
    vitalSignsResolver = {
  VitalSignTypes.pulseRate: (dynamic value, VitalSignConfidence? confidence) =>
      VitalSignPulseRate(value as int, confidence: confidence),
  VitalSignTypes.respirationRate:
      (dynamic value, VitalSignConfidence? confidence) =>
          VitalSignRespirationRate(value as int, confidence: confidence),
  VitalSignTypes.oxygenSaturation:
      (dynamic value, VitalSignConfidence? confidence) =>
          VitalSignOxygenSaturation(value as int),
  VitalSignTypes.sdnn: (dynamic value, VitalSignConfidence? confidence) =>
      VitalSignSdnn(value as int, confidence: confidence),
  VitalSignTypes.stressLevel:
      (dynamic value, VitalSignConfidence? confidence) =>
          VitalSignStressLevel(StressLevel.values[value as int]),
  VitalSignTypes.rri: (dynamic value, VitalSignConfidence? confidence) {
    var rri = List<dynamic>.from(value)
        .map((rriValue) => Rri.fromJson(Map<String, dynamic>.from(rriValue)))
        .toList();
    return VitalSignRri(rri, confidence: confidence);
  },
  VitalSignTypes.bloodPressure:
      (dynamic jsonValue, VitalSignConfidence? confidence) =>
          VitalSignBloodPressure(
              BloodPressure.fromJson(Map<String, dynamic>.from(jsonValue))),
  VitalSignTypes.stressIndex:
      (dynamic value, VitalSignConfidence? confidence) =>
          VitalSignStressIndex(value as int),
  VitalSignTypes.meanRri: (dynamic value, VitalSignConfidence? confidence) =>
      VitalSignMeanRri(value as int, confidence: confidence),
  VitalSignTypes.rmssd: (dynamic value, VitalSignConfidence? confidence) =>
      VitalSignRmssd(value as int),
  VitalSignTypes.sd1: (dynamic value, VitalSignConfidence? confidence) =>
      VitalSignSd1(value as int),
  VitalSignTypes.sd2: (dynamic value, VitalSignConfidence? confidence) =>
      VitalSignSd2(value as int),
  VitalSignTypes.prq: (dynamic value, VitalSignConfidence? confidence) =>
      VitalSignPrq(value as double, confidence: confidence),
  VitalSignTypes.pnsIndex: (dynamic value, VitalSignConfidence? confidence) =>
      VitalSignPnsIndex(value as double),
  VitalSignTypes.pnsZone: (dynamic value, VitalSignConfidence? confidence) =>
      VitalSignPnsZone(PnsZone.values[value as int]),
  VitalSignTypes.snsIndex: (dynamic value, VitalSignConfidence? confidence) =>
      VitalSignSnsIndex(value as double),
  VitalSignTypes.snsZone: (dynamic value, VitalSignConfidence? confidence) =>
      VitalSignSnsZone(SnsZone.values[value as int]),
  VitalSignTypes.wellnessIndex:
      (dynamic value, VitalSignConfidence? confidence) =>
          VitalSignWellnessIndex(value as int),
  VitalSignTypes.wellnessLevel:
      (dynamic value, VitalSignConfidence? confidence) =>
          VitalSignWellnessLevel(WellnessLevel.values[value as int]),
  VitalSignTypes.lfhf: (dynamic value, VitalSignConfidence? confidence) =>
      VitalSignLfhf(value),
  VitalSignTypes.hemoglobin: (dynamic value, VitalSignConfidence? confidence) =>
      VitalSignHemoglobin(value),
  VitalSignTypes.hemoglobinA1C:
      (dynamic value, VitalSignConfidence? confidence) =>
          VitalSignHemoglobinA1C(value),
};
VitalSign? createVitalSign(Map<String, dynamic> data) {
  return vitalSignsResolver[data['type']]?.call(data['value'], null);
}

VitalSignsResults createFinalResults(List<dynamic> resultsList) {
  var vitalSignsResults = VitalSignsResults();
  for (var result in resultsList) {
    var vitalSignInfo = Map<String, dynamic>.from(result);
    VitalSignConfidence? confidence;
    if (vitalSignInfo.containsKey("confidence")) {
      int confidenceLevel = vitalSignInfo["confidence"]["level"];
      confidence =
          VitalSignConfidence(level: ConfidenceLevel.values[confidenceLevel]);
    }

    var vitalSign = vitalSignsResolver[vitalSignInfo['type']]
        ?.call(vitalSignInfo['value'], confidence);
    if (vitalSign != null) {
      vitalSignsResults.setResult(vitalSign);
    }
  }

  return vitalSignsResults;
}
