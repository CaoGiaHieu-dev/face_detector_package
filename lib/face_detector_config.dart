part of 'face_detector_package.dart';

class FaceDetectorConfig {
  /// if [DetectionDisplay] is default , it's will displayed in the order of the [listDetectorType]
  ///
  /// if [DetectionDisplay] is random , it's will displayed randomly in [listDetectorType]
  ///
  /// [listDetectorType] is list of [DetectionType] that's you want to use
  ///
  /// [doingStep] will take [int] step in your list live acction
  FaceDetectorConfig.init({
    required CameraType cameraType,
    required List<DetectionType> listDetectorType,
    int doingStep = 5,
    DetectionDisplay detectionDisplay = DetectionDisplay.DEFAULT,
    bool isEnableAudio = false,
    ResolutionPreset resolutionPreset = ResolutionPreset.low,
  })  : _cameraType = cameraType,
        _isEnableAudio = isEnableAudio,
        _resolutionPreset = resolutionPreset,
        _doingStep = doingStep,
        listDetectorType = listDetectorType,
        assert(
            listDetectorType
                .where(
                  (element) =>
                      element == DetectionType.SMILE ||
                      element == DetectionType.EYES_BLINK,
                )
                .isNotEmpty,
            'Must have DetectionType.SMILE or  DetectionType.EYES_BLINK'),
        assert(listDetectorType.length >= 2,
            'Dectector list must be more than 1 and less than 6 option') {
    if (detectionDisplay == DetectionDisplay.RANDOM) {
      listDetectorType.shuffle();
    }
    takeActionStep();
  }
  static final ValueNotifier<bool> isReady = ValueNotifier<bool>(false);
  static List<CameraDescription> _cameras = <CameraDescription>[];
  static CameraController? cameraController;
  static late FaceDetector _faceDetector;

  List<DetectionType> listDetectorType;
  final CameraType _cameraType;
  final bool _isEnableAudio;
  final ResolutionPreset _resolutionPreset;
  final int _doingStep;

  late ValueNotifier<DetectionType> step;
  static late ValueNotifier<int> currentStep;

  bool _isBusy = false;

  /// This will be stream camera image when once live action is success
  static StreamController<CameraImage> listenOnDataProcess =
      StreamController<CameraImage>.broadcast();

  /// This will be notification when you allready done all step
  static StreamController<bool> isFinish = StreamController<bool>.broadcast();

  Future<void> initFaceDetector() async {
    _cameras = await availableCameras();
    if (_cameras.length > 1) {
      cameraController = CameraController(
        _cameraType == CameraType.BACK ? _cameras[0] : _cameras[1],
        _resolutionPreset,
        enableAudio: _isEnableAudio,
      );
    } else {
      cameraController = CameraController(
        _cameras[0],
        _resolutionPreset,
        enableAudio: _isEnableAudio,
      );
    }

    _faceDetector = GoogleMlKit.vision.faceDetector(
      const FaceDetectorOptions(
        enableClassification: true,
        enableTracking: true,
      ),
    );
  }

  /// this method called when you done
  /// it's close stream listen so you can't resume listen on next time
  /// call this method when you already done
  static void disposeListen() {
    listenOnDataProcess.close();
    isFinish.close();
  }

  /// this method called when you finished listen on task
  /// it's doesn't close stream listen so you can resume listen on next time
  static void cleanListen() {
    isFinish.done;
    listenOnDataProcess.done;
  }

  void takeActionStep() {
    var _list = listDetectorType.take(_doingStep).toList();
    if (_list
        .where((element) =>
            element == DetectionType.EYES_BLINK ||
            element == DetectionType.SMILE)
        .isEmpty) {
      var listImportant = [DetectionType.EYES_BLINK, DetectionType.SMILE];
      listImportant.shuffle();
      var i = Random().nextInt(_list.length);
      _list.removeAt(i);
      _list.add(listImportant.first);
    }
    listDetectorType = _list;
  }

  Future<void> startLiveFeed() async {
    step = ValueNotifier(listDetectorType.first);
    currentStep = ValueNotifier(0);
    await initFaceDetector.call();
    if (_cameras.isNotEmpty) {
      await cameraController?.initialize();
      await cameraController?.startImageStream((CameraImage image) {
        isReady.value = true;
        _processCameraImage(image);
      });
    } else {
      isReady.value = true;
    }
  }

  Future<void> stopLiveFeed() async {
    await cameraController?.stopImageStream();
    await cameraController?.dispose();
    cameraController = null;
    isReady.value = false;
    rollback();
  }

  /// this method will be reset your step
  static void rollback() {
    currentStep.value = 0;
  }

  Future _processCameraImage(CameraImage image) async {
    final allBytes = WriteBuffer();
    for (var plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final imageSize = Size(image.width.toDouble(), image.height.toDouble());

    final camera = _cameras[1];
    final imageRotation =
        InputImageRotationMethods.fromRawValue(camera.sensorOrientation) ??
            InputImageRotation.Rotation_0deg;

    final inputImageFormat =
        InputImageFormatMethods.fromRawValue(image.format.raw) ??
            InputImageFormat.NV21;

    final planeData = image.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    final inputImage =
        InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

    await _processImage(inputImage, image);
  }

  void _changeStep({required CameraImage image}) {
    _isBusy = true;
    if (currentStep.value <= listDetectorType.length) {
      currentStep.value++;
      if (currentStep.value < listDetectorType.length) {
        step.value = listDetectorType[currentStep.value];
        _isBusy = false;
      } else {
        isFinish.add(true);
      }
    }
    listenOnDataProcess.sink.add(image);
  }

  bool _isRecognize(Face face) {
    if (face.boundingBox.left > -11 &&
        face.boundingBox.right < 350 &&
        face.boundingBox.top > 30 &&
        face.boundingBox.bottom < 300) {
      if (face.headEulerAngleY != null &&
          face.headEulerAngleY != null &&
          face.rightEyeOpenProbability != null &&
          face.smilingProbability != null) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<void> _processImage(InputImage inputImage, CameraImage image) async {
    if (_isBusy) return;
    final faces = await _faceDetector.processImage(inputImage);
    if (faces.isNotEmpty) {
      // left
      if (step.value == DetectionType.LOOK_LEFT) {
        for (var item in faces) {
          if (Platform.isAndroid) {
            if ((item.headEulerAngleY ?? -1) > 30 && _isRecognize(item)) {
              _changeStep(
                image: image,
              );
            }
          } else {
            if ((item.headEulerAngleY ?? 1) < -30 && _isRecognize(item)) {
              _changeStep(
                image: image,
              );
            }
          }
        }
        //right
      } else if (step.value == DetectionType.LOOK_RIGHT) {
        for (var item in faces) {
          if (Platform.isAndroid) {
            if ((item.headEulerAngleY ?? 1) < -30 && _isRecognize(item)) {
              _changeStep(
                image: image,
              );
            }
          } else {
            if ((item.headEulerAngleY ?? -1) > 30 && _isRecognize(item)) {
              _changeStep(
                image: image,
              );
            }
          }
        }
        //blink
      } else if (step.value == DetectionType.EYES_BLINK) {
        for (var item in faces) {
          if ((item.rightEyeOpenProbability ?? 1) < 0.02 ||
              (item.leftEyeOpenProbability ?? 1) < 0.02 && _isRecognize(item)) {
            _changeStep(
              image: image,
            );
          }
        }
        //smile
      } else if (step.value == DetectionType.SMILE) {
        for (var item in faces) {
          if ((item.smilingProbability ?? -1) > 0.5 && _isRecognize(item)) {
            _changeStep(
              image: image,
            );
          }
        }
        //stand
      } else if (step.value == DetectionType.LOOK_STRAIGHT) {
        for (var item in faces) {
          if (_isRecognize(item)) {
            if ((item.smilingProbability ?? -1) < 0.05 &&
                ((item.rightEyeOpenProbability ?? 1) > 0.5 &&
                    (item.leftEyeOpenProbability ?? 1) > 0.5) &&
                (item.headEulerAngleY ?? -1) > -1 &&
                (item.headEulerAngleY ?? -1) < 1) {
              _changeStep(
                image: image,
              );
            }
          }
        }
      }
    }
  }
}
