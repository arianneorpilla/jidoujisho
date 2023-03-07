import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_pip_mode/actions/pip_action.dart';
import 'package:simple_pip_mode/actions/pip_actions_layout.dart';
import 'package:simple_pip_mode/pip_widget.dart';
import 'package:simple_pip_mode/simple_pip.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/i18n/strings.g.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/src/models/app_model.dart';
import 'package:yuuna/utils.dart';
import 'package:collection/collection.dart';

/// The page shown after entering picture-in-picture mode.
class PipPage extends BasePage {
  /// Create an instance of this page.
  const PipPage({
    super.key,
  });

  @override
  BasePageState<PipPage> createState() => _PipPageState();
}

class _PipPageState extends BasePageState<PipPage> {
  String get noSearchResultsLabel => appModel.translate('no_search_results');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SimplePip().enterPipMode(aspectRatio: [16, 9]);
    });
  }

  @override
  void dispose() {
    super.dispose();
    appModel.cancelAccessibilityStream();
  }

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _selectedPositionKey = GlobalKey();
  bool _characterSelectMode = false;

  @override
  Widget build(BuildContext context) {
    ref.watch(accessibilityProvider);

    int currentPosition = ref.watch(pipSearchPositionProvider);
    String lastSearchTerm = ref.watch(pipSearchTermProvider);

    return PipWidget(
      onPipExited: () {
        Navigator.of(context).pop();
      },
      builder: (context) => const SizedBox.shrink(),
      pipBuilder: (context) {
        return Scaffold(
          body: _characterSelectMode
              ? buildWordSelector(
                  lastSearchTerm: lastSearchTerm,
                  currentPosition: currentPosition,
                )
              : buildShowSearchResult(),
        );
      },
      pipLayout: PipActionsLayout.media,
      onPipAction: (action) {
        switch (action) {
          case PipAction.live:
            break;
          case PipAction.play:
            setState(() {
              _characterSelectMode = false;
            });
            ref.refresh(pipSearchResultProvider);

            break;
          case PipAction.pause:
            setState(() {
              _characterSelectMode = true;
            });
            keepCharacterVisible(
              alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
              milliseconds: 0,
            );

            break;

          case PipAction.next:
            if (_characterSelectMode) {
              if (currentPosition != lastSearchTerm.length - 1) {
                ref.watch(pipSearchPositionProvider.notifier).state =
                    currentPosition + 1;
                keepCharacterVisible(
                  alignmentPolicy:
                      ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
                );
              } else {
                ref.watch(pipSearchPositionProvider.notifier).state = 0;
                keepCharacterVisible(
                  alignmentPolicy:
                      ScrollPositionAlignmentPolicy.keepVisibleAtStart,
                );
              }
            } else {
              _scrollController.animateTo(
                _scrollController.offset + 100,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
              );
            }
            break;
          case PipAction.previous:
            if (_characterSelectMode) {
              if (currentPosition != 0) {
                ref.watch(pipSearchPositionProvider.notifier).state =
                    currentPosition - 1;
                keepCharacterVisible(
                  alignmentPolicy:
                      ScrollPositionAlignmentPolicy.keepVisibleAtStart,
                );
              } else {
                ref.watch(pipSearchPositionProvider.notifier).state =
                    lastSearchTerm.length - 1;
                keepCharacterVisible(
                  alignmentPolicy:
                      ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
                );
              }
            } else {
              if (_scrollController.offset > 0) {
                _scrollController.animateTo(
                  _scrollController.offset - 100,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                );
              }
            }
            break;
        }
      },
    );
  }

  void keepCharacterVisible({
    required ScrollPositionAlignmentPolicy alignmentPolicy,
    int milliseconds = 200,
  }) {
    Future.delayed(const Duration(milliseconds: 100), () {
      Scrollable.ensureVisible(
        _selectedPositionKey.currentContext!,
        duration: Duration(milliseconds: milliseconds),
        curve: Curves.easeInOut,
        alignmentPolicy: alignmentPolicy,
      );
    });
  }

  Widget buildWordSelector({
    required String lastSearchTerm,
    required int currentPosition,
  }) {
    return Stack(
      children: [
        Padding(
          padding: Spacing.of(context).insets.all.big,
          child: SingleChildScrollView(
            child: Align(
              alignment: Alignment.topCenter,
              child: Text.rich(
                TextSpan(
                  children: lastSearchTerm.characters
                      .mapIndexed(
                        (index, character) => WidgetSpan(
                          child: Text(
                            character,
                            key: currentPosition == index
                                ? _selectedPositionKey
                                : null,
                            style: TextStyle(
                                fontSize: 24,
                                backgroundColor: currentPosition == index
                                    ? Colors.red.withOpacity(0.5)
                                    : null),
                          ),
                        ),
                      )
                      .toList(),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.1, 0.15, 0.5, 0.85, 0.9, 1.0],
              colors: [
                Theme.of(context).scaffoldBackgroundColor,
                Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
                Theme.of(context).scaffoldBackgroundColor.withOpacity(0.1),
                Theme.of(context).scaffoldBackgroundColor.withOpacity(0),
                Theme.of(context).scaffoldBackgroundColor.withOpacity(0.1),
                Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
                Theme.of(context).scaffoldBackgroundColor,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildPlaceholder() {
    return Center(
      child: JidoujishoPlaceholderMessage(
        icon: Icons.search,
        message: t.enter_search_term,
      ),
    );
  }

  Widget buildShowSearchResult() {
    AsyncValue<DictionarySearchResult?> result =
        ref.watch(pipSearchResultProvider);

    return result.when(
      loading: buildLoading,
      error: (error, stack) => buildError(error: error, stack: stack),
      data: (result) {
        if (result == null || result.searchTerm.isEmpty) {
          return buildPlaceholder();
        }

        if (result.headings.isEmpty) {
          return Center(
            child: JidoujishoPlaceholderMessage(
              icon: Icons.search_off,
              message: noSearchResultsLabel.replaceAll(
                '%searchTerm%',
                result.searchTerm,
              ),
            ),
          );
        }

        return DictionaryResultPage(
          spaceBeforeFirstResult: false,
          scrollController: _scrollController,
          result: result,
          onSearch: (searchTerm) => super.onContextSearch(searchTerm),
          onStash: (searchTerm) => super.onContextStash(searchTerm),
        );
      },
    );
  }
}
