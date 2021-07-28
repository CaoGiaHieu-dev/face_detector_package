part of '../face_detector_package.dart';

class FaceDetectorView extends StatefulWidget {
  const FaceDetectorView({
    Key? key,
    this.sizeWidth = 50.0,
    this.sizeHeight = 50.0,
    required this.config,
    this.decriptionOfLookLeft,
    this.decriptionOfLookRight,
    this.decriptionOfEyesBlink,
    this.decriptionOfSmile,
    this.decriptionOfLookStraigh,
    this.decriptionOfConpeleted,
    required this.overlayColor,
    this.decriptionOfTakePortraits,
  }) : super(key: key);

  /// using full widge of device
  final double sizeWidth;
  final double sizeHeight;
  final FaceDetectorConfig config;
  final Color overlayColor;
  final String? decriptionOfLookLeft;
  final String? decriptionOfLookRight;
  final String? decriptionOfEyesBlink;
  final String? decriptionOfSmile;
  final String? decriptionOfLookStraigh;
  final String? decriptionOfConpeleted;
  final String? decriptionOfTakePortraits;

  String pathAssetImage(String name) => 'assets/images/detection/$name.png';
  @override
  _FaceDetectorViewState createState() => _FaceDetectorViewState();
}

class _FaceDetectorViewState extends State<FaceDetectorView> {
  late FaceDetectorConfig faceDetectorConfig;
  late int _step;
  @override
  void initState() {
    faceDetectorConfig = widget.config;
    _step = faceDetectorConfig.listDetectorType.length;
    faceDetectorConfig.startLiveFeed();
    super.initState();
  }

  @override
  void dispose() {
    faceDetectorConfig.stopLiveFeed();
    super.dispose();
  }

  bool onRunOneStep(int i) {
    var runOneStep = (60 / _step) * (FaceDetectorConfig.currentStep.value);
    if (i < runOneStep) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          flex: 12,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(1),
                child: ValueListenableBuilder<bool>(
                    valueListenable: FaceDetectorConfig.isReady,
                    builder: (context, snapshot, _) {
                      return snapshot
                          ? CameraPreview(FaceDetectorConfig.cameraController!)
                          : const Center(
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                              ),
                            );
                    }),
              ),
              CameraOverlay(
                colors: widget.overlayColor,
                width: widget.sizeWidth,
                height: widget.sizeHeight,
              ),
              Positioned(
                top: widget.sizeHeight / 4.1,
                child: RotationTransition(
                  turns: const AlwaysStoppedAnimation(240 / 360),
                  child: SizedBox.fromSize(
                    size:
                        Size(widget.sizeWidth * 0.84, widget.sizeHeight * 0.44),
                    child: Stack(
                      children: List.generate(60, (i) {
                        return Positioned.fill(
                          left: widget.sizeWidth * 0.46,
                          top: widget.sizeHeight * 0.24,
                          child: Transform(
                            transform: Matrix4.rotationZ(6.0 * i * 0.0174533),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Transform.rotate(
                                angle: 39.85,
                                child: ValueListenableBuilder(
                                    valueListenable:
                                        FaceDetectorConfig.currentStep,
                                    builder: (context, snapshot, _) {
                                      return Stack(
                                        children: <Widget>[
                                          AnimatedContainer(
                                            height: onRunOneStep(i) ? 30 : 0,
                                            duration:
                                                Duration(milliseconds: i * 30),
                                            child: Image.asset(
                                              widget.pathAssetImage(
                                                  'vector_blue'),
                                            ),
                                          ),
                                          AnimatedContainer(
                                            height: onRunOneStep(i) ? 0 : 30,
                                            duration:
                                                Duration(milliseconds: i * 30),
                                            child: Image.asset(
                                              widget.pathAssetImage(
                                                  'vector_white'),
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 5,
          child: StreamBuilder<bool>(
            stream: FaceDetectorConfig.onLastStep.stream,
            builder: (context, AsyncSnapshot<bool> snapshot) {
              return AnimatedSwitcher(
                duration: const Duration(seconds: 1),
                child: snapshot.data ?? false
                    ? Column(
                        children: [
                          Text(
                            widget.decriptionOfTakePortraits ??
                                'Take Portraits',
                            style:
                                Theme.of(context).textTheme.bodyText1?.copyWith(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                    ),
                          ),
                          const SizedBox(height: 40),
                          Container(
                            height: MediaQuery.of(context).size.height / 10,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () {
                                faceDetectorConfig.takePortraitsImage();
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : _FaceDetectorDetail(
                        step: faceDetectorConfig.step,
                        decriptionOfLookLeft: widget.decriptionOfLookLeft,
                        decriptionOfLookRight: widget.decriptionOfLookRight,
                        decriptionOfEyesBlink: widget.decriptionOfEyesBlink,
                        decriptionOfSmile: widget.decriptionOfSmile,
                        decriptionOfLookStraigh: widget.decriptionOfLookStraigh,
                        decriptionOfConpeleted: widget.decriptionOfConpeleted,
                      ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FaceDetectorDetail extends StatelessWidget {
  const _FaceDetectorDetail(
      {Key? key,
      required this.step,
      this.decriptionOfLookLeft,
      this.decriptionOfLookRight,
      this.decriptionOfEyesBlink,
      this.decriptionOfSmile,
      this.decriptionOfLookStraigh,
      this.decriptionOfConpeleted})
      : super(key: key);
  final ValueNotifier<DetectionType> step;
  final String? decriptionOfLookLeft;
  final String? decriptionOfLookRight;
  final String? decriptionOfEyesBlink;
  final String? decriptionOfSmile;
  final String? decriptionOfLookStraigh;
  final String? decriptionOfConpeleted;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: step,
        builder: (context, snapshot, _) {
          return AnimatedSwitcher(
            duration: const Duration(seconds: 1),
            child: FaceDetectionGroupImage(
              padding: const EdgeInsets.only(top: 10),
              key: UniqueKey(),
              imageName: snapshot == DetectionType.LOOK_LEFT
                  ? 'turn_left'
                  : snapshot == DetectionType.LOOK_RIGHT
                      ? 'turn_right'
                      : snapshot == DetectionType.EYES_BLINK
                          ? 'bling_eyes'
                          : snapshot == DetectionType.SMILE
                              ? 'smile'
                              : snapshot == DetectionType.LOOK_STRAIGHT
                                  ? 'face'
                                  : 'face',
              title: snapshot == DetectionType.LOOK_LEFT
                  ? decriptionOfLookLeft ?? 'Turn your face to the left'
                  : snapshot == DetectionType.LOOK_RIGHT
                      ? decriptionOfLookRight ?? 'Turn your face to the right'
                      : snapshot == DetectionType.EYES_BLINK
                          ? decriptionOfEyesBlink ?? "Let's blink"
                          : snapshot == DetectionType.SMILE
                              ? decriptionOfSmile ?? "Let's  smile"
                              : snapshot == DetectionType.LOOK_STRAIGHT
                                  ? decriptionOfLookStraigh ??
                                      'Keep your face straight'
                                  : decriptionOfConpeleted ?? 'Completed',
              assetType: (snapshot == DetectionType.LOOK_STRAIGHT)
                  ? AssetType.Image
                  : AssetType.GIF,
              titleStyle: Theme.of(context).textTheme.bodyText1?.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
            ),
          );
        });
  }
}
