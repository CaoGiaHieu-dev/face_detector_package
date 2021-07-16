#import "FaceDetectorPackagePlugin.h"
#if __has_include(<face_detector_package/face_detector_package-Swift.h>)
#import <face_detector_package/face_detector_package-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "face_detector_package-Swift.h"
#endif

@implementation FaceDetectorPackagePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFaceDetectorPackagePlugin registerWithRegistrar:registrar];
}
@end
