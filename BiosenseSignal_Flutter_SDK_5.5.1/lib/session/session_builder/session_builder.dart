// ignore_for_file: unused_field

import 'package:biosensesignal_flutter_sdk/images/image_data_listener.dart';
import 'package:biosensesignal_flutter_sdk/session/session.dart';
import 'package:biosensesignal_flutter_sdk/session/session_info_listener.dart';
import 'package:biosensesignal_flutter_sdk/vital_signs/vital_signs_listener.dart';
import 'package:biosensesignal_flutter_sdk/license/license_details.dart';

abstract class SessionBuilder {
  VitalSignsListener? _vitalSignsListener;
  SessionInfoListener? _sessionInfoListener;
  ImageDataListener? _imageDataListener;
  Map<String, dynamic>? _options;

  SessionBuilder withSessionInfoListener(
      SessionInfoListener? sessionInfoListener) {
    _sessionInfoListener = sessionInfoListener;
    return this;
  }

  SessionBuilder withVitalSignsListener(VitalSignsListener vitalSignsListener) {
    _vitalSignsListener = vitalSignsListener;
    return this;
  }

  SessionBuilder withImageDataListener(ImageDataListener imageDataListener) {
    _imageDataListener = imageDataListener;
    return this;
  }

  SessionBuilder withOptions(Map<String, dynamic> options) {
    _options = options;
    return this;
  }

  Future<Session> build(LicenseDetails licenseDetails);

  VitalSignsListener? get vitalSignListener => _vitalSignsListener;

  SessionInfoListener? get sessionInfoListener => _sessionInfoListener;

  ImageDataListener? get imageDataListener => _imageDataListener;

  Map<String, dynamic>? get options => _options;
}
