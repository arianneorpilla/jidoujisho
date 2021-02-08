#import "FlutterVlcPlayerPlugin.h"
#if __has_include(<flutter_vlc_player/flutter_vlc_player-Swift.h>)
#import <flutter_vlc_player/flutter_vlc_player-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_vlc_player-Swift.h"
#endif

@implementation FlutterVlcPlayerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterVlcPlayerPlugin registerWithRegistrar:registrar];
}
@end
