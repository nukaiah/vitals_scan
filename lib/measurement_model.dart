import 'dart:async';
import 'package:biosensesignal_flutter_sdk/images/image_validity.dart';
import 'package:biosensesignal_flutter_sdk/license/license_details.dart';
import 'package:biosensesignal_flutter_sdk/license/license_offline_measurements.dart';
import 'package:biosensesignal_flutter_sdk/session/demographics/sex.dart';
import 'package:biosensesignal_flutter_sdk/session/demographics/subject_demographic.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vitals/vital_sign_lfhf.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vitals/vital_sign_mean_rri.dart';
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
import 'package:flutter/material.dart';
import 'package:biosensesignal_flutter_sdk/images/image_data_listener.dart';
import 'package:biosensesignal_flutter_sdk/images/image_data.dart' as sdk_image_data;
import 'package:biosensesignal_flutter_sdk/session/session_builder/face_session_builder.dart';
import 'package:biosensesignal_flutter_sdk/session/session.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vital_sign_types.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vitals/vital_sign_pulse_rate.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vital_signs_listener.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vital_signs_results.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vitals/vital_sign.dart';
import 'package:biosensesignal_flutter_sdk/alerts/warning_data.dart';
import 'package:biosensesignal_flutter_sdk/alerts/error_data.dart';
import 'package:biosensesignal_flutter_sdk/license/license_info.dart';
import 'package:biosensesignal_flutter_sdk/session/session_state.dart';
import 'package:biosensesignal_flutter_sdk/session/session_enabled_vital_signs.dart';
import 'package:biosensesignal_flutter_sdk/session/session_info_listener.dart';
import 'package:biosensesignal_flutter_sdk/alerts/alert_codes.dart';
import 'package:biosensesignal_flutter_sdk/health_monitor_exception.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock/wakelock.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vitals/vital_sign_blood_pressure.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vitals/vital_sign_hemoglobin.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vitals/vital_sign_hemoglobin_a1c.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vitals/vital_sign_oxygen_saturation.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vitals/vital_sign_respiration_rate.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vitals/vital_sign_stress_index.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vitals/vital_sign_stress_level.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vitals/vital_sign_wellness_index.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vitals/vital_sign_wellness_level.dart';

class MeasurementModel extends ChangeNotifier
    implements SessionInfoListener, VitalSignsListener, ImageDataListener {

  final licenseKey = "2E539C-65BB9A-4EA68E-D2593C-D8DE78-5FFB13";
  final measurementDuration = 60;
  Session? _session;
  sdk_image_data.ImageData? imageData;
  bool isStopped = false;

  String? error;
  String? warning;
  SessionState? sessionState;
  String? finalResultsString;
  String? confidenceLevels;
  String imageValidityString = "";
  bool showImageValidity = false;

  screenInFocus(bool focus, {required sex, required age, required weight}) async {
    if (focus) {
      if (!await _requestCameraPermission()) {
        return;
      }

      _createSession(sex: sex,age:age,weight:weight);
    } else {
      _terminateSession();
    }
  }

  void startStopButtonClicked() {
    showImageValidity = false;
    switch (sessionState) {
      case SessionState.ready:
        _startMeasuring();
        break;
      case SessionState.processing:
        _stopMeasuring();
        break;
      default:
        break;
    }
  }

  @override
  void onImageData(sdk_image_data.ImageData imageData) {
    this.imageData = imageData;
    if (imageData.imageValidity != ImageValidity.valid) {
      showImageValidity = true;
      switch (imageData.imageValidity) {
        case ImageValidity.invalidDeviceOrientation:
          imageValidityString = "Invalid Orientation";
          break;
        case ImageValidity.invalidRoi:
          imageValidityString = "Face Not Detected";
          break;
        case ImageValidity.tiltedHead:
          imageValidityString = "Titled Head";
          break;
        case ImageValidity.faceTooFar:
          imageValidityString = "You are Too Far";
          break;
        case ImageValidity.unevenLight:
          imageValidityString = "Uneven Lighting";
          break;
      }
    } else {
      showImageValidity = false;
    }
    notifyListeners();
  }

  @override
  void onVitalSign(VitalSign vitalSign) {
  }

  @override
  void onFinalResults(VitalSignsResults finalResults) async {
    var wellnessIndex = (finalResults.getResult(VitalSignTypes.wellnessIndex) as VitalSignWellnessIndex?)?.value;
    var wellnessLevel = (finalResults.getResult(VitalSignTypes.wellnessLevel) as VitalSignWellnessLevel?)?.value;
    var pulseRate = (finalResults.getResult(VitalSignTypes.pulseRate) as VitalSignPulseRate?)?.value;
    var respirationRate = (finalResults.getResult(VitalSignTypes.respirationRate) as VitalSignRespirationRate?)?.value ;
    var stressLevel = (finalResults.getResult(VitalSignTypes.stressLevel) as VitalSignStressLevel?)?.value ;
    var stressIndex = (finalResults.getResult(VitalSignTypes.stressIndex) as VitalSignStressIndex?)?.value ;
    var oxygenSaturation = (finalResults.getResult(VitalSignTypes.oxygenSaturation) as VitalSignOxygenSaturation?)?.value;
    var bloodPressure = (finalResults.getResult(VitalSignTypes.bloodPressure) as VitalSignBloodPressure?)?.value ;
    var hemoglobin = (finalResults.getResult(VitalSignTypes.hemoglobin) as VitalSignHemoglobin?)?.value ;
    var hemoglobinA1C = (finalResults.getResult(VitalSignTypes.hemoglobinA1C) as VitalSignHemoglobinA1C?)?.value;
    var sdnn = (finalResults.getResult(VitalSignTypes.sdnn) as VitalSignSdnn?)?.value;
    var meanRri = (finalResults.getResult(VitalSignTypes.meanRri) as VitalSignMeanRri?)?.value;
    var prq = (finalResults.getResult(VitalSignTypes.prq) as VitalSignPrq?)?.value;
    var lfhf = (finalResults.getResult(VitalSignTypes.lfhf) as VitalSignLfhf?)?.value;
    var pnsIndex = (finalResults.getResult(VitalSignTypes.pnsIndex) as VitalSignPnsIndex?)?.value;
    var pnsZone = (finalResults.getResult(VitalSignTypes.pnsZone) as VitalSignPnsZone?)?.value;
    var rmSsd = (finalResults.getResult(VitalSignTypes.rmssd) as VitalSignRmssd?)?.value;
    var rri = (finalResults.getResult(VitalSignTypes.rri) as VitalSignRri?)?.value;
    var sd1 = (finalResults.getResult(VitalSignTypes.sd1) as VitalSignSd1?)?.value;
    var sd2 = (finalResults.getResult(VitalSignTypes.sd2) as VitalSignSd2?)?.value;
    var snsIndex = (finalResults.getResult(VitalSignTypes.snsIndex) as VitalSignSnsIndex?)?.value;
    var snsZone = (finalResults.getResult(VitalSignTypes.snsZone) as VitalSignSnsZone?)?.value;



    var pulseRateConfidence = (finalResults.getResult(VitalSignTypes.pulseRate) as VitalSignPulseRate?)?.confidence!.level.name;
    var respirationRateConfidence = (finalResults.getResult(VitalSignTypes.respirationRate) as VitalSignRespirationRate?)?.confidence!.level.name;
    var sdnnConfidence = (finalResults.getResult(VitalSignTypes.sdnn) as VitalSignSdnn?)?.confidence!.level.name;
    var meanRRiConfidence = (finalResults.getResult(VitalSignTypes.meanRri) as VitalSignMeanRri?)?.confidence!.level.name;
    var prqConfidence = (finalResults.getResult(VitalSignTypes.prq) as VitalSignPrq?)?.confidence!.level.name;
    if(isStopped){
      finalResultsString = null;
      confidenceLevels = null;
    }
    else{
      HapticFeedback.vibrate();
      finalResultsString = "$wellnessIndex,$wellnessLevel,$pulseRate,$respirationRate,$stressLevel,$stressIndex,$oxygenSaturation,$bloodPressure,$hemoglobin,$hemoglobinA1C,$sdnn,$meanRri,$prq,$lfhf,$pnsIndex,$pnsZone,$rmSsd,$rri,$sd1,$sd2,$snsIndex,$snsZone";
      confidenceLevels = "$pulseRateConfidence,$respirationRateConfidence,$sdnnConfidence,$meanRRiConfidence,$prqConfidence";
    }
    notifyListeners();
  }

  @override
  void onWarning(WarningData warningData) {
    if (warning != null) {
      return;
    }

    if (warningData.code == AlertCodes.measurementCodeMisdetectionDurationExceedsLimitWarning) {
    }

    warning = "Warning: ${warningData.code}";
    notifyListeners();
    Future.delayed(const Duration(seconds: 1), () {
      warning = null;
    });
  }

  @override
  void onError(ErrorData errorData) {
    error = "Error: ${errorData.code}";
    notifyListeners();
  }

  @override
  void onSessionStateChange(SessionState sessionState) {
    this.sessionState = sessionState;
    switch (sessionState) {
      case SessionState.ready:
        Wakelock.enable();
        break;
      case SessionState.terminating:
        Wakelock.disable();
        break;
      default:
        break;
    }

    notifyListeners();
  }

  @override
  void onEnabledVitalSigns(SessionEnabledVitalSigns enabledVitalSigns) {}

  @override
  void onLicenseInfo(LicenseInfo licenseInfo) {
    LicenseOfflineMeasurements? offlineMeasurements = licenseInfo.offlineMeasurements;
    if (offlineMeasurements != null) {
    }
  }

  Future<void> _createSession({required sex,required age,required weight}) async {
    if (_session != null) {
      await _terminateSession();
    }
    reset();
    try {
      SubjectDemographic subjectDemographic = SubjectDemographic(sex:sex=="Male"?Sex.male: Sex.female, age: age, weight: weight);
      _session = await FaceSessionBuilder()
          .withStrictMeasurementGuidance(true)
          .withSubjectDemographic(subjectDemographic)
          .withImageDataListener(this)
          .withVitalSignsListener(this)
          .withSessionInfoListener(this)
          .build(LicenseDetails(licenseKey));
    } on HealthMonitorException catch (e) {
      error = "Error: ${e.code}";
      notifyListeners();
    }
  }

  Future<void> _startMeasuring() async {
    try {
      reset();
      await _session?.start(measurementDuration);
      startTimer();
      isStopped = false;
      notifyListeners();
    } on HealthMonitorException catch (e) {
      error = "Error: ${e.code}";
    }
  }

  Future<void> _stopMeasuring() async {
    try {
      await _session?.stop();
      stopTimer();
      isStopped = true;
      reset();
    } on HealthMonitorException catch (e) {
      error = "Error: ${e.code}";
    }
  }

  Future<void> _terminateSession() async {
    await _session?.terminate();
    _session = null;
  }

  int seconds = 60;
  Timer? timer;

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (seconds > 0) {
        seconds--;
      } else {
        timer.cancel();
      }
      notifyListeners();
    });
  }
  void stopTimer(){
    seconds=60;
    timer?.cancel();
    notifyListeners();
  }

  void reset() {
    error = null;
    warning = null;
    finalResultsString = null;
    confidenceLevels = null;
    seconds = 60;
    notifyListeners();
  }

  Future<bool> _requestCameraPermission() async {
    PermissionStatus result;
    result = await Permission.camera.request();
    return result.isGranted;
  }
}
