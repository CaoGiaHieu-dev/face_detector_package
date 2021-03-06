library face_detector_packages;

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:developer' as developer;

import 'package:pedantic/pedantic.dart';

part 'face_detector_config.dart';
part 'view/face_detector_view.dart';
part 'widgets/face_detection_group_image.dart';
part 'widgets/camera_overlay.dart';
part 'data/face_detector_data.dart';
