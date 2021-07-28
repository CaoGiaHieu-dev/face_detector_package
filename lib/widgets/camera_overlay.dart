part of '../face_detector_package.dart';

class CameraOverlay extends StatelessWidget {
  const CameraOverlay({
    Key? key,
    required this.colors,
    required this.width,
    required this.height,
  }) : super(key: key);
  final Color colors;
  final double width;
  final double height;
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ClipPath(
        clipper: InvertedCircleClipper(width: width, height: height),
        child: Container(
          color: colors,
        ),
      ),
    );
  }
}

class InvertedCircleClipper extends CustomClipper<Path> {
  const InvertedCircleClipper({required this.width, required this.height});
  final double width;
  final double height;

  @override
  Path getClip(Size size) {
    return Path()
      ..addOval(Rect.fromCircle(center: Offset(width * 0.456, height * 0.43), radius: (height + width) * 0.17))
      ..addRect(Rect.fromLTWH(0.0, 0.0, width, height))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
