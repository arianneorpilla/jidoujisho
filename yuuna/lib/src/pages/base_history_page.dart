import 'package:flutter/material.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// A template for a single media type's history body content in the main menu
/// given a selected media source.
abstract class BaseHistoryPage extends BasePage {
  /// Create an instance of this tab page.
  const BaseHistoryPage({
    super.key,
  });

  @override
  BaseHistoryPageState<BaseHistoryPage> createState();
}

/// A base class for providing all tabs in the main menu. In large part, this
/// was implemented to define shortcuts for common lengthy methods across UI
/// code.
abstract class BaseHistoryPageState<T extends BaseHistoryPage>
    extends BasePageState {
  /// The message to be shown in the placeholder that displays when
  /// [shouldPlaceholderBeShown] is true. This should be a localised message.
  String get placeholderMessage => appModel.translate('info_empty_home_tab');

  /// This variable is true when the [buildPlaceholder] should be shown.
  /// For example, if a certain media type does not have any media items to
  /// show in its history.
  bool get shouldPlaceholderBeShown => true;

  /// Each tab in the home page represents a media type.
  MediaType get mediaType => mediaSource.mediaType;

  /// Get the active media source for the current media type.
  MediaSource get mediaSource =>
      appModel.getCurrentSourceForMediaType(mediaType: mediaType);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (shouldPlaceholderBeShown) {
      return buildPlaceholder();
    } else {
      return buildHistory();
    }
  }

  /// This is shown as the body when [shouldPlaceholderBeShown] is true.
  Widget buildPlaceholder() {
    return Center(
      child: JidoujishoPlaceholderMessage(
        icon: mediaType.outlinedIcon,
        message: placeholderMessage,
      ),
    );
  }

  /// This is shown as the body when [shouldPlaceholderBeShown] is false.
  Widget buildHistory() {
    return Container();
  }
}
