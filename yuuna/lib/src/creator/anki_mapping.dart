import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/language.dart';
import 'package:yuuna/models.dart';
import 'package:yuuna/utils.dart';

part 'anki_mapping.g.dart';

/// A user-generated mapping to allow customisation of the fields exported from
/// the application. A mapping is bound to a [model], which must have a length
/// of fields equal or more than the length of [getExportFields].
@JsonSerializable()
@Collection()
class AnkiMapping {
  /// Initialise a model mapping with the given parameters.
  AnkiMapping({
    required this.label,
    required this.model,
    required this.exportFieldKeys,
    required this.creatorFieldKeys,
    required this.creatorCollapsedFieldKeys,
    required this.order,
    required this.tags,
    required this.exportMediaTags,
    required this.useBrTags,
    required this.prependDictionaryNames,
    this.enhancements,
    this.actions,
    this.id,
  });

  /// Get the default mapping that is included with the application at first
  /// startup. Requires a language so that the appropriate default enhancements
  /// are suggested.
  factory AnkiMapping.defaultMapping({
    required Language language,
    required int order,
  }) {
    return AnkiMapping(
      label: standardProfileName,
      model: standardModelName,
      exportFieldKeys: [
        TermField.key,
        SentenceField.key,
        ReadingField.key,
        MeaningField.key,
        NotesField.key,
        ImageField.key,
        AudioField.key,
        PitchAccentField.key,
        FuriganaField.key,
        ExpandedMeaningField.key,
        CollapsedMeaningField.key,
        AudioSentenceField.key,
      ],
      creatorFieldKeys: defaultCreatorFieldKeys,
      creatorCollapsedFieldKeys: defaultCreatorCollapsedFieldKeys,
      order: order,
      tags: [standardModelName],
      enhancements: defaultEnhancementsByLanguage[language.languageCountryCode],
      actions: defaultActionsByLanguage[language.languageCountryCode],
      exportMediaTags: false,
      useBrTags: false,
      prependDictionaryNames: true,
    );
  }

  /// A default map of enhancements to use for new mappings.
  static const Map<String, Map<String, Map<int, String>>>
      defaultEnhancementsByLanguage = {
    'ja-JP': {
      SentenceField.key: {
        0: ClearFieldEnhancement.key,
        1: TextSegmentationEnhancement.key,
        2: SentencePickerEnhancement.key,
      },
      TermField.key: {
        0: ClearFieldEnhancement.key,
        1: SearchDictionaryEnhancement.key,
        2: MassifExampleSentencesEnhancement.key,
        3: ImmersionKitEnhancement.key,
        4: OpenStashEnhancement.key,
      },
      ReadingField.key: {0: ClearFieldEnhancement.key},
      MeaningField.key: {
        0: ClearFieldEnhancement.key,
        1: TextSegmentationEnhancement.key,
      },
      NotesField.key: {0: ClearFieldEnhancement.key},
      ImageField.key: {
        -1: BingImagesSearchEnhancement.key,
        0: ClearFieldEnhancement.key,
        1: BingImagesSearchEnhancement.key,
        2: CameraEnhancement.key,
        3: PickImageEnhancement.key,
        4: CropImageEnhancement.key,
      },
      AudioField.key: {
        -1: JapanesePod101AudioEnhancement.key,
        0: ClearFieldEnhancement.key,
        1: JapanesePod101AudioEnhancement.key,
        2: ForvoAudioEnhancement.key,
        3: PickAudioEnhancement.key,
        4: AudioRecorderEnhancement.key,
      },
      AudioSentenceField.key: {
        0: ClearFieldEnhancement.key,
      },
      TagsField.key: {
        0: ClearFieldEnhancement.key,
        1: SaveTagsEnhancement.key,
      },
      ContextField.key: {0: ClearFieldEnhancement.key},
      PitchAccentField.key: {0: ClearFieldEnhancement.key},
      FuriganaField.key: {0: ClearFieldEnhancement.key},
      CollapsedMeaningField.key: {0: ClearFieldEnhancement.key},
      ExpandedMeaningField.key: {0: ClearFieldEnhancement.key},
      HiddenMeaningField.key: {0: ClearFieldEnhancement.key},
    },
    'en-US': {
      SentenceField.key: {
        0: ClearFieldEnhancement.key,
        1: TextSegmentationEnhancement.key
      },
      TermField.key: {
        0: ClearFieldEnhancement.key,
        1: SearchDictionaryEnhancement.key,
        2: TatoebaExampleSentencesEnhancement.key,
        3: OpenStashEnhancement.key,
      },
      ReadingField.key: {0: ClearFieldEnhancement.key},
      MeaningField.key: {
        0: ClearFieldEnhancement.key,
        1: TextSegmentationEnhancement.key,
      },
      NotesField.key: {0: ClearFieldEnhancement.key},
      ImageField.key: {
        -1: BingImagesSearchEnhancement.key,
        0: ClearFieldEnhancement.key,
        1: BingImagesSearchEnhancement.key,
        2: CameraEnhancement.key,
        3: PickImageEnhancement.key,
        4: CropImageEnhancement.key,
      },
      AudioField.key: {
        -1: ForvoAudioEnhancement.key,
        0: ClearFieldEnhancement.key,
        1: ForvoAudioEnhancement.key,
        2: PickAudioEnhancement.key,
        3: AudioRecorderEnhancement.key,
      },
      AudioSentenceField.key: {
        0: ClearFieldEnhancement.key,
      },
      TagsField.key: {
        0: ClearFieldEnhancement.key,
        1: SaveTagsEnhancement.key,
      },
      ContextField.key: {0: ClearFieldEnhancement.key},
      PitchAccentField.key: {0: ClearFieldEnhancement.key},
      FuriganaField.key: {0: ClearFieldEnhancement.key},
      CollapsedMeaningField.key: {0: ClearFieldEnhancement.key},
      ExpandedMeaningField.key: {0: ClearFieldEnhancement.key},
      HiddenMeaningField.key: {0: ClearFieldEnhancement.key},
    },
  };

  /// Default fields to show upon opening the Card Creator.
  static const List<String> defaultCreatorFieldKeys = [
    SentenceField.key,
    TermField.key,
    ReadingField.key,
    MeaningField.key,
    NotesField.key,
    ImageField.key,
    AudioField.key,
    AudioSentenceField.key,
  ];

  /// Default fields to show upon opening the Card Creator.
  static const List<String> defaultCreatorCollapsedFieldKeys = [
    TagsField.key,
    FuriganaField.key,
    PitchAccentField.key,
  ];

  /// A default map of enhancements to use for new mappings.
  static const Map<String, Map<int, String>> defaultActionsByLanguage = {
    'ja-JP': {
      0: CardCreatorAction.key,
      1: InstantExportAction.key,
      2: AddToStashAction.key,
      3: CopyToClipboardAction.key,
      4: ShareAction.key,
      5: PlayAudioAction.key,
    },
    'en-US': {
      0: CardCreatorAction.key,
      1: InstantExportAction.key,
      2: AddToStashAction.key,
      3: CopyToClipboardAction.key,
      4: ShareAction.key,
      5: PlayAudioAction.key,
    }
  };

  /// The default mapping name which cannot be deleted or reused.
  static String standardModelName = 'jidoujisho Yuuna';

  /// The default mapping name which cannot be deleted or reused.
  static String standardProfileName = 'Standard';

  /// A unique identifier for the purposes of database storage.
  Id? id;

  /// The name of this mapping.
  @Index(unique: true, replace: true)
  final String label;

  /// The name of the model to use when exporting with this mapping.
  final String model;

  /// Returns the unique key equivalents of the field in [getExportFields] that
  /// can be stored in a database.
  List<String?> exportFieldKeys;

  /// Returns the unique key equivalents of the field in [getCreatorFields]
  /// that can be stored in a database.
  List<String> creatorFieldKeys;

  /// Returns the unique key equivalents of the field in
  /// [getCreatorCollapsedFields] that can be stored in a database.
  List<String> creatorCollapsedFieldKeys;

  /// A collection of tags to always include when exporting with this mapping.
  final List<String> tags;

  /// Whether or not this mapping has any non-empty fields set.
  bool get isExportFieldsEmpty =>
      exportFieldKeys.where((e) => e != null).isEmpty;

  /// Used to keep track of actions used in dictionary results.
  @ignore
  Map<int, String>? actions;

  /// Serializes [actions].
  String get actionsIsar => QuickActionsConverter.toIsar(actions!);
  set actionsIsar(String object) =>
      actions = QuickActionsConverter.fromIsar(object);

  /// Used to keep track of enhancements used in the creator per field.
  @ignore
  late Map<String, Map<int, String>>? enhancements;

  /// Serializes [enhancements].
  String get enhancementsIsar => EnhancementsConverter.toIsar(enhancements!);
  set enhancementsIsar(String object) =>
      enhancements = EnhancementsConverter.fromIsar(object);

  /// Reserved index for the auto mode field in the map of enhancement names
  /// for a field.
  static int autoModeSlotNumber = -1;

  /// Whether or not this mapping exports image and audio HTML/Anki syntax
  /// or only shows the filename. If null, will be considered false.
  bool? exportMediaTags;

  /// Whether or not this mapping exports <br> tags instead of \n.
  bool? useBrTags;

  /// Whether or not to add the dictionary name before the meaning.
  bool? prependDictionaryNames;

  /// The order of this dictionary in terms of user sorting, relative to other
  /// dictionaries.
  @Index(unique: true, replace: true)
  int order;

  /// Convert unique keys to fields.
  List<Field?> keysToFieldsNullable(List<String?> keys) {
    List<Field?> fields = [];

    for (String? key in keys) {
      if (key == null) {
        fields.add(null);
      } else {
        Field field = fieldsByKey[key]!;
        fields.add(field);
      }
    }

    return fields;
  }

  /// Convert unique keys to fields.
  List<Field> keysToFields(List<String> keys) {
    List<Field> fields = [];

    for (String key in keys) {
      Field field = fieldsByKey[key]!;
      fields.add(field);
    }

    return fields;
  }

  /// The ordering of the fields to use when exporting with this mapping. The
  /// length of this must be less or equal the length of the model being used
  /// for export to work correctly.
  List<Field?> getExportFields() => keysToFieldsNullable(exportFieldKeys);

  /// The ordering of the fields to show in the Creator.
  List<Field> getCreatorFields() => keysToFields(creatorFieldKeys);

  /// The ordering of the fields to hide in the Creator.
  List<Field> getCreatorCollapsedFields() =>
      keysToFields(creatorCollapsedFieldKeys);

  /// Creates a deep copy of this mapping but with the given variables replaced
  /// with the new values.
  AnkiMapping copyWith({
    String? label,
    String? model,
    List<String?>? exportFieldKeys,
    List<String>? creatorFieldKeys,
    List<String>? creatorCollapsedFieldKeys,
    List<String>? tags,
    int? order,
    int? id,
    Map<String, Map<int, String>>? enhancements,
    Map<int, String>? actions,
    bool? exportMediaTags,
    bool? useBrTags,
    bool? prependDictionaryNames,
  }) {
    return AnkiMapping(
      label: label ?? this.label,
      model: model ?? this.model,
      exportFieldKeys: exportFieldKeys ?? this.exportFieldKeys,
      creatorFieldKeys: creatorFieldKeys ?? this.creatorFieldKeys,
      creatorCollapsedFieldKeys:
          creatorCollapsedFieldKeys ?? this.creatorCollapsedFieldKeys,
      tags: tags ?? this.tags,
      order: order ?? this.order,
      id: id ?? this.id,
      enhancements: enhancements ?? this.enhancements,
      actions: actions ?? this.actions,
      exportMediaTags: exportMediaTags ?? this.exportMediaTags,
      useBrTags: useBrTags ?? this.useBrTags,
      prependDictionaryNames:
          prependDictionaryNames ?? this.prependDictionaryNames,
    );
  }

  /// Returns a list of enhancement names active for a certain field in the
  /// persisted enhancements map.
  List<String> getManualFieldEnhancementNames({required Field field}) {
    return (enhancements![field.uniqueKey] ?? {})
        .entries
        .where((entry) => entry.key != autoModeSlotNumber)
        .map((entry) => entry.value)
        .toList();
  }

  /// Returns the enhancement names active for a certain field in the persisted
  /// enhancements map.
  String? getAutoFieldEnhancementName({required Field field}) {
    return (enhancements![field.uniqueKey] ?? {})[autoModeSlotNumber];
  }

  /// Returns a list of action names active in the persisted actions map.
  List<String> getActionNames() {
    return actions!.values.toList();
  }

  /// Returns a list of enhancements active for a certain field in the
  /// persisted enhancements map.
  List<Enhancement> getManualFieldEnhancement(
      {required AppModel appModel, required Field field}) {
    List<String> enhancementNames =
        getManualFieldEnhancementNames(field: field);
    List<Enhancement> enhancements = enhancementNames
        .map((enhancementName) =>
            appModel.enhancements[field]![enhancementName]!)
        .toList();

    return enhancements;
  }

  /// Returns the enhancement active for a certain field in the persisted
  /// enhancements map.
  Enhancement? getAutoFieldEnhancement(
      {required AppModel appModel, required Field field}) {
    String? enhancementName = getAutoFieldEnhancementName(field: field);
    if (enhancementName == null) {
      return null;
    }

    Enhancement? enhancement = appModel.enhancements[field]![enhancementName];
    return enhancement;
  }

  /// Returns a list of actions active for the persisted actions map.
  List<QuickAction> getActions({required AppModel appModel}) {
    List<String> actionNames = getActionNames();
    List<QuickAction> actions = actionNames
        .map((enhancementName) => appModel.quickActions[enhancementName]!)
        .toList();

    return actions;
  }

  @override
  bool operator ==(Object other) =>
      other is AnkiMapping && label == other.label;

  @override
  int get hashCode => label.hashCode;
}
