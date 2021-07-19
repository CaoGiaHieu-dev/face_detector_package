part of '../face_detector_package.dart';

class FaceDetectionGroupImage extends StatelessWidget {
  const FaceDetectionGroupImage({
    Key? key,
    required this.imageName,
    required this.title,
    this.titleStyle,
    this.dimesHeight = const SizedBox(
      height: 20,
    ),
    this.assetType = AssetType.Image,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
  }) : super(key: key);
  final String imageName;
  final String title;
  final TextStyle? titleStyle;
  final SizedBox dimesHeight;
  final EdgeInsetsGeometry padding;
  final AssetType assetType;
  String pathAssetImage(String name) => 'assets/images/detection/$name.png';
  String pathAssetGif(String name) => 'assets/gif/detection/$name.gif';
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Image.asset(
            assetType == AssetType.Image
                ? pathAssetImage(imageName)
                : pathAssetGif(imageName),
            height: MediaQuery.of(context).size.height / 12,
          ),
          dimesHeight,
          Text(
            title,
            style: titleStyle ??
                Theme.of(context).textTheme.bodyText1?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
