import Flutter
import MobileVLCKit
import UIKit

public class SwiftFlutterVlcPlayerPlugin: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {

        let factory = VLCViewFactory(registrar: registrar)
        registrar.register(factory, withId: "flutter_video_plugin/getVideoView")
    }
    
}

public class VLCViewFactory: NSObject, FlutterPlatformViewFactory {
        
    private var registrar: FlutterPluginRegistrar
    private var builder: VLCViewBuilder

    
    init(registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
        self.builder = VLCViewBuilder(registrar: registrar)
        super.init()
    }
    
    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        
        //        let arguments = args as? NSDictionary ?? [:]
        return builder.build(frame: frame, viewId: viewId)
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
    
}

public class VLCViewBuilder: NSObject, VlcPlayerApi{
    
    var players = [Int:VLCViewController]()
    private var registrar: FlutterPluginRegistrar
    private var messenger: FlutterBinaryMessenger
    
    init(registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
        self.messenger = registrar.messenger()
        super.init()
        //
        VlcPlayerApiSetup(messenger, self)
    }
    
    public func build(frame: CGRect, viewId: Int64) -> VLCViewController{
        //
        var vlcViewController: VLCViewController
        vlcViewController = VLCViewController(frame: frame, viewId: viewId, messenger: messenger)
        players[Int(viewId)] = vlcViewController
        return vlcViewController;
    }
    
    public func initialize(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        return
    }
    
    func getPlayer(textureId: NSNumber?) -> VLCViewController? {
      guard textureId != nil else {
        return nil
        
      }
        return players[Int(truncating: textureId! as NSNumber)]
    }
    
    public func create(_ input: CreateMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        let player = getPlayer(textureId: input.textureId)
        
        var isAssetUrl: Bool = false
        var mediaUrl: String = ""
        
        if(DataSourceType(rawValue: Int(truncating: input.type!)) == DataSourceType.ASSET){
            var assetPath: String
            if input.packageName != nil {
                assetPath = registrar.lookupKey(forAsset: input.uri ?? "" , fromPackage: input.packageName ?? "")
            } else {
                assetPath = registrar.lookupKey(forAsset: input.uri ?? "")
            }
            mediaUrl = assetPath
            isAssetUrl = true
        }else{
            mediaUrl = input.uri ?? ""
            isAssetUrl = false
        }
        
        player?.setMediaPlayerUrl(
            uri: mediaUrl,
            isAssetUrl: isAssetUrl,
            autoPlay: input.autoPlay?.boolValue ?? true,
            hwAcc: input.hwAcc?.intValue ?? HWAccellerationType.HW_ACCELERATION_AUTOMATIC.rawValue,
            options: input.options as? [String] ?? []
        )
    }
    
    public func dispose(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        let player = getPlayer(textureId: input.textureId)
        
        player?.dispose()
        players.removeValue(forKey: input.textureId as! Int)
    }
    
    public func setStreamUrl(_ input: SetMediaMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        let player = getPlayer(textureId: input.textureId)
        
        var isAssetUrl: Bool = false
        var mediaUrl: String = ""
        
        if(DataSourceType(rawValue: Int(truncating: input.type!)) == DataSourceType.ASSET){
            var assetPath: String
            if input.packageName != nil {
                assetPath = registrar.lookupKey(forAsset: input.uri ?? "" , fromPackage: input.packageName ?? "")
            } else {
                assetPath = registrar.lookupKey(forAsset: input.uri ?? "")
            }
            mediaUrl = assetPath
            isAssetUrl = true
        }else{
            mediaUrl = input.uri ?? ""
            isAssetUrl = false
        }
        player?.setMediaPlayerUrl(
            uri: mediaUrl,
            isAssetUrl: isAssetUrl,
            autoPlay: input.autoPlay?.boolValue ?? true,
            hwAcc: input.hwAcc?.intValue ?? HWAccellerationType.HW_ACCELERATION_AUTOMATIC.rawValue,
            options: []
        )
    }
    
    public func play(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        let player = getPlayer(textureId: input.textureId)
        player?.play()
    }
    
    public func pause(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        let player = getPlayer(textureId: input.textureId)
        
        player?.pause()
    }
    
    public func stop(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        let player = getPlayer(textureId: input.textureId)

        
        player?.stop()
    }
    
    public func isPlaying(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> BooleanMessage? {
        
        let player = getPlayer(textureId: input.textureId)
        
        let message: BooleanMessage = BooleanMessage()
        message.result = player?.isPlaying()
        return message
    }
    
    public func setLooping(_ input: LoopingMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        let player = getPlayer(textureId: input.textureId)

        player?.setLooping(isLooping: input.isLooping)
    }
    
    public func seek(to input: PositionMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        let player = getPlayer(textureId: input.textureId)
        
        player?.seek(position: input.position)
    }
    
    public func position(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> PositionMessage? {
        
        let player = getPlayer(textureId: input.textureId)

        let message: PositionMessage = PositionMessage()
        message.position = player?.position()
        return message
    }
    
    public func duration(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> DurationMessage? {
        
        let player = getPlayer(textureId: input.textureId)
        
        let message: DurationMessage = DurationMessage()
        message.duration = player?.duration()
        return message
    }
    
    public func setVolume(_ input: VolumeMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        let player = getPlayer(textureId: input.textureId)
        
        player?.setVolume(volume: input.volume)
    }
    
    public func getVolume(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> VolumeMessage? {
        
        let player = getPlayer(textureId: input.textureId)

        let message: VolumeMessage = VolumeMessage()
        message.volume = player?.getVolume()
        return message
    }
    
    public func setPlaybackSpeed(_ input: PlaybackSpeedMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        let player = getPlayer(textureId: input.textureId)
        
        player?.setPlaybackSpeed(speed: input.speed)
    }
    
    public func getPlaybackSpeed(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> PlaybackSpeedMessage? {
        
        let player = getPlayer(textureId: input.textureId)
        
        let message: PlaybackSpeedMessage = PlaybackSpeedMessage()
        message.speed = player?.getPlaybackSpeed()
        return message
    }
    
    public func takeSnapshot(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> SnapshotMessage? {
        
        let player = getPlayer(textureId: input.textureId)
        
        let message: SnapshotMessage = SnapshotMessage()
        message.snapshot = player?.takeSnapshot()
        return message
    }
    
    public func getSpuTracksCount(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> TrackCountMessage? {
        
        let player = getPlayer(textureId: input.textureId)

        let message: TrackCountMessage = TrackCountMessage()
        message.count = player?.getSpuTracksCount()
        return message
    }
    
    public func getSpuTracks(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> SpuTracksMessage? {
        
        let player = getPlayer(textureId: input.textureId)

        let message: SpuTracksMessage = SpuTracksMessage()
        message.subtitles = player?.getSpuTracks()
        return message
    }
    
    public func setSpuTrack(_ input: SpuTrackMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        let player = getPlayer(textureId: input.textureId)

        player?.setSpuTrack(spuTrackNumber: input.spuTrackNumber)
    }
    
    public func getSpuTrack(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> SpuTrackMessage? {
        
        let player = getPlayer(textureId: input.textureId)
        
        let message: SpuTrackMessage = SpuTrackMessage()
        message.spuTrackNumber = player?.getSpuTrack()
        return message
    }
    
    public func setSpuDelay(_ input: DelayMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        let player = getPlayer(textureId: input.textureId)
        
        player?.setSpuDelay(delay: input.delay)
    }
    
    public func getSpuDelay(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> DelayMessage? {
        
        let player = getPlayer(textureId: input.textureId)
        
        let message: DelayMessage = DelayMessage()
        message.delay = player?.getSpuDelay()
        return message
    }
    
    public func addSubtitleTrack(_ input: AddSubtitleMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        let player = getPlayer(textureId: input.textureId)
        
        player?.addSubtitleTrack(uri: input.uri, isSelected: input.isSelected)
    }
    
    public func getAudioTracksCount(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> TrackCountMessage? {
        
        let player = getPlayer(textureId: input.textureId)
        
        let message: TrackCountMessage = TrackCountMessage()
        message.count = player?.getAudioTracksCount()
        return message
    }
    
    public func getAudioTracks(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> AudioTracksMessage? {
        
        let player = getPlayer(textureId: input.textureId)
        
        let message: AudioTracksMessage = AudioTracksMessage()
        message.audios = player?.getAudioTracks()
        return message
    }
    
    public func setAudioTrack(_ input: AudioTrackMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        let player = getPlayer(textureId: input.textureId)
        
        player?.setAudioTrack(audioTrackNumber: input.audioTrackNumber)
    }
    
    public func getAudioTrack(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> AudioTrackMessage? {
        
        let player = getPlayer(textureId: input.textureId)
        
        let message: AudioTrackMessage = AudioTrackMessage()
        message.audioTrackNumber = player?.getAudioTrack()
        return message
    }
    
    public func setAudioDelay(_ input: DelayMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        let player = getPlayer(textureId: input.textureId)
        
        player?.setAudioDelay(delay: input.delay)
    }
    
    public func getAudioDelay(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> DelayMessage? {
        
        let player = getPlayer(textureId: input.textureId)
        
        let message: DelayMessage = DelayMessage()
        message.delay = player?.getAudioDelay()
        return message
    }
    
    public func addAudioTrack(_ input: AddAudioMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        let player = getPlayer(textureId: input.textureId)
        
        player?.addAudioTrack(uri: input.uri, isSelected: input.isSelected)
    }
    
    public func getVideoTracksCount(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> TrackCountMessage? {
        
        let player = getPlayer(textureId: input.textureId)
        
        let message: TrackCountMessage = TrackCountMessage()
        message.count = player?.getVideoTracksCount()
        return message
    }
    
    public func getVideoTracks(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> VideoTracksMessage? {
        
        let player = getPlayer(textureId: input.textureId)
        
        let message: VideoTracksMessage = VideoTracksMessage()
        message.videos = player?.getVideoTracks()
        return message
    }
    
    public func setVideoTrack(_ input: VideoTrackMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        let player = getPlayer(textureId: input.textureId)
        
        player?.setVideoTrack(videoTrackNumber: input.videoTrackNumber)
    }
    
    public func getVideoTrack(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> VideoTrackMessage? {
        
        let player = getPlayer(textureId: input.textureId)
        
        let message: VideoTrackMessage = VideoTrackMessage()
        message.videoTrackNumber = player?.getVideoTrack()
        return message
    }
    
    public func setVideoScale(_ input: VideoScaleMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        let player = getPlayer(textureId: input.textureId)
        
        player?.setVideoScale(scale: input.scale)
    }
    
    public func getVideoScale(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> VideoScaleMessage? {
        
        let player = getPlayer(textureId: input.textureId)
        
        let message: VideoScaleMessage = VideoScaleMessage()
        message.scale = player?.getVideoScale()
        return message
    }
    
    public func setVideoAspectRatio(_ input: VideoAspectRatioMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        let player = getPlayer(textureId: input.textureId)
        
        player?.setVideoAspectRatio(aspectRatio: input.aspectRatio)
    }
    
    public func getVideoAspectRatio(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> VideoAspectRatioMessage? {
        
        let player = getPlayer(textureId: input.textureId)

        let message: VideoAspectRatioMessage = VideoAspectRatioMessage()
        message.aspectRatio = player?.getVideoAspectRatio()
        return message
    }
    
    public func getAvailableRendererServices(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> RendererServicesMessage? {
        
        let player = getPlayer(textureId: input.textureId)

        let message: RendererServicesMessage = RendererServicesMessage()
        message.services = player?.getAvailableRendererServices()
        return message
    }
    
    public func startRendererScanning(_ input: RendererScanningMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        let player = getPlayer(textureId: input.textureId)
        
        player?.startRendererScanning()
    }
    
    public func stopRendererScanning(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        let player = getPlayer(textureId: input.textureId)

        player?.stopRendererScanning()
    }
    
    public func getRendererDevices(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> RendererDevicesMessage? {
        
        let player = getPlayer(textureId: input.textureId)
        
        let message: RendererDevicesMessage = RendererDevicesMessage()
        message.rendererDevices = player?.getRendererDevices()
        return message
    }
    
    public func cast(toRenderer input: RenderDeviceMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        let player = getPlayer(textureId: input.textureId)
        
        player?.cast(rendererDevice: input.rendererDevice)
    }
}


public class VLCViewController: NSObject, FlutterPlatformView {
    
    var hostedView: UIView
    var vlcMediaPlayer: VLCMediaPlayer
    var mediaEventChannel: FlutterEventChannel
    let mediaEventChannelHandler: VLCPlayerEventStreamHandler
    var rendererEventChannel: FlutterEventChannel
    let rendererEventChannelHandler: VLCRendererEventStreamHandler
    var rendererdiscoverers: [VLCRendererDiscoverer] = [VLCRendererDiscoverer]()
    
    public func view() -> UIView {
        return hostedView
    }
    
    init(frame: CGRect, viewId: Int64, messenger:FlutterBinaryMessenger) {
        
        let mediaEventChannel = FlutterEventChannel(
            name: "flutter_video_plugin/getVideoEvents_\(viewId)",
            binaryMessenger: messenger
        )
        let rendererEventChannel = FlutterEventChannel(
            name: "flutter_video_plugin/getRendererEvents_\(viewId)",
            binaryMessenger: messenger
        )
        
        self.hostedView = UIView(frame: frame)
        self.vlcMediaPlayer = VLCMediaPlayer()
//        self.vlcMediaPlayer.libraryInstance.debugLogging = true
//        self.vlcMediaPlayer.libraryInstance.debugLoggingLevel = 3
        self.mediaEventChannel = mediaEventChannel
        self.mediaEventChannelHandler = VLCPlayerEventStreamHandler()
        self.rendererEventChannel = rendererEventChannel
        self.rendererEventChannelHandler = VLCRendererEventStreamHandler()
        //
        self.mediaEventChannel.setStreamHandler(mediaEventChannelHandler)
        self.rendererEventChannel.setStreamHandler(rendererEventChannelHandler)
        self.vlcMediaPlayer.drawable = self.hostedView
        self.vlcMediaPlayer.delegate = self.mediaEventChannelHandler
    }
    
    public func play() {
        self.vlcMediaPlayer.play()
    }
    
    public func pause() {
        
        self.vlcMediaPlayer.pause()
    }
    
    public func stop() {
        
        self.vlcMediaPlayer.stop()
    }
    
    public func isPlaying() -> NSNumber?{
        
        return self.vlcMediaPlayer.isPlaying as NSNumber
    }
    
    public func setLooping(isLooping: NSNumber?) {
        
        let enableLooping = isLooping?.boolValue ?? false;
        self.vlcMediaPlayer.media.addOption(enableLooping ? "--loop" : "--no-loop")
    }
    
    public func seek(position: NSNumber?) {
        
        self.vlcMediaPlayer.time = VLCTime(number: position ?? 0)
    }
    
    public func position() -> NSNumber? {
        
        return self.vlcMediaPlayer.time.value
    }
    
    public func duration() -> NSNumber? {
        
        return self.vlcMediaPlayer.media?.length.value ?? 0
        
    }
    
    public func setVolume(volume: NSNumber?) {
        
        self.vlcMediaPlayer.audio.volume = volume?.int32Value ?? 100
    }
    
    public func getVolume() -> NSNumber? {
        
        return NSNumber(value: self.vlcMediaPlayer.audio.volume)
    }
    
    public func setPlaybackSpeed(speed: NSNumber?) {
        
        self.vlcMediaPlayer.rate = speed?.floatValue ?? 1
    }
    
    public func getPlaybackSpeed() -> NSNumber? {
        
        return NSNumber(value: self.vlcMediaPlayer.rate)
    }
    
    public func takeSnapshot() -> String? {
        
        let drawable: UIView = self.vlcMediaPlayer.drawable as! UIView
        let size = drawable.frame.size
        UIGraphicsBeginImageContextWithOptions(size, _: false, _: 0.0)
        let rec = drawable.frame
        drawable.drawHierarchy(in: rec, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let byteArray = (image ?? UIImage()).pngData()
        //
        return byteArray?.base64EncodedString()
    }
    
    public func getSpuTracksCount() -> NSNumber? {
        
        return NSNumber(value: self.vlcMediaPlayer.numberOfSubtitlesTracks)
    }
    
    public func getSpuTracks() -> [Int:String]? {
        
        return self.vlcMediaPlayer.subtitles()
    }
    
    public func setSpuTrack(spuTrackNumber: NSNumber?) {
        
        self.vlcMediaPlayer.currentVideoSubTitleIndex = spuTrackNumber?.int32Value ?? 0
    }
    
    public func getSpuTrack() -> NSNumber? {
        
        return NSNumber(value: self.vlcMediaPlayer.currentVideoSubTitleIndex)
    }
    
    public func setSpuDelay(delay: NSNumber?) {
        
        self.vlcMediaPlayer.currentVideoSubTitleDelay = delay?.intValue ?? 0
    }
    
    public func getSpuDelay() -> NSNumber? {
        
        return NSNumber(value: self.vlcMediaPlayer.currentVideoSubTitleDelay)
    }
    
    public func addSubtitleTrack(uri: String?, isSelected: NSNumber?) {
        
        // todo: check for file type
        guard let urlString = uri,
              let url = URL(string: urlString)
        else {
            return
        }
        self.vlcMediaPlayer.addPlaybackSlave(
            url,
            type: VLCMediaPlaybackSlaveType.subtitle,
            enforce: isSelected?.boolValue ?? true
        )
    }
    
    public func getAudioTracksCount() -> NSNumber? {
        
        return NSNumber(value: self.vlcMediaPlayer.numberOfAudioTracks)
    }
    
    public func getAudioTracks() -> [Int:String]? {
        
        return self.vlcMediaPlayer.audioTracks()
    }
    
    public func setAudioTrack(audioTrackNumber: NSNumber?) {
        
        self.vlcMediaPlayer.currentAudioTrackIndex = audioTrackNumber?.int32Value ?? 0
    }
    
    public func getAudioTrack() -> NSNumber? {
        
        return NSNumber(value: self.vlcMediaPlayer.currentAudioTrackIndex)
    }
    
    public func setAudioDelay(delay: NSNumber?) {
        
        self.vlcMediaPlayer.currentAudioPlaybackDelay = delay?.intValue ?? 0
    }
    
    public func getAudioDelay() -> NSNumber? {
        
        return NSNumber(value: self.vlcMediaPlayer.currentAudioPlaybackDelay)
    }
    
    public func addAudioTrack(uri: String?, isSelected: NSNumber?) {
        
        // todo: check for file type
        guard let urlString = uri,
              let url = URL(string: urlString)
        else {
            return
        }
        self.vlcMediaPlayer.addPlaybackSlave(
            url,
            type: VLCMediaPlaybackSlaveType.audio,
            enforce: isSelected?.boolValue ?? true
        )
    }
    
    public func getVideoTracksCount() -> NSNumber? {
        
        return NSNumber(value: self.vlcMediaPlayer.numberOfVideoTracks)
    }
    
    public func getVideoTracks() -> [Int:String]? {
        
        return self.vlcMediaPlayer.videoTracks()
    }
    
    public func setVideoTrack(videoTrackNumber: NSNumber?) {
        
        self.vlcMediaPlayer.currentVideoTrackIndex = videoTrackNumber?.int32Value ?? 0
    }
    
    public func getVideoTrack() -> NSNumber? {
        
        return NSNumber(value: self.vlcMediaPlayer.currentVideoTrackIndex)
    }
    
    public func setVideoScale(scale: NSNumber?) {
        
        self.vlcMediaPlayer.scaleFactor = scale?.floatValue ?? 1
    }
    
    public func getVideoScale() -> NSNumber? {
        
        return NSNumber(value: self.vlcMediaPlayer.scaleFactor)
    }
    
    public func setVideoAspectRatio(aspectRatio: String?) {
        
        let aspectRatio = UnsafeMutablePointer<Int8>(
            mutating: (aspectRatio as NSString?)?.utf8String!
        )
        self.vlcMediaPlayer.videoAspectRatio = aspectRatio
    }
    
    public func getVideoAspectRatio() -> String? {
        
        return String(cString: self.vlcMediaPlayer.videoAspectRatio)
    }
    
    public func getAvailableRendererServices() -> [String]? {
        
        return self.vlcMediaPlayer.rendererServices()
    }
    
    public func startRendererScanning() {
        
        rendererdiscoverers.removeAll()
        rendererEventChannelHandler.renderItems.removeAll()
        // chromecast service name: "Bonjour_renderer"
        let rendererServices = self.vlcMediaPlayer.rendererServices()
        for rendererService in rendererServices{
            guard let rendererDiscoverer
                    = VLCRendererDiscoverer(name: rendererService) else {
                continue
            }
            rendererDiscoverer.delegate = self.rendererEventChannelHandler
            rendererDiscoverer.start()
            rendererdiscoverers.append(rendererDiscoverer)
        }
    }
    
    public func stopRendererScanning() {
        
        for rendererDiscoverer in rendererdiscoverers {
            rendererDiscoverer.stop()
            rendererDiscoverer.delegate = nil
        }
        rendererdiscoverers.removeAll()
        rendererEventChannelHandler.renderItems.removeAll()
        if(self.vlcMediaPlayer.isPlaying){
            self.vlcMediaPlayer.pause()
        }
        self.vlcMediaPlayer.setRendererItem(nil)
    }
    
    public func getRendererDevices() -> [String: String]? {
        
        var rendererDevices: [String: String] = [:]
        let rendererItems = rendererEventChannelHandler.renderItems
        for (_, item) in rendererItems.enumerated() {
            rendererDevices[item.name] = item.name
        }
        return rendererDevices
    }
    
    public func cast(rendererDevice: String?) {
        
        if (self.vlcMediaPlayer.isPlaying){
            self.vlcMediaPlayer.pause()
        }
        let rendererItems = self.rendererEventChannelHandler.renderItems
        let rendererItem = rendererItems.first{
            $0.name.contains(rendererDevice ?? "")
        }
        self.vlcMediaPlayer.setRendererItem(rendererItem)
        self.vlcMediaPlayer.play()
    }
    
    public func dispose(){
        //todo: dispose player & event handlers
    }
    
    func setMediaPlayerUrl(uri: String, isAssetUrl: Bool, autoPlay: Bool, hwAcc: Int, options: [String]){
        self.vlcMediaPlayer.stop()
        
        var media: VLCMedia
        if(isAssetUrl){
            guard let path = Bundle.main.path(forResource: uri, ofType: nil)
            else {
                return
            }
            media = VLCMedia(path: path)
        }
        else{
            guard let url = URL(string: uri)
            else {
                return
            }
            media = VLCMedia(url: url)
        }
        
        if(!options.isEmpty){
            for option in options {
                media.addOption(option)
            }
        }
        
        switch HWAccellerationType.init(rawValue: hwAcc)
        {
        case .HW_ACCELERATION_DISABLED:
            media.addOption("--codec=avcodec")
            break

        case .HW_ACCELERATION_DECODING:
            media.addOption("--codec=all")
            media.addOption(":no-mediacodec-dr")
            media.addOption(":no-omxil-dr")
            break

        case .HW_ACCELERATION_FULL:
            media.addOption("--codec=all")
            break

        case .HW_ACCELERATION_AUTOMATIC:
            break

        case .none:
            break
        }
        
        self.vlcMediaPlayer.media = media
//        self.vlcMediaPlayer.media.parse(withOptions: VLCMediaParsingOptions(VLCMediaParseLocal | VLCMediaFetchLocal | VLCMediaParseNetwork | VLCMediaFetchNetwork))
        self.vlcMediaPlayer.play()
        if(!autoPlay){
            self.vlcMediaPlayer.stop()
        }
    }
}


class VLCRendererEventStreamHandler: NSObject, FlutterStreamHandler, VLCRendererDiscovererDelegate {
    
    private var rendererEventSink: FlutterEventSink?
    var renderItems:[VLCRendererItem] = [VLCRendererItem]()
    
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        
        rendererEventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        
        rendererEventSink = nil
        return nil
    }
    
    func rendererDiscovererItemAdded(_ rendererDiscoverer: VLCRendererDiscoverer, item: VLCRendererItem) {
        
        self.renderItems.append(item)
        
        guard let rendererEventSink = self.rendererEventSink else { return }
        rendererEventSink([
            "event": "attached",
            "id": item.name,
            "name" : item.name,
        ])
    }
    
    func rendererDiscovererItemDeleted(_ rendererDiscoverer: VLCRendererDiscoverer, item: VLCRendererItem) {
        
        if let index = renderItems.firstIndex(of: item) {
            renderItems.remove(at: index)
        }
        
        guard let rendererEventSink = self.rendererEventSink else { return }
        rendererEventSink([
            "event": "detached",
            "id": item.name,
            "name" : item.name,
        ])
    }
}

class VLCPlayerEventStreamHandler: NSObject, FlutterStreamHandler, VLCMediaPlayerDelegate, VLCMediaDelegate  {
    
    private var mediaEventSink: FlutterEventSink?
    
    func onListen(withArguments _: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        
        mediaEventSink = events
        return nil
    }
    
    func onCancel(withArguments _: Any?) -> FlutterError? {
        
        mediaEventSink = nil
        return nil
    }
    
    func mediaPlayerStateChanged(_ aNotification: Notification?) {
        guard let mediaEventSink = self.mediaEventSink else { return }
        
        let player = aNotification?.object as? VLCMediaPlayer
        let media = player?.media
        
//        let tracks: [Any] = media?.tracksInformation ?? [""] // [Any]
//        var track: NSDictionary
//        var height = 0
//        var width = 0
//        if (player?.currentVideoTrackIndex != nil) &&
//            (player?.currentVideoTrackIndex != -1) {
//            track = tracks[0] as! NSDictionary
//            height = (track["height"] as? Int) ?? 0
//            width = (track["width"] as? Int) ?? 0
//        }
        
        let height = player?.videoSize.height ?? 0
        let width = player?.videoSize.width ?? 0
        let audioTracksCount = player?.numberOfAudioTracks ?? 0
        let activeAudioTrack = player?.currentAudioTrackIndex ?? 0
        let spuTracksCount = player?.numberOfSubtitlesTracks ?? 0
        let activeSpuTrack = player?.currentVideoSubTitleIndex ?? 0
        let duration =  media?.length.value ?? 0
        let speed = player?.rate ?? 1
        let position = player?.time?.value?.intValue ?? 0
        let buffering = 100.0
        let isPlaying = player?.isPlaying ?? false
                
        switch player?.state
        {
        case .opening:
            mediaEventSink([
                "event":"opening",
            ])
            break
            
        case .paused:
            mediaEventSink([
                "event":"paused",
            ])
            break
            
        case .stopped:
            mediaEventSink([
                "event": "stopped",
            ])
            break
            
        case .playing:
            mediaEventSink([
                "event": "playing",
                "height": height,
                "width":  width,
                "speed": speed,
                "duration": duration,
                "audioTracksCount": audioTracksCount,
                "activeAudioTrack": activeAudioTrack,
                "spuTracksCount": spuTracksCount,
                "activeSpuTrack": activeSpuTrack,
            ])
            break
            
        case .ended:
            mediaEventSink([
                "event": "ended",
                "position": position
            ])
            break
            
        case .buffering:
            mediaEventSink([
                "event": "timeChanged",
                "height": height,
                "width":  width,
                "speed": speed,
                "duration": duration,
                "position": position,
                "buffer": buffering,
                "audioTracksCount": audioTracksCount,
                "activeAudioTrack": activeAudioTrack,
                "spuTracksCount": spuTracksCount,
                "activeSpuTrack": activeSpuTrack,
                "isPlaying": isPlaying,
            ])
            break
            
        case .error:
            /*mediaEventSink(
             FlutterError(
             code: "500",
             message: "Player State got an error",
             details: nil)
             )*/
            mediaEventSink([
                "event": "error",
            ])
            break
            
        case .esAdded:
            break
            
        default:
            break
        }
    }
    
    func mediaPlayerTimeChanged(_ aNotification: Notification!) {
        guard let mediaEventSink = self.mediaEventSink else { return }
        
        let player = aNotification?.object as? VLCMediaPlayer
        //
        let height = player?.videoSize.height ?? 0
        let width = player?.videoSize.width ?? 0
        let speed = player?.rate ?? 1
        let duration = player?.media?.length.value ?? 0
        let audioTracksCount = player?.numberOfAudioTracks ?? 0
        let activeAudioTrack = player?.currentAudioTrackIndex ?? 0
        let spuTracksCount = player?.numberOfSubtitlesTracks ?? 0
        let activeSpuTrack = player?.currentVideoSubTitleIndex ?? 0
        let buffering = 100.0
        let isPlaying = player?.isPlaying ?? false
        //
        if let position = player?.time.value {
            mediaEventSink([
                "event": "timeChanged",
                "height": height,
                "width":  width,
                "speed": speed,
                "duration": duration,
                "position": position,
                "buffer": buffering,
                "audioTracksCount": audioTracksCount,
                "activeAudioTrack": activeAudioTrack,
                "spuTracksCount": spuTracksCount,
                "activeSpuTrack": activeSpuTrack,
                "isPlaying": isPlaying,
            ])
        }
    }
}

enum DataSourceType: Int
{
    case ASSET = 0
    case NETWORK = 1
    case FILE = 2
}

enum HWAccellerationType: Int
{
    case HW_ACCELERATION_AUTOMATIC = 0
    case HW_ACCELERATION_DISABLED = 1
    case HW_ACCELERATION_DECODING = 2
    case HW_ACCELERATION_FULL = 3
}

extension VLCMediaPlayer {
    
    func subtitles() -> [Int: String] {
        guard let indexs = videoSubTitlesIndexes as? [Int],
              let names = videoSubTitlesNames as? [String],
              indexs.count == names.count
        else {
            return [:]
        }
        
        var subtitles: [Int: String] = [:]
        
        var i = 0
        for index in indexs {
            if index >= 0 {
                let name = names[i]
                subtitles[Int(index)] = name
            }
            i = i + 1
        }
        
        return subtitles
    }
    
    func audioTracks() -> [Int: String] {
        guard let indexs = audioTrackIndexes as? [Int],
              let names = audioTrackNames as? [String],
              indexs.count == names.count
        else {
            return [:]
        }
        
        var audios: [Int: String] = [:]
        
        var i = 0
        for index in indexs {
            if index >= 0 {
                let name = names[i]
                audios[Int(index)] = name
            }
            i = i + 1
        }
        
        return audios
    }
    
    func videoTracks() -> [Int: String]{
        
        guard let indexs = videoTrackIndexes as? [Int],
              let names = videoTrackNames as? [String],
              indexs.count == names.count
        else {
            return [:]
        }
        
        var videos: [Int: String] = [:]
        
        var i = 0
        for index in indexs {
            if index >= 0 {
                let name = names[i]
                videos[Int(index)] = name
            }
            i = i + 1
        }
        
        return videos
    }
    
    func rendererServices() -> [String]{
        
        let renderers = VLCRendererDiscoverer.list()
        var services : [String] = []
        
        renderers?.forEach({ (VLCRendererDiscovererDescription) in
            services.append(VLCRendererDiscovererDescription.name)
        })
        return services
    }
    
}



