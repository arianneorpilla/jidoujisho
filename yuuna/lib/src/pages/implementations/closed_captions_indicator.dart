import 'package:flutter/material.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';

/// Used to indicate which captions are included on metadata
/// for a YouTube video.
class ClosedCaptionsIndicator extends BasePage {
  /// Create an instance of this page.
  const ClosedCaptionsIndicator({
    required this.item,
    super.key,
  });

  /// Media item this indicator pertains to.
  final MediaItem item;

  @override
  BasePageState<ClosedCaptionsIndicator> createState() =>
      _ClosedCaptionsIndicatorState();
}

class _ClosedCaptionsIndicatorState
    extends BasePageState<ClosedCaptionsIndicator> {
  String get captionsQueryLabel => appModel.translate('closed_captions_query');
  String get captionsErrorLabel => appModel.translate('closed_captions_error');
  String get captionsTargetLabel =>
      appModel.translate('closed_captions_target');
  String get captionsAppLabel => appModel.translate('closed_captions_app');
  String get captionsOtherLabel => appModel.translate('closed_captions_other');
  String get captionsUnavailableLabel =>
      appModel.translate('closed_captions_unavailable');

  @override
  Widget build(BuildContext context) {
    List<String>? cachedLanguages =
        PlayerYoutubeSource.instance.getCaptionsLanguages(widget.item);
    if (cachedLanguages != null) {
      return buildCaptionsData(cachedLanguages);
    }

    return FutureBuilder<List<String>>(
      future: PlayerYoutubeSource.instance
          .getAvailableCaptionLanguages(widget.item),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return buildCaptionsData(snapshot.data!);
        } else if (snapshot.hasError) {
          return buildCaptionsError();
        } else {
          return buildCaptionsQuerying();
        }
      },
    );
  }

  Widget buildCaptionsData(List<String> captionsLanguages) {
    List<String>? languageCodes = captionsLanguages;
    List<String> shortenedLanguageCodes = languageCodes;
    for (int i = 0; i < shortenedLanguageCodes.length; i++) {
      shortenedLanguageCodes[i] = shortenedLanguageCodes[i].substring(0, 2);
    }
    String targetLanguage = appModel.targetLanguage.languageCode;
    String appLanguage = appModel.appLocale.languageCode;

    bool hasTargetLanguage = languageCodes.contains(targetLanguage) ||
        shortenedLanguageCodes.contains(targetLanguage);
    bool hasAppLanguage = languageCodes.contains(appLanguage) ||
        shortenedLanguageCodes.contains(appLanguage);

    bool hasNoLanguage = languageCodes.isEmpty;

    if (hasTargetLanguage) {
      return buildCaptionsTarget();
    } else if (hasAppLanguage) {
      return buildCaptionsApp();
    } else if (hasNoLanguage) {
      return buildCaptionsUnavailable();
    } else {
      return buildCaptionsOther();
    }
  }

  Widget buildCaptionsQuerying() {
    return buildCaptionsRow(
      icon: Icons.closed_caption,
      label: captionsQueryLabel,
      loading: true,
      color: Colors.grey,
      overrideColor: theme.unselectedWidgetColor,
    );
  }

  Widget buildCaptionsError() {
    return buildCaptionsRow(
      icon: Icons.error,
      label: captionsErrorLabel,
      color: Colors.grey,
      overrideColor: theme.unselectedWidgetColor,
    );
  }

  Widget buildCaptionsTarget() {
    return buildCaptionsRow(
      icon: Icons.closed_caption,
      label: captionsTargetLabel,
      color: Colors.green,
    );
  }

  Widget buildCaptionsApp() {
    return buildCaptionsRow(
      icon: Icons.closed_caption,
      label: captionsAppLabel,
      color: Colors.blue,
    );
  }

  Widget buildCaptionsOther() {
    return buildCaptionsRow(
      icon: Icons.closed_caption,
      label: captionsOtherLabel,
      color: Colors.orange,
    );
  }

  Widget buildCaptionsUnavailable() {
    return buildCaptionsRow(
      icon: Icons.closed_caption_disabled,
      label: captionsUnavailableLabel,
      color: Colors.red,
    );
  }

  Widget buildCaptionsRow({
    required String label,
    required IconData icon,
    required MaterialColor color,
    Color? overrideColor,
    bool loading = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: overrideColor ??
              (appModel.isDarkMode ? color.shade200 : color.shade600),
          size: 12,
        ),
        const Space.small(),
        Text(
          label,
          style: TextStyle(
            color: overrideColor ??
                (appModel.isDarkMode ? color.shade200 : color.shade600),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
        ),
        if (loading)
          SizedBox(
            width: 12,
            height: 12,
            child: JumpingDotsProgressIndicator(
              color: overrideColor ??
                  (appModel.isDarkMode ? color.shade200 : color.shade600),
            ),
          )
      ],
    );
  }
}
