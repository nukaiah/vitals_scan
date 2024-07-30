import 'package:biosensesignal_flutter_sdk/bridge/bridge_channels.dart';
import 'package:biosensesignal_flutter_sdk/bridge/method_calls.dart';
import 'package:biosensesignal_flutter_sdk/fall_detection/fall_detection_listener.dart';
import 'package:biosensesignal_flutter_sdk/health_monitor_exception.dart';
import 'package:biosensesignal_flutter_sdk/ppg_device/ppg_device_info_listener.dart';
import 'package:biosensesignal_flutter_sdk/ppg_device/ppg_device_type.dart';
import 'package:biosensesignal_flutter_sdk/session/demographics/subject_demographic.dart';
import 'package:biosensesignal_flutter_sdk/session/measurement_mode.dart';
import 'package:biosensesignal_flutter_sdk/session/session.dart';
import 'package:biosensesignal_flutter_sdk/session/session_info_listener.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vital_signs_listener.dart';
import 'package:biosensesignal_flutter_sdk/license/license_details.dart';
import 'package:flutter/services.dart';

class PolarSessionBuilder {
  final String _deviceId;
  SubjectDemographic? _subjectDemographic;
  VitalSignsListener? _vitalSignsListener;
  SessionInfoListener? _sessionInfoListener;
  PPGDeviceInfoListener? _ppgDeviceInfoListener;
  FallDetectionListener? _fallDetectionListener;
  Map<String, dynamic>? _options;

  PolarSessionBuilder(this._deviceId);

  PolarSessionBuilder withSubjectDemographic(
      SubjectDemographic? subjectDemographic) {
    _subjectDemographic = subjectDemographic;
    return this;
  }

  PolarSessionBuilder withSessionInfoListener(
      SessionInfoListener? sessionInfoListener) {
    _sessionInfoListener = sessionInfoListener;
    return this;
  }

  PolarSessionBuilder withVitalSignsListener(
      VitalSignsListener vitalSignsListener) {
    _vitalSignsListener = vitalSignsListener;
    return this;
  }

  PolarSessionBuilder withPPGDeviceInfoListener(
      PPGDeviceInfoListener ppgDeviceInfoListener) {
    _ppgDeviceInfoListener = ppgDeviceInfoListener;
    return this;
  }

  PolarSessionBuilder withFallDetectionListener(
      FallDetectionListener fallDetectionListener) {
    _fallDetectionListener = fallDetectionListener;
    return this;
  }

  PolarSessionBuilder withOptions(Map<String, dynamic> options) {
    _options = options;
    return this;
  }

  String get deviceId => _deviceId;

  VitalSignsListener? get vitalSignListener => _vitalSignsListener;

  SessionInfoListener? get sessionInfoListener => _sessionInfoListener;

  PPGDeviceInfoListener? get ppgDeviceInfoListener => _ppgDeviceInfoListener;

  FallDetectionListener? get fallDetectionListener => _fallDetectionListener;

  Map<String, dynamic>? get options => _options;

  Future<Session> build(LicenseDetails licenseDetails) async {
    var session = Session(
        sessionInfoListener: sessionInfoListener,
        vitalSignsListener: vitalSignListener,
        ppgDeviceInfoListener: ppgDeviceInfoListener,
        fallDetectionListener: fallDetectionListener);

    try {
      await methodChannel.invokeMethod(MethodCalls.createPPGDeviceSession, {
        'measurementMode': MeasurementMode.ppgDevice.index,
        'licenseKey': licenseDetails.licenseKey,
        'productId': licenseDetails.productId,
        'deviceId': deviceId,
        'deviceType': PPGDeviceType.polar.index,
        'subjectSex': _subjectDemographic?.sex?.index,
        'subjectAge': _subjectDemographic?.age,
        'subjectWeight': _subjectDemographic?.weight,
        'fallDetection': _fallDetectionListener != null,
        'options': options
      });
    } on PlatformException catch (e) {
      throw HealthMonitorException(e.message as String, int.parse(e.code));
    }

    return session;
  }
}
