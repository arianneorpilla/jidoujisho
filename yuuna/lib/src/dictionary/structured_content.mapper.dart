// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element

part of 'structured_content.dart';

class StructuredContentMapper extends ClassMapperBase<StructuredContent> {
  StructuredContentMapper._();

  static StructuredContentMapper? _instance;
  static StructuredContentMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = StructuredContentMapper._());
      StructuredContentTextNodeMapper.ensureInitialized();
      StructuredContentChildContentMapper.ensureInitialized();
      StructuredContentLineBreakMapper.ensureInitialized();
      StructuredContentImageMapper.ensureInitialized();
      StructuredContentLinkMapper.ensureInitialized();
      StructuredContentContainerMapper.ensureInitialized();
      StructuredContentStyledContainerMapper.ensureInitialized();
      StructuredContentTableElementMapper.ensureInitialized();
      StructuredContentMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'StructuredContent';

  static StructuredContent? _$content(StructuredContent v) => v.content;
  static const Field<StructuredContent, StructuredContent> _f$content =
      Field('content', _$content, opt: true, hook: ContentHook());

  @override
  final Map<Symbol, Field<StructuredContent, dynamic>> fields = const {
    #content: _f$content,
  };

  static StructuredContent _instantiate(DecodingData data) {
    throw MapperException.missingConstructor('StructuredContent');
  }

  @override
  final Function instantiate = _instantiate;

  static StructuredContent fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<StructuredContent>(map);
  }

  static StructuredContent fromJson(String json) {
    return ensureInitialized().decodeJson<StructuredContent>(json);
  }
}

mixin StructuredContentMappable {}

class StructuredContentTextNodeMapper
    extends SubClassMapperBase<StructuredContentTextNode> {
  StructuredContentTextNodeMapper._();

  static StructuredContentTextNodeMapper? _instance;
  static StructuredContentTextNodeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals
          .use(_instance = StructuredContentTextNodeMapper._());
      StructuredContentMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'StructuredContentTextNode';

  static String _$text(StructuredContentTextNode v) => v.text;
  static const Field<StructuredContentTextNode, String> _f$text =
      Field('text', _$text);
  static StructuredContent? _$content(StructuredContentTextNode v) => v.content;
  static const Field<StructuredContentTextNode, StructuredContent> _f$content =
      Field('content', _$content, hook: ContentHook());

  @override
  final Map<Symbol, Field<StructuredContentTextNode, dynamic>> fields = const {
    #text: _f$text,
    #content: _f$content,
  };

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = StructuredContentTextNode.checkType;
  @override
  late final ClassMapperBase superMapper =
      StructuredContentMapper.ensureInitialized();

  static StructuredContentTextNode _instantiate(DecodingData data) {
    return StructuredContentTextNode(text: data.dec(_f$text));
  }

  @override
  final Function instantiate = _instantiate;

  static StructuredContentTextNode fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<StructuredContentTextNode>(map);
  }

  static StructuredContentTextNode fromJson(String json) {
    return ensureInitialized().decodeJson<StructuredContentTextNode>(json);
  }
}

mixin StructuredContentTextNodeMappable {
  String toJson() {
    return StructuredContentTextNodeMapper.ensureInitialized()
        .encodeJson<StructuredContentTextNode>(
            this as StructuredContentTextNode);
  }

  Map<String, dynamic> toMap() {
    return StructuredContentTextNodeMapper.ensureInitialized()
        .encodeMap<StructuredContentTextNode>(
            this as StructuredContentTextNode);
  }

  StructuredContentTextNodeCopyWith<StructuredContentTextNode,
          StructuredContentTextNode, StructuredContentTextNode>
      get copyWith => _StructuredContentTextNodeCopyWithImpl(
          this as StructuredContentTextNode, $identity, $identity);
  @override
  String toString() {
    return StructuredContentTextNodeMapper.ensureInitialized()
        .stringifyValue(this as StructuredContentTextNode);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (runtimeType == other.runtimeType &&
            StructuredContentTextNodeMapper.ensureInitialized()
                .isValueEqual(this as StructuredContentTextNode, other));
  }

  @override
  int get hashCode {
    return StructuredContentTextNodeMapper.ensureInitialized()
        .hashValue(this as StructuredContentTextNode);
  }
}

extension StructuredContentTextNodeValueCopy<$R, $Out>
    on ObjectCopyWith<$R, StructuredContentTextNode, $Out> {
  StructuredContentTextNodeCopyWith<$R, StructuredContentTextNode, $Out>
      get $asStructuredContentTextNode => $base
          .as((v, t, t2) => _StructuredContentTextNodeCopyWithImpl(v, t, t2));
}

abstract class StructuredContentTextNodeCopyWith<
    $R,
    $In extends StructuredContentTextNode,
    $Out> implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? text});
  StructuredContentTextNodeCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _StructuredContentTextNodeCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, StructuredContentTextNode, $Out>
    implements
        StructuredContentTextNodeCopyWith<$R, StructuredContentTextNode, $Out> {
  _StructuredContentTextNodeCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<StructuredContentTextNode> $mapper =
      StructuredContentTextNodeMapper.ensureInitialized();
  @override
  $R call({String? text}) =>
      $apply(FieldCopyWithData({if (text != null) #text: text}));
  @override
  StructuredContentTextNode $make(CopyWithData data) =>
      StructuredContentTextNode(text: data.get(#text, or: $value.text));

  @override
  StructuredContentTextNodeCopyWith<$R2, StructuredContentTextNode, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _StructuredContentTextNodeCopyWithImpl($value, $cast, t);
}

class StructuredContentChildContentMapper
    extends SubClassMapperBase<StructuredContentChildContent> {
  StructuredContentChildContentMapper._();

  static StructuredContentChildContentMapper? _instance;
  static StructuredContentChildContentMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals
          .use(_instance = StructuredContentChildContentMapper._());
      StructuredContentMapper.ensureInitialized().addSubMapper(_instance!);
      StructuredContentMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'StructuredContentChildContent';

  static List<StructuredContent> _$children(StructuredContentChildContent v) =>
      v.children;
  static const Field<StructuredContentChildContent, List<StructuredContent>>
      _f$children = Field('children', _$children);
  static StructuredContent? _$content(StructuredContentChildContent v) =>
      v.content;
  static const Field<StructuredContentChildContent, StructuredContent>
      _f$content = Field('content', _$content, hook: ContentHook());

  @override
  final Map<Symbol, Field<StructuredContentChildContent, dynamic>> fields =
      const {
    #children: _f$children,
    #content: _f$content,
  };

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = StructuredContentChildContent.checkType;
  @override
  late final ClassMapperBase superMapper =
      StructuredContentMapper.ensureInitialized();

  static StructuredContentChildContent _instantiate(DecodingData data) {
    return StructuredContentChildContent(children: data.dec(_f$children));
  }

  @override
  final Function instantiate = _instantiate;

  static StructuredContentChildContent fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<StructuredContentChildContent>(map);
  }

  static StructuredContentChildContent fromJson(String json) {
    return ensureInitialized().decodeJson<StructuredContentChildContent>(json);
  }
}

mixin StructuredContentChildContentMappable {
  String toJson() {
    return StructuredContentChildContentMapper.ensureInitialized()
        .encodeJson<StructuredContentChildContent>(
            this as StructuredContentChildContent);
  }

  Map<String, dynamic> toMap() {
    return StructuredContentChildContentMapper.ensureInitialized()
        .encodeMap<StructuredContentChildContent>(
            this as StructuredContentChildContent);
  }

  StructuredContentChildContentCopyWith<StructuredContentChildContent,
          StructuredContentChildContent, StructuredContentChildContent>
      get copyWith => _StructuredContentChildContentCopyWithImpl(
          this as StructuredContentChildContent, $identity, $identity);
  @override
  String toString() {
    return StructuredContentChildContentMapper.ensureInitialized()
        .stringifyValue(this as StructuredContentChildContent);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (runtimeType == other.runtimeType &&
            StructuredContentChildContentMapper.ensureInitialized()
                .isValueEqual(this as StructuredContentChildContent, other));
  }

  @override
  int get hashCode {
    return StructuredContentChildContentMapper.ensureInitialized()
        .hashValue(this as StructuredContentChildContent);
  }
}

extension StructuredContentChildContentValueCopy<$R, $Out>
    on ObjectCopyWith<$R, StructuredContentChildContent, $Out> {
  StructuredContentChildContentCopyWith<$R, StructuredContentChildContent, $Out>
      get $asStructuredContentChildContent => $base.as(
          (v, t, t2) => _StructuredContentChildContentCopyWithImpl(v, t, t2));
}

abstract class StructuredContentChildContentCopyWith<
    $R,
    $In extends StructuredContentChildContent,
    $Out> implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, StructuredContent,
      ObjectCopyWith<$R, StructuredContent, StructuredContent>> get children;
  $R call({List<StructuredContent>? children});
  StructuredContentChildContentCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _StructuredContentChildContentCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, StructuredContentChildContent, $Out>
    implements
        StructuredContentChildContentCopyWith<$R, StructuredContentChildContent,
            $Out> {
  _StructuredContentChildContentCopyWithImpl(
      super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<StructuredContentChildContent> $mapper =
      StructuredContentChildContentMapper.ensureInitialized();
  @override
  ListCopyWith<$R, StructuredContent,
          ObjectCopyWith<$R, StructuredContent, StructuredContent>>
      get children => ListCopyWith($value.children,
          (v, t) => ObjectCopyWith(v, $identity, t), (v) => call(children: v));
  @override
  $R call({List<StructuredContent>? children}) =>
      $apply(FieldCopyWithData({if (children != null) #children: children}));
  @override
  StructuredContentChildContent $make(CopyWithData data) =>
      StructuredContentChildContent(
          children: data.get(#children, or: $value.children));

  @override
  StructuredContentChildContentCopyWith<$R2, StructuredContentChildContent,
      $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _StructuredContentChildContentCopyWithImpl($value, $cast, t);
}

class StructuredContentLineBreakMapper
    extends SubClassMapperBase<StructuredContentLineBreak> {
  StructuredContentLineBreakMapper._();

  static StructuredContentLineBreakMapper? _instance;
  static StructuredContentLineBreakMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals
          .use(_instance = StructuredContentLineBreakMapper._());
      StructuredContentMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'StructuredContentLineBreak';

  static StructuredContent? _$content(StructuredContentLineBreak v) =>
      v.content;
  static const Field<StructuredContentLineBreak, StructuredContent> _f$content =
      Field('content', _$content, hook: ContentHook());

  @override
  final Map<Symbol, Field<StructuredContentLineBreak, dynamic>> fields = const {
    #content: _f$content,
  };

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = StructuredContentLineBreak.checkType;
  @override
  late final ClassMapperBase superMapper =
      StructuredContentMapper.ensureInitialized();

  static StructuredContentLineBreak _instantiate(DecodingData data) {
    return StructuredContentLineBreak();
  }

  @override
  final Function instantiate = _instantiate;

  static StructuredContentLineBreak fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<StructuredContentLineBreak>(map);
  }

  static StructuredContentLineBreak fromJson(String json) {
    return ensureInitialized().decodeJson<StructuredContentLineBreak>(json);
  }
}

mixin StructuredContentLineBreakMappable {
  String toJson() {
    return StructuredContentLineBreakMapper.ensureInitialized()
        .encodeJson<StructuredContentLineBreak>(
            this as StructuredContentLineBreak);
  }

  Map<String, dynamic> toMap() {
    return StructuredContentLineBreakMapper.ensureInitialized()
        .encodeMap<StructuredContentLineBreak>(
            this as StructuredContentLineBreak);
  }

  StructuredContentLineBreakCopyWith<StructuredContentLineBreak,
          StructuredContentLineBreak, StructuredContentLineBreak>
      get copyWith => _StructuredContentLineBreakCopyWithImpl(
          this as StructuredContentLineBreak, $identity, $identity);
  @override
  String toString() {
    return StructuredContentLineBreakMapper.ensureInitialized()
        .stringifyValue(this as StructuredContentLineBreak);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (runtimeType == other.runtimeType &&
            StructuredContentLineBreakMapper.ensureInitialized()
                .isValueEqual(this as StructuredContentLineBreak, other));
  }

  @override
  int get hashCode {
    return StructuredContentLineBreakMapper.ensureInitialized()
        .hashValue(this as StructuredContentLineBreak);
  }
}

extension StructuredContentLineBreakValueCopy<$R, $Out>
    on ObjectCopyWith<$R, StructuredContentLineBreak, $Out> {
  StructuredContentLineBreakCopyWith<$R, StructuredContentLineBreak, $Out>
      get $asStructuredContentLineBreak => $base
          .as((v, t, t2) => _StructuredContentLineBreakCopyWithImpl(v, t, t2));
}

abstract class StructuredContentLineBreakCopyWith<
    $R,
    $In extends StructuredContentLineBreak,
    $Out> implements ClassCopyWith<$R, $In, $Out> {
  $R call();
  StructuredContentLineBreakCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _StructuredContentLineBreakCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, StructuredContentLineBreak, $Out>
    implements
        StructuredContentLineBreakCopyWith<$R, StructuredContentLineBreak,
            $Out> {
  _StructuredContentLineBreakCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<StructuredContentLineBreak> $mapper =
      StructuredContentLineBreakMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  StructuredContentLineBreak $make(CopyWithData data) =>
      StructuredContentLineBreak();

  @override
  StructuredContentLineBreakCopyWith<$R2, StructuredContentLineBreak, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _StructuredContentLineBreakCopyWithImpl($value, $cast, t);
}

class StructuredContentImageMapper
    extends SubClassMapperBase<StructuredContentImage> {
  StructuredContentImageMapper._();

  static StructuredContentImageMapper? _instance;
  static StructuredContentImageMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = StructuredContentImageMapper._());
      StructuredContentMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'StructuredContentImage';

  static String _$path(StructuredContentImage v) => v.path;
  static const Field<StructuredContentImage, String> _f$path =
      Field('path', _$path);
  static double? _$width(StructuredContentImage v) => v.width;
  static const Field<StructuredContentImage, double> _f$width =
      Field('width', _$width, opt: true);
  static double? _$height(StructuredContentImage v) => v.height;
  static const Field<StructuredContentImage, double> _f$height =
      Field('height', _$height, opt: true);
  static String? _$title(StructuredContentImage v) => v.title;
  static const Field<StructuredContentImage, String> _f$title =
      Field('title', _$title, opt: true);
  static String? _$description(StructuredContentImage v) => v.description;
  static const Field<StructuredContentImage, String> _f$description =
      Field('description', _$description, opt: true);
  static bool _$pixelated(StructuredContentImage v) => v.pixelated;
  static const Field<StructuredContentImage, bool> _f$pixelated =
      Field('pixelated', _$pixelated, opt: true, def: false);
  static String _$imageRendering(StructuredContentImage v) => v.imageRendering;
  static const Field<StructuredContentImage, String> _f$imageRendering =
      Field('imageRendering', _$imageRendering, opt: true, def: 'auto');
  static String _$appearance(StructuredContentImage v) => v.appearance;
  static const Field<StructuredContentImage, String> _f$appearance =
      Field('appearance', _$appearance, opt: true, def: 'auto');
  static bool _$background(StructuredContentImage v) => v.background;
  static const Field<StructuredContentImage, bool> _f$background =
      Field('background', _$background, opt: true, def: true);
  static bool _$collapsed(StructuredContentImage v) => v.collapsed;
  static const Field<StructuredContentImage, bool> _f$collapsed =
      Field('collapsed', _$collapsed, opt: true, def: false);
  static bool _$collapsible(StructuredContentImage v) => v.collapsible;
  static const Field<StructuredContentImage, bool> _f$collapsible =
      Field('collapsible', _$collapsible, opt: true, def: true);
  static String? _$verticalAlign(StructuredContentImage v) => v.verticalAlign;
  static const Field<StructuredContentImage, String> _f$verticalAlign =
      Field('verticalAlign', _$verticalAlign, opt: true);
  static String? _$sizeUnits(StructuredContentImage v) => v.sizeUnits;
  static const Field<StructuredContentImage, String> _f$sizeUnits =
      Field('sizeUnits', _$sizeUnits, opt: true);
  static StructuredContent? _$content(StructuredContentImage v) => v.content;
  static const Field<StructuredContentImage, StructuredContent> _f$content =
      Field('content', _$content, hook: ContentHook());

  @override
  final Map<Symbol, Field<StructuredContentImage, dynamic>> fields = const {
    #path: _f$path,
    #width: _f$width,
    #height: _f$height,
    #title: _f$title,
    #description: _f$description,
    #pixelated: _f$pixelated,
    #imageRendering: _f$imageRendering,
    #appearance: _f$appearance,
    #background: _f$background,
    #collapsed: _f$collapsed,
    #collapsible: _f$collapsible,
    #verticalAlign: _f$verticalAlign,
    #sizeUnits: _f$sizeUnits,
    #content: _f$content,
  };

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = StructuredContentImage.checkType;
  @override
  late final ClassMapperBase superMapper =
      StructuredContentMapper.ensureInitialized();

  static StructuredContentImage _instantiate(DecodingData data) {
    return StructuredContentImage(
        path: data.dec(_f$path),
        width: data.dec(_f$width),
        height: data.dec(_f$height),
        title: data.dec(_f$title),
        description: data.dec(_f$description),
        pixelated: data.dec(_f$pixelated),
        imageRendering: data.dec(_f$imageRendering),
        appearance: data.dec(_f$appearance),
        background: data.dec(_f$background),
        collapsed: data.dec(_f$collapsed),
        collapsible: data.dec(_f$collapsible),
        verticalAlign: data.dec(_f$verticalAlign),
        sizeUnits: data.dec(_f$sizeUnits));
  }

  @override
  final Function instantiate = _instantiate;

  static StructuredContentImage fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<StructuredContentImage>(map);
  }

  static StructuredContentImage fromJson(String json) {
    return ensureInitialized().decodeJson<StructuredContentImage>(json);
  }
}

mixin StructuredContentImageMappable {
  String toJson() {
    return StructuredContentImageMapper.ensureInitialized()
        .encodeJson<StructuredContentImage>(this as StructuredContentImage);
  }

  Map<String, dynamic> toMap() {
    return StructuredContentImageMapper.ensureInitialized()
        .encodeMap<StructuredContentImage>(this as StructuredContentImage);
  }

  StructuredContentImageCopyWith<StructuredContentImage, StructuredContentImage,
          StructuredContentImage>
      get copyWith => _StructuredContentImageCopyWithImpl(
          this as StructuredContentImage, $identity, $identity);
  @override
  String toString() {
    return StructuredContentImageMapper.ensureInitialized()
        .stringifyValue(this as StructuredContentImage);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (runtimeType == other.runtimeType &&
            StructuredContentImageMapper.ensureInitialized()
                .isValueEqual(this as StructuredContentImage, other));
  }

  @override
  int get hashCode {
    return StructuredContentImageMapper.ensureInitialized()
        .hashValue(this as StructuredContentImage);
  }
}

extension StructuredContentImageValueCopy<$R, $Out>
    on ObjectCopyWith<$R, StructuredContentImage, $Out> {
  StructuredContentImageCopyWith<$R, StructuredContentImage, $Out>
      get $asStructuredContentImage =>
          $base.as((v, t, t2) => _StructuredContentImageCopyWithImpl(v, t, t2));
}

abstract class StructuredContentImageCopyWith<
    $R,
    $In extends StructuredContentImage,
    $Out> implements ClassCopyWith<$R, $In, $Out> {
  $R call(
      {String? path,
      double? width,
      double? height,
      String? title,
      String? description,
      bool? pixelated,
      String? imageRendering,
      String? appearance,
      bool? background,
      bool? collapsed,
      bool? collapsible,
      String? verticalAlign,
      String? sizeUnits});
  StructuredContentImageCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _StructuredContentImageCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, StructuredContentImage, $Out>
    implements
        StructuredContentImageCopyWith<$R, StructuredContentImage, $Out> {
  _StructuredContentImageCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<StructuredContentImage> $mapper =
      StructuredContentImageMapper.ensureInitialized();
  @override
  $R call(
          {String? path,
          Object? width = $none,
          Object? height = $none,
          Object? title = $none,
          Object? description = $none,
          bool? pixelated,
          String? imageRendering,
          String? appearance,
          bool? background,
          bool? collapsed,
          bool? collapsible,
          Object? verticalAlign = $none,
          Object? sizeUnits = $none}) =>
      $apply(FieldCopyWithData({
        if (path != null) #path: path,
        if (width != $none) #width: width,
        if (height != $none) #height: height,
        if (title != $none) #title: title,
        if (description != $none) #description: description,
        if (pixelated != null) #pixelated: pixelated,
        if (imageRendering != null) #imageRendering: imageRendering,
        if (appearance != null) #appearance: appearance,
        if (background != null) #background: background,
        if (collapsed != null) #collapsed: collapsed,
        if (collapsible != null) #collapsible: collapsible,
        if (verticalAlign != $none) #verticalAlign: verticalAlign,
        if (sizeUnits != $none) #sizeUnits: sizeUnits
      }));
  @override
  StructuredContentImage $make(CopyWithData data) => StructuredContentImage(
      path: data.get(#path, or: $value.path),
      width: data.get(#width, or: $value.width),
      height: data.get(#height, or: $value.height),
      title: data.get(#title, or: $value.title),
      description: data.get(#description, or: $value.description),
      pixelated: data.get(#pixelated, or: $value.pixelated),
      imageRendering: data.get(#imageRendering, or: $value.imageRendering),
      appearance: data.get(#appearance, or: $value.appearance),
      background: data.get(#background, or: $value.background),
      collapsed: data.get(#collapsed, or: $value.collapsed),
      collapsible: data.get(#collapsible, or: $value.collapsible),
      verticalAlign: data.get(#verticalAlign, or: $value.verticalAlign),
      sizeUnits: data.get(#sizeUnits, or: $value.sizeUnits));

  @override
  StructuredContentImageCopyWith<$R2, StructuredContentImage, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _StructuredContentImageCopyWithImpl($value, $cast, t);
}

class StructuredContentLinkMapper
    extends SubClassMapperBase<StructuredContentLink> {
  StructuredContentLinkMapper._();

  static StructuredContentLinkMapper? _instance;
  static StructuredContentLinkMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = StructuredContentLinkMapper._());
      StructuredContentMapper.ensureInitialized().addSubMapper(_instance!);
      StructuredContentMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'StructuredContentLink';

  static String _$href(StructuredContentLink v) => v.href;
  static const Field<StructuredContentLink, String> _f$href =
      Field('href', _$href);
  static StructuredContent? _$content(StructuredContentLink v) => v.content;
  static const Field<StructuredContentLink, StructuredContent> _f$content =
      Field('content', _$content, opt: true, hook: ContentHook());
  static String? _$lang(StructuredContentLink v) => v.lang;
  static const Field<StructuredContentLink, String> _f$lang =
      Field('lang', _$lang, opt: true);

  @override
  final Map<Symbol, Field<StructuredContentLink, dynamic>> fields = const {
    #href: _f$href,
    #content: _f$content,
    #lang: _f$lang,
  };

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = StructuredContentLink.checkType;
  @override
  late final ClassMapperBase superMapper =
      StructuredContentMapper.ensureInitialized();

  static StructuredContentLink _instantiate(DecodingData data) {
    return StructuredContentLink(
        href: data.dec(_f$href),
        content: data.dec(_f$content),
        lang: data.dec(_f$lang));
  }

  @override
  final Function instantiate = _instantiate;

  static StructuredContentLink fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<StructuredContentLink>(map);
  }

  static StructuredContentLink fromJson(String json) {
    return ensureInitialized().decodeJson<StructuredContentLink>(json);
  }
}

mixin StructuredContentLinkMappable {
  String toJson() {
    return StructuredContentLinkMapper.ensureInitialized()
        .encodeJson<StructuredContentLink>(this as StructuredContentLink);
  }

  Map<String, dynamic> toMap() {
    return StructuredContentLinkMapper.ensureInitialized()
        .encodeMap<StructuredContentLink>(this as StructuredContentLink);
  }

  StructuredContentLinkCopyWith<StructuredContentLink, StructuredContentLink,
          StructuredContentLink>
      get copyWith => _StructuredContentLinkCopyWithImpl(
          this as StructuredContentLink, $identity, $identity);
  @override
  String toString() {
    return StructuredContentLinkMapper.ensureInitialized()
        .stringifyValue(this as StructuredContentLink);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (runtimeType == other.runtimeType &&
            StructuredContentLinkMapper.ensureInitialized()
                .isValueEqual(this as StructuredContentLink, other));
  }

  @override
  int get hashCode {
    return StructuredContentLinkMapper.ensureInitialized()
        .hashValue(this as StructuredContentLink);
  }
}

extension StructuredContentLinkValueCopy<$R, $Out>
    on ObjectCopyWith<$R, StructuredContentLink, $Out> {
  StructuredContentLinkCopyWith<$R, StructuredContentLink, $Out>
      get $asStructuredContentLink =>
          $base.as((v, t, t2) => _StructuredContentLinkCopyWithImpl(v, t, t2));
}

abstract class StructuredContentLinkCopyWith<
    $R,
    $In extends StructuredContentLink,
    $Out> implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? href, StructuredContent? content, String? lang});
  StructuredContentLinkCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _StructuredContentLinkCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, StructuredContentLink, $Out>
    implements StructuredContentLinkCopyWith<$R, StructuredContentLink, $Out> {
  _StructuredContentLinkCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<StructuredContentLink> $mapper =
      StructuredContentLinkMapper.ensureInitialized();
  @override
  $R call({String? href, Object? content = $none, Object? lang = $none}) =>
      $apply(FieldCopyWithData({
        if (href != null) #href: href,
        if (content != $none) #content: content,
        if (lang != $none) #lang: lang
      }));
  @override
  StructuredContentLink $make(CopyWithData data) => StructuredContentLink(
      href: data.get(#href, or: $value.href),
      content: data.get(#content, or: $value.content),
      lang: data.get(#lang, or: $value.lang));

  @override
  StructuredContentLinkCopyWith<$R2, StructuredContentLink, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _StructuredContentLinkCopyWithImpl($value, $cast, t);
}

class StructuredContentContainerMapper
    extends SubClassMapperBase<StructuredContentContainer> {
  StructuredContentContainerMapper._();

  static StructuredContentContainerMapper? _instance;
  static StructuredContentContainerMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals
          .use(_instance = StructuredContentContainerMapper._());
      StructuredContentMapper.ensureInitialized().addSubMapper(_instance!);
      StructuredContentMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'StructuredContentContainer';

  static String _$tag(StructuredContentContainer v) => v.tag;
  static const Field<StructuredContentContainer, String> _f$tag =
      Field('tag', _$tag);
  static StructuredContent? _$content(StructuredContentContainer v) =>
      v.content;
  static const Field<StructuredContentContainer, StructuredContent> _f$content =
      Field('content', _$content, opt: true, hook: ContentHook());
  static Map<String, String>? _$data(StructuredContentContainer v) => v.data;
  static const Field<StructuredContentContainer, Map<String, String>> _f$data =
      Field('data', _$data, opt: true);
  static String? _$lang(StructuredContentContainer v) => v.lang;
  static const Field<StructuredContentContainer, String> _f$lang =
      Field('lang', _$lang, opt: true);

  @override
  final Map<Symbol, Field<StructuredContentContainer, dynamic>> fields = const {
    #tag: _f$tag,
    #content: _f$content,
    #data: _f$data,
    #lang: _f$lang,
  };

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = StructuredContentContainer.checkType;
  @override
  late final ClassMapperBase superMapper =
      StructuredContentMapper.ensureInitialized();

  static StructuredContentContainer _instantiate(DecodingData data) {
    return StructuredContentContainer(
        tag: data.dec(_f$tag),
        content: data.dec(_f$content),
        data: data.dec(_f$data),
        lang: data.dec(_f$lang));
  }

  @override
  final Function instantiate = _instantiate;

  static StructuredContentContainer fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<StructuredContentContainer>(map);
  }

  static StructuredContentContainer fromJson(String json) {
    return ensureInitialized().decodeJson<StructuredContentContainer>(json);
  }
}

mixin StructuredContentContainerMappable {
  String toJson() {
    return StructuredContentContainerMapper.ensureInitialized()
        .encodeJson<StructuredContentContainer>(
            this as StructuredContentContainer);
  }

  Map<String, dynamic> toMap() {
    return StructuredContentContainerMapper.ensureInitialized()
        .encodeMap<StructuredContentContainer>(
            this as StructuredContentContainer);
  }

  StructuredContentContainerCopyWith<StructuredContentContainer,
          StructuredContentContainer, StructuredContentContainer>
      get copyWith => _StructuredContentContainerCopyWithImpl(
          this as StructuredContentContainer, $identity, $identity);
  @override
  String toString() {
    return StructuredContentContainerMapper.ensureInitialized()
        .stringifyValue(this as StructuredContentContainer);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (runtimeType == other.runtimeType &&
            StructuredContentContainerMapper.ensureInitialized()
                .isValueEqual(this as StructuredContentContainer, other));
  }

  @override
  int get hashCode {
    return StructuredContentContainerMapper.ensureInitialized()
        .hashValue(this as StructuredContentContainer);
  }
}

extension StructuredContentContainerValueCopy<$R, $Out>
    on ObjectCopyWith<$R, StructuredContentContainer, $Out> {
  StructuredContentContainerCopyWith<$R, StructuredContentContainer, $Out>
      get $asStructuredContentContainer => $base
          .as((v, t, t2) => _StructuredContentContainerCopyWithImpl(v, t, t2));
}

abstract class StructuredContentContainerCopyWith<
    $R,
    $In extends StructuredContentContainer,
    $Out> implements ClassCopyWith<$R, $In, $Out> {
  MapCopyWith<$R, String, String, ObjectCopyWith<$R, String, String>>? get data;
  $R call(
      {String? tag,
      StructuredContent? content,
      Map<String, String>? data,
      String? lang});
  StructuredContentContainerCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _StructuredContentContainerCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, StructuredContentContainer, $Out>
    implements
        StructuredContentContainerCopyWith<$R, StructuredContentContainer,
            $Out> {
  _StructuredContentContainerCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<StructuredContentContainer> $mapper =
      StructuredContentContainerMapper.ensureInitialized();
  @override
  MapCopyWith<$R, String, String, ObjectCopyWith<$R, String, String>>?
      get data => $value.data != null
          ? MapCopyWith($value.data!, (v, t) => ObjectCopyWith(v, $identity, t),
              (v) => call(data: v))
          : null;
  @override
  $R call(
          {String? tag,
          Object? content = $none,
          Object? data = $none,
          Object? lang = $none}) =>
      $apply(FieldCopyWithData({
        if (tag != null) #tag: tag,
        if (content != $none) #content: content,
        if (data != $none) #data: data,
        if (lang != $none) #lang: lang
      }));
  @override
  StructuredContentContainer $make(CopyWithData data) =>
      StructuredContentContainer(
          tag: data.get(#tag, or: $value.tag),
          content: data.get(#content, or: $value.content),
          data: data.get(#data, or: $value.data),
          lang: data.get(#lang, or: $value.lang));

  @override
  StructuredContentContainerCopyWith<$R2, StructuredContentContainer, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _StructuredContentContainerCopyWithImpl($value, $cast, t);
}

class StructuredContentStyledContainerMapper
    extends SubClassMapperBase<StructuredContentStyledContainer> {
  StructuredContentStyledContainerMapper._();

  static StructuredContentStyledContainerMapper? _instance;
  static StructuredContentStyledContainerMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals
          .use(_instance = StructuredContentStyledContainerMapper._());
      StructuredContentMapper.ensureInitialized().addSubMapper(_instance!);
      StructuredContentMapper.ensureInitialized();
      StructuredContentStyleMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'StructuredContentStyledContainer';

  static String _$tag(StructuredContentStyledContainer v) => v.tag;
  static const Field<StructuredContentStyledContainer, String> _f$tag =
      Field('tag', _$tag);
  static StructuredContent? _$content(StructuredContentStyledContainer v) =>
      v.content;
  static const Field<StructuredContentStyledContainer, StructuredContent>
      _f$content = Field('content', _$content, opt: true, hook: ContentHook());
  static StructuredContentStyle? _$style(StructuredContentStyledContainer v) =>
      v.style;
  static const Field<StructuredContentStyledContainer, StructuredContentStyle>
      _f$style = Field('style', _$style, opt: true);
  static Map<String, String>? _$data(StructuredContentStyledContainer v) =>
      v.data;
  static const Field<StructuredContentStyledContainer, Map<String, String>>
      _f$data = Field('data', _$data, opt: true);
  static String? _$lang(StructuredContentStyledContainer v) => v.lang;
  static const Field<StructuredContentStyledContainer, String> _f$lang =
      Field('lang', _$lang, opt: true);

  @override
  final Map<Symbol, Field<StructuredContentStyledContainer, dynamic>> fields =
      const {
    #tag: _f$tag,
    #content: _f$content,
    #style: _f$style,
    #data: _f$data,
    #lang: _f$lang,
  };

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = StructuredContentStyledContainer.checkType;
  @override
  late final ClassMapperBase superMapper =
      StructuredContentMapper.ensureInitialized();

  static StructuredContentStyledContainer _instantiate(DecodingData data) {
    return StructuredContentStyledContainer(
        tag: data.dec(_f$tag),
        content: data.dec(_f$content),
        style: data.dec(_f$style),
        data: data.dec(_f$data),
        lang: data.dec(_f$lang));
  }

  @override
  final Function instantiate = _instantiate;

  static StructuredContentStyledContainer fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<StructuredContentStyledContainer>(map);
  }

  static StructuredContentStyledContainer fromJson(String json) {
    return ensureInitialized()
        .decodeJson<StructuredContentStyledContainer>(json);
  }
}

mixin StructuredContentStyledContainerMappable {
  String toJson() {
    return StructuredContentStyledContainerMapper.ensureInitialized()
        .encodeJson<StructuredContentStyledContainer>(
            this as StructuredContentStyledContainer);
  }

  Map<String, dynamic> toMap() {
    return StructuredContentStyledContainerMapper.ensureInitialized()
        .encodeMap<StructuredContentStyledContainer>(
            this as StructuredContentStyledContainer);
  }

  StructuredContentStyledContainerCopyWith<StructuredContentStyledContainer,
          StructuredContentStyledContainer, StructuredContentStyledContainer>
      get copyWith => _StructuredContentStyledContainerCopyWithImpl(
          this as StructuredContentStyledContainer, $identity, $identity);
  @override
  String toString() {
    return StructuredContentStyledContainerMapper.ensureInitialized()
        .stringifyValue(this as StructuredContentStyledContainer);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (runtimeType == other.runtimeType &&
            StructuredContentStyledContainerMapper.ensureInitialized()
                .isValueEqual(this as StructuredContentStyledContainer, other));
  }

  @override
  int get hashCode {
    return StructuredContentStyledContainerMapper.ensureInitialized()
        .hashValue(this as StructuredContentStyledContainer);
  }
}

extension StructuredContentStyledContainerValueCopy<$R, $Out>
    on ObjectCopyWith<$R, StructuredContentStyledContainer, $Out> {
  StructuredContentStyledContainerCopyWith<$R, StructuredContentStyledContainer,
          $Out>
      get $asStructuredContentStyledContainer => $base.as((v, t, t2) =>
          _StructuredContentStyledContainerCopyWithImpl(v, t, t2));
}

abstract class StructuredContentStyledContainerCopyWith<
    $R,
    $In extends StructuredContentStyledContainer,
    $Out> implements ClassCopyWith<$R, $In, $Out> {
  StructuredContentStyleCopyWith<$R, StructuredContentStyle,
      StructuredContentStyle>? get style;
  MapCopyWith<$R, String, String, ObjectCopyWith<$R, String, String>>? get data;
  $R call(
      {String? tag,
      StructuredContent? content,
      StructuredContentStyle? style,
      Map<String, String>? data,
      String? lang});
  StructuredContentStyledContainerCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _StructuredContentStyledContainerCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, StructuredContentStyledContainer, $Out>
    implements
        StructuredContentStyledContainerCopyWith<$R,
            StructuredContentStyledContainer, $Out> {
  _StructuredContentStyledContainerCopyWithImpl(
      super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<StructuredContentStyledContainer> $mapper =
      StructuredContentStyledContainerMapper.ensureInitialized();
  @override
  StructuredContentStyleCopyWith<$R, StructuredContentStyle,
          StructuredContentStyle>?
      get style => $value.style?.copyWith.$chain((v) => call(style: v));
  @override
  MapCopyWith<$R, String, String, ObjectCopyWith<$R, String, String>>?
      get data => $value.data != null
          ? MapCopyWith($value.data!, (v, t) => ObjectCopyWith(v, $identity, t),
              (v) => call(data: v))
          : null;
  @override
  $R call(
          {String? tag,
          Object? content = $none,
          Object? style = $none,
          Object? data = $none,
          Object? lang = $none}) =>
      $apply(FieldCopyWithData({
        if (tag != null) #tag: tag,
        if (content != $none) #content: content,
        if (style != $none) #style: style,
        if (data != $none) #data: data,
        if (lang != $none) #lang: lang
      }));
  @override
  StructuredContentStyledContainer $make(CopyWithData data) =>
      StructuredContentStyledContainer(
          tag: data.get(#tag, or: $value.tag),
          content: data.get(#content, or: $value.content),
          style: data.get(#style, or: $value.style),
          data: data.get(#data, or: $value.data),
          lang: data.get(#lang, or: $value.lang));

  @override
  StructuredContentStyledContainerCopyWith<$R2,
      StructuredContentStyledContainer, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _StructuredContentStyledContainerCopyWithImpl($value, $cast, t);
}

class StructuredContentStyleMapper
    extends ClassMapperBase<StructuredContentStyle> {
  StructuredContentStyleMapper._();

  static StructuredContentStyleMapper? _instance;
  static StructuredContentStyleMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = StructuredContentStyleMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'StructuredContentStyle';

  static String _$fontStyle(StructuredContentStyle v) => v.fontStyle;
  static const Field<StructuredContentStyle, String> _f$fontStyle =
      Field('fontStyle', _$fontStyle, opt: true, def: 'normal');
  static String _$fontWeight(StructuredContentStyle v) => v.fontWeight;
  static const Field<StructuredContentStyle, String> _f$fontWeight =
      Field('fontWeight', _$fontWeight, opt: true, def: 'normal');
  static String _$fontSize(StructuredContentStyle v) => v.fontSize;
  static const Field<StructuredContentStyle, String> _f$fontSize =
      Field('fontSize', _$fontSize, opt: true, def: 'medium');
  static List<String> _$textDecorationLine(StructuredContentStyle v) =>
      v.textDecorationLine;
  static const Field<StructuredContentStyle, List<String>>
      _f$textDecorationLine = Field('textDecorationLine', _$textDecorationLine,
          opt: true, def: const [], hook: TextDecorationLineHooker());
  static String _$verticalAlign(StructuredContentStyle v) => v.verticalAlign;
  static const Field<StructuredContentStyle, String> _f$verticalAlign =
      Field('verticalAlign', _$verticalAlign, opt: true, def: 'baseline');
  static String _$textAlign(StructuredContentStyle v) => v.textAlign;
  static const Field<StructuredContentStyle, String> _f$textAlign =
      Field('textAlign', _$textAlign, opt: true, def: 'start');
  static double _$marginTop(StructuredContentStyle v) => v.marginTop;
  static const Field<StructuredContentStyle, double> _f$marginTop =
      Field('marginTop', _$marginTop, opt: true, def: 0);
  static double _$marginLeft(StructuredContentStyle v) => v.marginLeft;
  static const Field<StructuredContentStyle, double> _f$marginLeft =
      Field('marginLeft', _$marginLeft, opt: true, def: 0);
  static double _$marginRight(StructuredContentStyle v) => v.marginRight;
  static const Field<StructuredContentStyle, double> _f$marginRight =
      Field('marginRight', _$marginRight, opt: true, def: 0);
  static double _$marginBottom(StructuredContentStyle v) => v.marginBottom;
  static const Field<StructuredContentStyle, double> _f$marginBottom =
      Field('marginBottom', _$marginBottom, opt: true, def: 0);
  static String _$listStyleType(StructuredContentStyle v) => v.listStyleType;
  static const Field<StructuredContentStyle, String> _f$listStyleType =
      Field('listStyleType', _$listStyleType, opt: true, def: 'disc');

  @override
  final Map<Symbol, Field<StructuredContentStyle, dynamic>> fields = const {
    #fontStyle: _f$fontStyle,
    #fontWeight: _f$fontWeight,
    #fontSize: _f$fontSize,
    #textDecorationLine: _f$textDecorationLine,
    #verticalAlign: _f$verticalAlign,
    #textAlign: _f$textAlign,
    #marginTop: _f$marginTop,
    #marginLeft: _f$marginLeft,
    #marginRight: _f$marginRight,
    #marginBottom: _f$marginBottom,
    #listStyleType: _f$listStyleType,
  };

  static StructuredContentStyle _instantiate(DecodingData data) {
    return StructuredContentStyle(
        fontStyle: data.dec(_f$fontStyle),
        fontWeight: data.dec(_f$fontWeight),
        fontSize: data.dec(_f$fontSize),
        textDecorationLine: data.dec(_f$textDecorationLine),
        verticalAlign: data.dec(_f$verticalAlign),
        textAlign: data.dec(_f$textAlign),
        marginTop: data.dec(_f$marginTop),
        marginLeft: data.dec(_f$marginLeft),
        marginRight: data.dec(_f$marginRight),
        marginBottom: data.dec(_f$marginBottom),
        listStyleType: data.dec(_f$listStyleType));
  }

  @override
  final Function instantiate = _instantiate;

  static StructuredContentStyle fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<StructuredContentStyle>(map);
  }

  static StructuredContentStyle fromJson(String json) {
    return ensureInitialized().decodeJson<StructuredContentStyle>(json);
  }
}

mixin StructuredContentStyleMappable {
  String toJson() {
    return StructuredContentStyleMapper.ensureInitialized()
        .encodeJson<StructuredContentStyle>(this as StructuredContentStyle);
  }

  Map<String, dynamic> toMap() {
    return StructuredContentStyleMapper.ensureInitialized()
        .encodeMap<StructuredContentStyle>(this as StructuredContentStyle);
  }

  StructuredContentStyleCopyWith<StructuredContentStyle, StructuredContentStyle,
          StructuredContentStyle>
      get copyWith => _StructuredContentStyleCopyWithImpl(
          this as StructuredContentStyle, $identity, $identity);
  @override
  String toString() {
    return StructuredContentStyleMapper.ensureInitialized()
        .stringifyValue(this as StructuredContentStyle);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (runtimeType == other.runtimeType &&
            StructuredContentStyleMapper.ensureInitialized()
                .isValueEqual(this as StructuredContentStyle, other));
  }

  @override
  int get hashCode {
    return StructuredContentStyleMapper.ensureInitialized()
        .hashValue(this as StructuredContentStyle);
  }
}

extension StructuredContentStyleValueCopy<$R, $Out>
    on ObjectCopyWith<$R, StructuredContentStyle, $Out> {
  StructuredContentStyleCopyWith<$R, StructuredContentStyle, $Out>
      get $asStructuredContentStyle =>
          $base.as((v, t, t2) => _StructuredContentStyleCopyWithImpl(v, t, t2));
}

abstract class StructuredContentStyleCopyWith<
    $R,
    $In extends StructuredContentStyle,
    $Out> implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>
      get textDecorationLine;
  $R call(
      {String? fontStyle,
      String? fontWeight,
      String? fontSize,
      List<String>? textDecorationLine,
      String? verticalAlign,
      String? textAlign,
      double? marginTop,
      double? marginLeft,
      double? marginRight,
      double? marginBottom,
      String? listStyleType});
  StructuredContentStyleCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _StructuredContentStyleCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, StructuredContentStyle, $Out>
    implements
        StructuredContentStyleCopyWith<$R, StructuredContentStyle, $Out> {
  _StructuredContentStyleCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<StructuredContentStyle> $mapper =
      StructuredContentStyleMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>
      get textDecorationLine => ListCopyWith(
          $value.textDecorationLine,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(textDecorationLine: v));
  @override
  $R call(
          {String? fontStyle,
          String? fontWeight,
          String? fontSize,
          List<String>? textDecorationLine,
          String? verticalAlign,
          String? textAlign,
          double? marginTop,
          double? marginLeft,
          double? marginRight,
          double? marginBottom,
          String? listStyleType}) =>
      $apply(FieldCopyWithData({
        if (fontStyle != null) #fontStyle: fontStyle,
        if (fontWeight != null) #fontWeight: fontWeight,
        if (fontSize != null) #fontSize: fontSize,
        if (textDecorationLine != null) #textDecorationLine: textDecorationLine,
        if (verticalAlign != null) #verticalAlign: verticalAlign,
        if (textAlign != null) #textAlign: textAlign,
        if (marginTop != null) #marginTop: marginTop,
        if (marginLeft != null) #marginLeft: marginLeft,
        if (marginRight != null) #marginRight: marginRight,
        if (marginBottom != null) #marginBottom: marginBottom,
        if (listStyleType != null) #listStyleType: listStyleType
      }));
  @override
  StructuredContentStyle $make(CopyWithData data) => StructuredContentStyle(
      fontStyle: data.get(#fontStyle, or: $value.fontStyle),
      fontWeight: data.get(#fontWeight, or: $value.fontWeight),
      fontSize: data.get(#fontSize, or: $value.fontSize),
      textDecorationLine:
          data.get(#textDecorationLine, or: $value.textDecorationLine),
      verticalAlign: data.get(#verticalAlign, or: $value.verticalAlign),
      textAlign: data.get(#textAlign, or: $value.textAlign),
      marginTop: data.get(#marginTop, or: $value.marginTop),
      marginLeft: data.get(#marginLeft, or: $value.marginLeft),
      marginRight: data.get(#marginRight, or: $value.marginRight),
      marginBottom: data.get(#marginBottom, or: $value.marginBottom),
      listStyleType: data.get(#listStyleType, or: $value.listStyleType));

  @override
  StructuredContentStyleCopyWith<$R2, StructuredContentStyle, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _StructuredContentStyleCopyWithImpl($value, $cast, t);
}

class StructuredContentTableElementMapper
    extends SubClassMapperBase<StructuredContentTableElement> {
  StructuredContentTableElementMapper._();

  static StructuredContentTableElementMapper? _instance;
  static StructuredContentTableElementMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals
          .use(_instance = StructuredContentTableElementMapper._());
      StructuredContentMapper.ensureInitialized().addSubMapper(_instance!);
      StructuredContentMapper.ensureInitialized();
      StructuredContentStyleMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'StructuredContentTableElement';

  static String _$tag(StructuredContentTableElement v) => v.tag;
  static const Field<StructuredContentTableElement, String> _f$tag =
      Field('tag', _$tag);
  static StructuredContent? _$content(StructuredContentTableElement v) =>
      v.content;
  static const Field<StructuredContentTableElement, StructuredContent>
      _f$content = Field('content', _$content, opt: true, hook: ContentHook());
  static StructuredContentStyle? _$style(StructuredContentTableElement v) =>
      v.style;
  static const Field<StructuredContentTableElement, StructuredContentStyle>
      _f$style = Field('style', _$style, opt: true);
  static Map<String, String>? _$data(StructuredContentTableElement v) => v.data;
  static const Field<StructuredContentTableElement, Map<String, String>>
      _f$data = Field('data', _$data, opt: true);
  static int? _$colSpan(StructuredContentTableElement v) => v.colSpan;
  static const Field<StructuredContentTableElement, int> _f$colSpan =
      Field('colSpan', _$colSpan, opt: true);
  static int? _$rowSpan(StructuredContentTableElement v) => v.rowSpan;
  static const Field<StructuredContentTableElement, int> _f$rowSpan =
      Field('rowSpan', _$rowSpan, opt: true);
  static String? _$lang(StructuredContentTableElement v) => v.lang;
  static const Field<StructuredContentTableElement, String> _f$lang =
      Field('lang', _$lang, opt: true);

  @override
  final Map<Symbol, Field<StructuredContentTableElement, dynamic>> fields =
      const {
    #tag: _f$tag,
    #content: _f$content,
    #style: _f$style,
    #data: _f$data,
    #colSpan: _f$colSpan,
    #rowSpan: _f$rowSpan,
    #lang: _f$lang,
  };

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = StructuredContentTableElement.checkType;
  @override
  late final ClassMapperBase superMapper =
      StructuredContentMapper.ensureInitialized();

  static StructuredContentTableElement _instantiate(DecodingData data) {
    return StructuredContentTableElement(
        tag: data.dec(_f$tag),
        content: data.dec(_f$content),
        style: data.dec(_f$style),
        data: data.dec(_f$data),
        colSpan: data.dec(_f$colSpan),
        rowSpan: data.dec(_f$rowSpan),
        lang: data.dec(_f$lang));
  }

  @override
  final Function instantiate = _instantiate;

  static StructuredContentTableElement fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<StructuredContentTableElement>(map);
  }

  static StructuredContentTableElement fromJson(String json) {
    return ensureInitialized().decodeJson<StructuredContentTableElement>(json);
  }
}

mixin StructuredContentTableElementMappable {
  String toJson() {
    return StructuredContentTableElementMapper.ensureInitialized()
        .encodeJson<StructuredContentTableElement>(
            this as StructuredContentTableElement);
  }

  Map<String, dynamic> toMap() {
    return StructuredContentTableElementMapper.ensureInitialized()
        .encodeMap<StructuredContentTableElement>(
            this as StructuredContentTableElement);
  }

  StructuredContentTableElementCopyWith<StructuredContentTableElement,
          StructuredContentTableElement, StructuredContentTableElement>
      get copyWith => _StructuredContentTableElementCopyWithImpl(
          this as StructuredContentTableElement, $identity, $identity);
  @override
  String toString() {
    return StructuredContentTableElementMapper.ensureInitialized()
        .stringifyValue(this as StructuredContentTableElement);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (runtimeType == other.runtimeType &&
            StructuredContentTableElementMapper.ensureInitialized()
                .isValueEqual(this as StructuredContentTableElement, other));
  }

  @override
  int get hashCode {
    return StructuredContentTableElementMapper.ensureInitialized()
        .hashValue(this as StructuredContentTableElement);
  }
}

extension StructuredContentTableElementValueCopy<$R, $Out>
    on ObjectCopyWith<$R, StructuredContentTableElement, $Out> {
  StructuredContentTableElementCopyWith<$R, StructuredContentTableElement, $Out>
      get $asStructuredContentTableElement => $base.as(
          (v, t, t2) => _StructuredContentTableElementCopyWithImpl(v, t, t2));
}

abstract class StructuredContentTableElementCopyWith<
    $R,
    $In extends StructuredContentTableElement,
    $Out> implements ClassCopyWith<$R, $In, $Out> {
  StructuredContentStyleCopyWith<$R, StructuredContentStyle,
      StructuredContentStyle>? get style;
  MapCopyWith<$R, String, String, ObjectCopyWith<$R, String, String>>? get data;
  $R call(
      {String? tag,
      StructuredContent? content,
      StructuredContentStyle? style,
      Map<String, String>? data,
      int? colSpan,
      int? rowSpan,
      String? lang});
  StructuredContentTableElementCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _StructuredContentTableElementCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, StructuredContentTableElement, $Out>
    implements
        StructuredContentTableElementCopyWith<$R, StructuredContentTableElement,
            $Out> {
  _StructuredContentTableElementCopyWithImpl(
      super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<StructuredContentTableElement> $mapper =
      StructuredContentTableElementMapper.ensureInitialized();
  @override
  StructuredContentStyleCopyWith<$R, StructuredContentStyle,
          StructuredContentStyle>?
      get style => $value.style?.copyWith.$chain((v) => call(style: v));
  @override
  MapCopyWith<$R, String, String, ObjectCopyWith<$R, String, String>>?
      get data => $value.data != null
          ? MapCopyWith($value.data!, (v, t) => ObjectCopyWith(v, $identity, t),
              (v) => call(data: v))
          : null;
  @override
  $R call(
          {String? tag,
          Object? content = $none,
          Object? style = $none,
          Object? data = $none,
          Object? colSpan = $none,
          Object? rowSpan = $none,
          Object? lang = $none}) =>
      $apply(FieldCopyWithData({
        if (tag != null) #tag: tag,
        if (content != $none) #content: content,
        if (style != $none) #style: style,
        if (data != $none) #data: data,
        if (colSpan != $none) #colSpan: colSpan,
        if (rowSpan != $none) #rowSpan: rowSpan,
        if (lang != $none) #lang: lang
      }));
  @override
  StructuredContentTableElement $make(CopyWithData data) =>
      StructuredContentTableElement(
          tag: data.get(#tag, or: $value.tag),
          content: data.get(#content, or: $value.content),
          style: data.get(#style, or: $value.style),
          data: data.get(#data, or: $value.data),
          colSpan: data.get(#colSpan, or: $value.colSpan),
          rowSpan: data.get(#rowSpan, or: $value.rowSpan),
          lang: data.get(#lang, or: $value.lang));

  @override
  StructuredContentTableElementCopyWith<$R2, StructuredContentTableElement,
      $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _StructuredContentTableElementCopyWithImpl($value, $cast, t);
}
