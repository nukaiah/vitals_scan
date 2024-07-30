import 'package:biosensesignal_flutter_sdk/images/image_data.dart'
    as sdk_image_data;
import 'package:biosensesignal_flutter_sdk/session/session_state.dart';
import 'package:biosensesignal_flutter_sdk/ui/camera_preview_view.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:provider/provider.dart';
import 'package:vitals_scan/Buttons.dart';
import 'package:vitals_scan/ConfigModels.dart';
import 'package:vitals_scan/measurement_model.dart';
import 'package:vitals_scan/widget_size.dart';

Color btnClr = const Color(0xFF063cd1);
Color bgClr1 =  const Color(0xFFFFFFFF);

class MeasurementScreen extends StatefulWidget {
  ConfigurationModel configurationModel;

  MeasurementScreen({super.key,required this.configurationModel});

  @override
  State<MeasurementScreen> createState() => _MeasurementScreenState();
}

class _MeasurementScreenState extends State<MeasurementScreen> {
  @override
  Widget build(BuildContext context) {
    var warning =
        context.select<MeasurementModel, String?>((model) => model.warning);
    var error =
        context.select<MeasurementModel, String?>((model) => model.error);
    var finalResults = context
        .select<MeasurementModel, String?>((model) => model.finalResultsString);

    if (warning != null) {
      Fluttertoast.showToast(
          msg: warning,
          toastLength: Toast.LENGTH_SHORT,
          textColor: Colors.white);
    }

    if (error != null) {
      showAlert(context, null, error);
    }

    if (finalResults != null) {
      WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {

      });
    }


    var sex = widget.configurationModel.sex;
    var age = widget.configurationModel.age;
    var weight = widget.configurationModel.weight;

    return FocusDetector(
        onFocusLost: () {
          context.read<MeasurementModel>().screenInFocus(false,
              sex: sex,
              age: double.parse(age.toString()),
              weight: double.parse(weight.toString()));
        },
        onFocusGained: () {
          context.read<MeasurementModel>().screenInFocus(true,
              sex: sex,
              age: double.parse(age.toString()),
              weight: double.parse(weight.toString()));
        },
        child: Scaffold(
            appBar: AppBar(
              elevation: 0.0,
              backgroundColor: btnClr,
              iconTheme: IconThemeData(
                color: bgClr1
              ),
            ),
            body: const SafeArea(
              child: Column(children: [
                Expanded(
                    child: Stack(children: [
                  _CameraPreview(),
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _ImageValidity(),
                          _StartStopButton(),
                        ]),
                  )
                ])),
              ]),
            )));
  }

  void showAlert(BuildContext context, String? title, String message) {
    Future.delayed(Duration.zero, () {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: title != null ? Text(title) : null,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message.toString()),
              Text(showWarning(warning: message.toString().split(":")[1])),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Provider.of<MeasurementModel>(context,listen: false).screenInFocus(
                    true,
                    sex: widget.configurationModel.sex,
                    age: widget.configurationModel.age,
                    weight: widget.configurationModel.weight
                );
                Navigator.pop(context, 'OK');
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }
}

class _CameraPreview extends StatefulWidget {
  const _CameraPreview();

  @override
  _CameraPreviewState createState() => _CameraPreviewState();
}

class _CameraPreviewState extends State<_CameraPreview> {
  Size? size;

  @override
  Widget build(BuildContext context) {
    var sessionState = context
        .select<MeasurementModel, SessionState?>((model) => model.sessionState);
    if (sessionState == null || sessionState == SessionState.initializing) {
      return Container();
    }

    return WidgetSize(
        onChange: (size) => setState(() {
              this.size = size;
            }),
        child: SizedBox(
            width: double.infinity,
            child: AspectRatio(
                aspectRatio: 0.75,
                child: Stack(children: [
                  Stack(
                    children: <Widget>[
                      const CameraPreviewView(),
                      Image.asset('assets/rppg_video_mask.png'),
                      _FaceDetectionView(size: size)
                    ],
                  ),
                ]))));
  }
}

class _FaceDetectionView extends StatefulWidget {
  final Size? size;

  const _FaceDetectionView({required this.size});

  @override
  State<_FaceDetectionView> createState() => _FaceDetectionViewState();
}

class _FaceDetectionViewState extends State<_FaceDetectionView> {
  @override
  Widget build(BuildContext context) {
    var imageInfo = context.select<MeasurementModel, sdk_image_data.ImageData?>(
        (model) => model.imageData);
    if (imageInfo == null) {
      return Container();
    }

    var roi = imageInfo.roi;
    if (roi == null) {
      return Container();
    }

    var devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    var widthFactor = widget.size!.width / (imageInfo.imageWidth / devicePixelRatio);
    var heightFactor =
        widget.size!.height / (imageInfo.imageHeight / devicePixelRatio);
    return Positioned(
        left: (roi.left * widthFactor) / devicePixelRatio,
        top: (roi.top * heightFactor) / devicePixelRatio,
        child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(width: 4, color: const Color(0xff0653F4)),
              borderRadius: BorderRadius.circular(5),
            ),
            width: (roi.width * widthFactor) / devicePixelRatio,
            height: (roi.height * heightFactor) / devicePixelRatio));
  }
}

class _StartStopButton extends StatefulWidget {
  const _StartStopButton();

  @override
  State<_StartStopButton> createState() => _StartStopButtonState();
}

class _StartStopButtonState extends State<_StartStopButton> {
  @override
  Widget build(BuildContext context) {
    var state = context
        .select<MeasurementModel, SessionState?>((model) => model.sessionState);
    var opacity =
        (state == SessionState.ready || state == SessionState.processing)
            ? 1.0
            : 0.5;

    return Consumer<MeasurementModel>(builder: (context, mesCtrl, child) {
      return Opacity(
          opacity: opacity,
          child: Column(
            children: [
              state == SessionState.processing
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 100,
                          width: 100,
                          child: CircularProgressIndicator(
                            value: mesCtrl.seconds / 60,
                            strokeWidth: 10.0,
                            backgroundColor: btnClr.withOpacity(0.1),
                            color: btnClr,
                          ),
                        ),
                        Text(
                          "${mesCtrl.seconds < 10 ? "0${mesCtrl.seconds}" : mesCtrl.seconds} \nsec",
                        ),
                      ],
                    )
                  : const SizedBox(),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: fillButton(context,
                    load: false,
                    title: state == SessionState.processing ? "STOP" : "START",
                    onTap: () {
                  mesCtrl.startStopButtonClicked();
                }),
              ),
            ],
          ));
    });
  }
}

class _ImageValidity extends StatefulWidget {
  const _ImageValidity();

  @override
  State<_ImageValidity> createState() => _ImageValidityState();
}

class _ImageValidityState extends State<_ImageValidity> {
  @override
  Widget build(BuildContext context) {
    var showImageValidity = context
        .select<MeasurementModel, bool>((model) => model.showImageValidity);
    var imageValidityString = context
        .select<MeasurementModel, String>((model) => model.imageValidityString);

    return Center(
      child: Visibility(
        visible: showImageValidity,
        child: Container(
            color: const Color(0xFF3D3734),
            padding: const EdgeInsets.all(5.0),
            width: 180,
            child: Column(
              children: [
                const Text(
                  "Image Validity",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  imageValidityString,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                )
              ],
            )),
      ),
    );
  }
}


showWarning({warning}) {
  int serialNumber = int.parse(warning.toString());
  if (serialNumber == 4) {
    return "Your device is in low power mode, please turn off it to proceed further";
  }
  else if(serialNumber==14){
    return "Your device battery level below 20%. It should be above 20%";
  }
  else if(serialNumber==7009){
    return "Current Session has been expired.Click on ok to restart the session";
  }
  else {
    return "";
  }
}
