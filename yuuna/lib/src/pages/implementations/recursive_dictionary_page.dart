import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// The page shown after performing a recursive dictionary lookup.
class RecursiveDictionaryPage extends BasePage {
  /// Create an instance of this page.
  const RecursiveDictionaryPage({
    required this.searchTerm,
    super.key,
  });

  /// The initial search term that this page searches on initialisation.
  final String searchTerm;

  @override
  BasePageState<RecursiveDictionaryPage> createState() =>
      _RecursiveDictionaryPageState();
}

class _RecursiveDictionaryPageState
    extends BasePageState<RecursiveDictionaryPage> {
  String get backLabel => appModel.translate('back');
  String get dictionariesLabel => appModel.translate('dictionaries');
  String get searchLabel => appModel.translate('search');
  String get searchEllipsisLabel => appModel.translate('search_ellipsis');
  String get noDictionariesLabel =>
      appModel.translate('dictionaries_menu_empty');
  String get noSearchResultsLabel => appModel.translate('no_search_results');
  String get enterSearchTermLabel => appModel.translate('enter_search_term');
  String get clearLabel => appModel.translate('clear');

  final FloatingSearchBarController _controller = FloatingSearchBarController();

  DictionaryResult? _result;

  bool _isSearching = false;

  @override
  void initState() {
    super.initState();

    _controller.query = widget.searchTerm;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.open();

      Future.delayed(const Duration(milliseconds: 10), () {
        FocusScope.of(context).unfocus();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).backgroundColor.withOpacity(0.9),
      body: SafeArea(
        child: buildFloatingSearchBar(),
      ),
    );
  }

  Widget buildFloatingSearchBar() {
    return FloatingSearchBar(
      hint: searchEllipsisLabel,
      controller: _controller,
      builder: buildFloatingSearchBody,
      borderRadius: BorderRadius.zero,
      elevation: 0,
      backgroundColor:
          appModel.isDarkMode ? theme.cardColor : const Color(0xFFE5E5E5),
      backdropColor: Colors.transparent,
      accentColor: theme.colorScheme.primary,
      scrollPadding: const EdgeInsets.only(top: 6, bottom: 56),
      transitionDuration: Duration.zero,
      margins: const EdgeInsets.symmetric(horizontal: 6),
      width: double.maxFinite,
      transition: SlideFadeFloatingSearchBarTransition(),
      automaticallyImplyBackButton: false,
      onFocusChanged: (focused) {
        if (!focused) {
          Navigator.pop(context);
        }
      },
      progress: _isSearching,
      leadingActions: [
        buildDictionaryButton(),
        buildBackButton(),
      ],
      actions: [
        buildSearchButton(),
      ],
      onQueryChanged: (query) async {
        setState(() {
          _isSearching = true;
        });

        try {
          _result = await appModel.searchDictionary(query);
        } finally {
          setState(() {
            _isSearching = false;
          });
        }
      },
    );
  }

  Widget buildDictionaryButton() {
    return FloatingSearchBarAction(
      child: JidoujishoIconButton(
        size: textTheme.titleLarge?.fontSize,
        tooltip: dictionariesLabel,
        icon: Icons.auto_stories,
        onTap: appModel.showDictionaryMenu,
      ),
    );
  }

  Widget buildBackButton() {
    return FloatingSearchBarAction(
      showIfOpened: true,
      showIfClosed: false,
      child: JidoujishoIconButton(
        size: textTheme.titleLarge?.fontSize,
        tooltip: backLabel,
        icon: Icons.arrow_back,
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget buildSearchButton() {
    return FloatingSearchBarAction.searchToClear(
      color: theme.appBarTheme.foregroundColor,
      size: textTheme.titleLarge!.fontSize!,
      searchButtonSemanticLabel: searchLabel,
      clearButtonSemanticLabel: clearLabel,
    );
  }

  Widget buildFloatingSearchBody(
    BuildContext context,
    Animation<double> transition,
  ) {
    if (appModel.dictionaries.isEmpty) {
      return buildImportDictionariesPlaceholderMessage();
    }
    if (_controller.query.isEmpty) {
      return buildEnterSearchTermPlaceholderMessage();
    }
    if (_isSearching || _result?.searchTerm != _controller.query) {
      if (_result != null) {
        return buildSearchResult();
      } else {
        return const SizedBox.shrink();
      }
    }
    if (_result == null || _result!.mapping.isEmpty) {
      return buildNoSearchResultsPlaceholderMessage();
    }

    return buildSearchResult();
  }

  Widget buildSearchResult() {
    return ClipRect(
      child: DictionaryResultPage(
        result: _result!,
        onTextSelect: (selection) {
          Navigator.push(
            context,
            PageRouteBuilder(
              opaque: false,
              pageBuilder: (context, animation1, animation2) =>
                  RecursiveDictionaryPage(searchTerm: selection),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        },
      ),
    );
  }

  /// Get padding meant for a placeholder message in a floating body.
  EdgeInsets get floatingBodyPadding => EdgeInsets.only(
        top: (MediaQuery.of(context).size.height / 2) -
            (AppBar().preferredSize.height * 2),
      );

  Widget buildEnterSearchTermPlaceholderMessage() {
    return Padding(
      padding: floatingBodyPadding,
      child: Center(
        child: JidoujishoPlaceholderMessage(
          icon: Icons.search,
          message: enterSearchTermLabel,
        ),
      ),
    );
  }

  Widget buildImportDictionariesPlaceholderMessage() {
    return Padding(
      padding: floatingBodyPadding,
      child: Center(
        child: JidoujishoPlaceholderMessage(
          icon: Icons.auto_stories,
          message: noDictionariesLabel,
        ),
      ),
    );
  }

  Widget buildNoSearchResultsPlaceholderMessage() {
    return Padding(
      padding: floatingBodyPadding,
      child: Center(
        child: JidoujishoPlaceholderMessage(
          icon: Icons.search_off,
          message: noSearchResultsLabel.replaceAll(
            '%searchTerm%',
            _controller.query,
          ),
        ),
      ),
    );
  }
}
