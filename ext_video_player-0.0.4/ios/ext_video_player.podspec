#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'ext_video_player'
  s.version          = '0.0.3'
  s.summary          = 'Flutter Video Player'
  s.description      = <<-DESC
A Flutter plugin for playing back video on a Widget surface.
Downloaded by pub (not CocoaPods).
                       DESC
  s.homepage         = 'https://github.com/ponnamkarthik/ext_video_player'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = { 'Karthik Ponnam' => 'ponnamkarthik3@gmail.com' }
  s.source           = { :http => 'https://github.com/ponnamkarthik/ext_video_player/tree/master/packages/video_player/video_player' }
  s.documentation_url = 'https://pub.dev/packages/ext_video_player'
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  
  s.platform = :ios, '8.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
end

