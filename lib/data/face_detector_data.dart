part of '../face_detector_package.dart';

enum CameraType { FRONT, BACK }

enum DetectionType {
  LOOK_LEFT,
  LOOK_RIGHT,
  LOOK_STRAIGHT,
  EYES_BLINK,
  SMILE,
}

enum DetectionDisplay {
  DEFAULT,
  RANDOM,
}
enum DetectionLastStep {
  NONE,
  TAKE_PORTRAITS,
}
enum AssetType {
  Image,
  GIF,
}
