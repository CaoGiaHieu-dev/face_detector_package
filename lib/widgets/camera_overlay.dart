part of '../face_detector_package.dart';

class CameraOverlay extends StatelessWidget {
  const CameraOverlay({Key? key, required this.colors, required this.rangeSize})
      : super(key: key);
  final Color colors;
  final double rangeSize;
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ClipPath(
        clipper: InvertedCircleClipper(rangeSize),
        child: Container(
          color: colors,
        ),
      ),
    );
  }
}

class InvertedCircleClipper extends CustomClipper<Path> {
  const InvertedCircleClipper(this.rangeSize);
  final double rangeSize;

  @override
  Path getClip(Size size) {
    return Path()
      ..addOval(Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: rangeSize * 0.323))
      ..addRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
