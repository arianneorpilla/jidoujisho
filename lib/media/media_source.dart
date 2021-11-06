import 'dart:async';

import 'package:chisa/media/media_history_items/media_history_item.dart';
import 'package:chisa/media/media_type.dart';
import 'package:chisa/models/app_model.dart';
import 'package:flutter/material.dart';

/// A source for a [MediaType] that will appear on the list of sources when
/// set as active. Handles sourcing and delivery of arguments such that the
/// [MediaType] is able to execute and launch with the proper arguments.
abstract class MediaSource {
  MediaSource({
    required this.sourceName,
    required this.mediaType,
    required this.icon,
    required this.searchSupport,
    required this.searchLabel,
    this.searchAction,
  }) : assert(
            (searchSupport && searchAction != null ||
                !searchSupport && searchAction == null),
            'Media sources that do not support search should not have non-null '
            'search actions.');

  /// The name for this that will appear under the media type's source picker.
  final String sourceName;

  /// Which media type this source pertains to.
  final MediaType mediaType;

  final IconData icon;

  /// Whether or not this source supports searching for items.
  final bool searchSupport;

  /// What shows up as a hint on the media source's search label.
  final String? searchLabel;

  /// What happens when the search action is clicked when this particular
  /// media source is active? If [searchSupport] is true, then this should not
  /// be null.
  final Future<void> Function()? searchAction;

  /// If this source is active and, this widget will appear under the search bar
  /// of the media type tab if non-null. This should typically be a button.
  Widget? getButton(BuildContext context);

  bool isShown(AppModel appModel) {
    return appModel.getMediaSourceShown(this);
  }

  /// The unique identifier that is passed to the source parameter
  String getIdentifier() {
    return "${mediaType.prefsDirectory()}/$sourceName";
  }

  /// From a [MediaHistoryItem], generate the thumbnail of this item that will
  /// show up in the home screen.
  Future<ImageProvider> getThumbnail(MediaHistoryItem item);

  /// From a [MediaHistoryItem], get a caption of the metadata to display.
  String getCaption(MediaHistoryItem item);

  /// From a [MediaHistoryItem], get a subcaption of the metadata to display.
  String getSubcaption(MediaHistoryItem item);
}
