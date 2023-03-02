import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// A page template which assumes use of [BaseSourcePageState] by which all
/// pages in the app that are used for when using a certain source will
/// conveniently share base functionality.f
abstract class BaseSourcePage extends BasePage {
  /// Create an instance of this tab page.
  const BaseSourcePage({
    required this.item,
    super.key,
  });

  /// The media item pertaining to this usage instance of the source.
  final MediaItem? item;

  @override
  BaseSourcePageState<BaseSourcePage> createState();
}

/// A base class for providing all pages used for media in the app with a
/// collection of shared functions and variables. In large part, this was
/// implemented to define shortcuts for common lengthy methods across UI code.
class BaseSourcePageState<T extends BaseSourcePage> extends BasePageState<T> {
  /// Localisation for the alert dialog title.
  String get exitMediaTitle => appModel.translate('exit_media_title');

  /// Localisation for the alert dialog description.
  String get exitMediaDescription =>
      appModel.translate('exit_media_description');

  /// Localisation for no results case.
  String get noSearchResultsLabel => appModel.translate('no_search_results');

  /// Localisation for the Close alert dialog option for closing the source.
  String get dialogClose => appModel.translate('dialog_exit');

  /// Localisation for the Cancel alert dialog option for closing the source.
  String get dialogCancel => appModel.translate('dialog_cancel');

  /// Localisation for context menu option.
  String get creatorLabel => appModel.translate('creator');

  /// Localisation for context menu option.
  String get copyLabel => appModel.translate('copy');

  /// Allows customisation of dictionary background.
  double get dictionaryBackgroundOpacity => 0.95;

  /// Allows customisation of opacity of dictionary entries.
  double get dictionaryEntryOpacity => 1;

  /// The result from the last dictionary search performed with
  /// [searchDictionaryResult].
  final ValueNotifier<DictionarySearchResult?> _dictionaryResultNotifier =
      ValueNotifier<DictionarySearchResult?>(null);

  /// Notifies the popup dictionary to refresh positions.
  final ValueNotifier<bool> _popupPositionNotifier = ValueNotifier<bool>(false);

  /// Notifies the progress bar whether or not to refresh.
  final ValueNotifier<bool> _isSearchingNotifier = ValueNotifier<bool>(false);

  /// Whether or not there is a present dictionary result.
  bool get isDictionaryShown => _dictionaryResultNotifier.value != null;

  /// The popup position for the [buildDictionary] widget.
  JidoujishoPopupPosition _popupPosition = JidoujishoPopupPosition.topHalf;

  /// Standard warning dialog for leaving a source page. All sources should
  /// use this and wrap their [build] function with a [WillPopScope].
  Future<bool> onWillPop() async {
    Widget alertDialog = AlertDialog(
      shape: const RoundedRectangleBorder(),
      title: Text(exitMediaTitle),
      content: Text(exitMediaDescription),
      actions: <Widget>[
        TextButton(
            child: Text(
              dialogClose,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            onPressed: () async {
              Navigator.pop(context, true);
              await appModel.closeMedia(
                context: context,
                ref: ref,
                mediaSource: appModel.currentMediaSource!,
                item: widget.item,
              );
            }),
        TextButton(
          child: Text(
            dialogCancel,
          ),
          onPressed: () => Navigator.pop(context, false),
        ),
      ],
    );

    return await showDialog(
          context: context,
          builder: (context) => alertDialog,
        ) ??
        false;
  }

  /// Perform a search with a given query and update the dictionary search
  /// result. The [position] parameter determines where the pop-up will
  /// be shown on the screen.
  Future<void> searchDictionaryResult({
    required String searchTerm,
    required JidoujishoPopupPosition position,
  }) async {
    late DictionarySearchResult dictionaryResult;
    _popupPosition = position;
    _popupPositionNotifier.value = true;
    try {
      _isSearchingNotifier.value = true;
      dictionaryResult = await appModel.searchDictionary(
        searchTerm: searchTerm,
        searchWithWildcards: false,
      );

      appModel.addToDictionaryHistory(result: dictionaryResult);
      _dictionaryResultNotifier.value = dictionaryResult;
    } finally {
      _isSearchingNotifier.value = false;
    }
  }

  /// Hide the dictionary and dispose of the current result.
  void clearDictionaryResult() async {
    _dictionaryResultNotifier.value = null;
    _popupPositionNotifier.value = false;
    appModel.currentMediaSource?.clearCurrentSentence();
  }

  /// Build a dictionary showing the result with positioning.
  /// If the result is null, show nothing.
  Widget buildDictionary() {
    return MultiValueListenableBuilder(
      valueListenables: [
        _dictionaryResultNotifier,
        _popupPositionNotifier,
      ],
      builder: (context, result, _) {
        if (!_isSearchingNotifier.value &&
            _dictionaryResultNotifier.value == null) {
          return const SizedBox.shrink();
        }

        switch (_popupPosition) {
          case JidoujishoPopupPosition.topHalf:
            return buildTopHalfDictionary();

          case JidoujishoPopupPosition.bottomHalf:
            return buildBottomHalfDictionary();

          case JidoujishoPopupPosition.leftHalf:
            return buildLeftHalfDictionary();

          case JidoujishoPopupPosition.rightHalf:
            return buildRightHalfDictionary();

          case JidoujishoPopupPosition.topThreeFourths:
            return buildTopThreeFourths();
        }
      },
    );
  }

  /// The dictionary in the case of [JidoujishoPopupPosition.topHalf].
  Widget buildTopHalfDictionary() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: buildDictionaryResult(),
        ),
        const Flexible(
          child: SizedBox.shrink(),
        ),
      ],
    );
  }

  /// The dictionary in the case of [JidoujishoPopupPosition.bottomHalf].
  Widget buildBottomHalfDictionary() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Flexible(
          child: SizedBox.shrink(),
        ),
        Flexible(
          child: buildDictionaryResult(),
        ),
      ],
    );
  }

  /// The dictionary in the case of [JidoujishoPopupPosition.leftHalf].
  Widget buildLeftHalfDictionary() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: buildDictionaryResult(),
        ),
        const Flexible(
          child: SizedBox.shrink(),
        ),
      ],
    );
  }

  /// The dictionary in the case of [JidoujishoPopupPosition.rightHalf].
  Widget buildRightHalfDictionary() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Flexible(
          child: SizedBox.shrink(),
        ),
        Flexible(
          child: buildDictionaryResult(),
        ),
      ],
    );
  }

  /// The dictionary in the case of [JidoujishoPopupPosition.topThreeFourths].
  Widget buildTopThreeFourths() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 3,
          child: buildDictionaryResult(),
        ),
        const Flexible(
          child: SizedBox.shrink(),
        ),
      ],
    );
  }

  /// The dictionary result unpositioned. See [buildDictionary] for the
  /// positioned version.
  Widget buildDictionaryResult() {
    return Dismissible(
      key: ValueKey(_dictionaryResultNotifier.value),
      onDismissed: (dismissDirection) {
        clearDictionaryResult();
      },
      dismissThresholds: const {DismissDirection.horizontal: 0.05},
      movementDuration: const Duration(milliseconds: 50),
      child: Container(
        padding: Spacing.of(context).insets.all.semiSmall,
        margin: Spacing.of(context).insets.all.normal,
        color: theme.cardColor.withOpacity(dictionaryBackgroundOpacity),
        child: Stack(
          children: [
            buildSearchResult(),
            buildDictionaryLoading(),
          ],
        ),
      ),
    );
  }

  /// In progress indicator for dictionary searching.
  Widget buildDictionaryLoading() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isSearchingNotifier,
      builder: (context, value, child) {
        return Visibility(
          visible: value,
          child: SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Card(
              color: Colors.transparent,
              elevation: 0,
              shape: const RoundedRectangleBorder(),
              child: Column(
                children: [
                  const LinearProgressIndicator(
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    minHeight: 2.75,
                  ),
                  Expanded(child: Container())
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Displays the dictionary entries.
  Widget buildSearchResult() {
    if (_dictionaryResultNotifier.value == null) {
      return SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Card(
          color: appModel.isDarkMode
              ? Color.fromRGBO(15, 15, 15, dictionaryEntryOpacity)
              : Color.fromRGBO(249, 249, 249, dictionaryEntryOpacity),
          elevation: 0,
          shape: const RoundedRectangleBorder(),
          child: Column(
            children: [Container()],
          ),
        ),
      );
    }

    if (_dictionaryResultNotifier.value!.headings.isEmpty) {
      return buildNoSearchResultsPlaceholderMessage();
    }

    return DictionaryResultPage(
      entryOpacity: dictionaryEntryOpacity,
      key: ValueKey(_dictionaryResultNotifier.value),
      onSearch: onSearch,
      onStash: onStash,
      result: _dictionaryResultNotifier.value!,
      spaceBeforeFirstResult: false,
    );
  }

  /// Placeholder when there are no search results.
  Widget buildNoSearchResultsPlaceholderMessage() {
    return Center(
      child: JidoujishoPlaceholderMessage(
        icon: Icons.search_off,
        message: noSearchResultsLabel.replaceAll(
          '%searchTerm%',
          _dictionaryResultNotifier.value!.searchTerm,
        ),
      ),
    );
  }

  /// Get the result returned from the last search.
  DictionarySearchResult? get currentResult => _dictionaryResultNotifier.value;

  /// Action upon selecting the Search option.
  void onSearch(String searchTerm) async {
    if (appModel.isMediaOpen) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      await Future.delayed(const Duration(milliseconds: 5), () {});
    }
    await appModel.openRecursiveDictionarySearch(
      searchTerm: searchTerm,
      killOnPop: false,
    );
    if (appModel.isMediaOpen) {
      await Future.delayed(const Duration(milliseconds: 5), () {});
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  }

  /// Action upon selecting the Stash option.
  void onStash(String searchTerm) {
    appModel.addToStash(terms: [searchTerm]);
  }
}
