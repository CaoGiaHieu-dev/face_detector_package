import 'package:flutter/material.dart';
import 'package:face_detector_package/face_detector_package.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final config = FaceDetectorConfig.init(
    cameraType: CameraType.FRONT,
    listDetectorType: const <DetectionType>[
      DetectionType.LOOK_LEFT,
      DetectionType.LOOK_RIGHT,
      DetectionType.EYES_BLINK,
      DetectionType.SMILE,
      DetectionType.LOOK_STRAIGHT,
    ],
  );
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.amber,
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: FaceDetectorView(
          config: config,
          size: 300,
        ),
      ),
    );
  }
}
