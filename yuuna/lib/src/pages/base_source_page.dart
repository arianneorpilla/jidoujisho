import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// A page template which assumes use of [BaseSourcePageState] by which all
/// pages in the app that are used for when using a certain source will
/// conveniently share base functionality.
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
  final ValueNotifier<DictionaryResult?> _dictionaryResultNotifier =
      ValueNotifier<DictionaryResult?>(null);

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
          onPressed: () => Navigator.pop(context, true),
        ),
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
  void searchDictionaryResult({
    required String searchTerm,
    required JidoujishoPopupPosition position,
  }) async {
    DictionaryResult dictionaryResult =
        await appModel.searchDictionary(searchTerm);
    _popupPosition = position;

    await appModel.addToDictionaryHistory(result: dictionaryResult);
    _dictionaryResultNotifier.value = dictionaryResult;
  }

  /// Hide the dictionary and dispose of the current result.
  void clearDictionaryResult() {
    _dictionaryResultNotifier.value = null;
    appModel.currentMediaSource?.clearCurrentSentence();
  }

  /// Build a dictionary showing the result with positioning.
  /// If the result is null, show nothing.
  Widget buildDictionary() {
    return ValueListenableBuilder<DictionaryResult?>(
      valueListenable: _dictionaryResultNotifier,
      builder: (context, result, _) {
        if (result == null) {
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

               case JidoujishoPopupPosition.topTwoThirds:
            return buildTopTwoThirdsDictionary();
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

    /// The dictionary in the case of [JidoujishoPopupPosition.topTwoThirds].
  Widget buildTopTwoThirdsDictionary() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 2,
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
      key: const ValueKey('result'),
      onDismissed: (dismissDirection) {
        clearDictionaryResult();
      },
      child: Container(
        padding: Spacing.of(context).insets.all.semiSmall,
        margin: Spacing.of(context).insets.all.normal,
        color: theme.cardColor.withOpacity(dictionaryBackgroundOpacity),
        child: buildSearchResult(),
      ),
    );
  }

  /// Displays the dictionary entries.
  Widget buildSearchResult() {
    if (_dictionaryResultNotifier.value!.terms.isEmpty) {
      return buildNoSearchResultsPlaceholderMessage();
    }

    return ClipRect(
      child: DictionaryResultPage(
        entryOpacity: dictionaryEntryOpacity,
        key: ValueKey(_dictionaryResultNotifier.value),
        onSearch: onSearch,
        onStash: onStash,
        result: _dictionaryResultNotifier.value!,
        spaceBeforeFirstResult: false,
      ),
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

  /// Action upon selecting the Search option.
  void onSearch(String searchTerm) {
    appModel.openRecursiveDictionarySearch(
      searchTerm: searchTerm,
      killOnPop: false,
    );
  }

  /// Action upon selecting the Stash option.
  void onStash(String searchTerm) {
    appModel.addToStash(terms: [searchTerm]);
  }
}
