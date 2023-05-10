import 'package:flutter/material.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// The page shown to view a result in dictionary history.
class RecursiveDictionaryHistoryPage extends BasePage {
  /// Create an instance of this page.
  const RecursiveDictionaryHistoryPage({
    required this.result,
    super.key,
  });

  /// The result made from a dictionary database search.
  final DictionarySearchResult result;

  @override
  BasePageState<RecursiveDictionaryHistoryPage> createState() =>
      _RecursiveDictionaryHistoryPageState();
}

class _RecursiveDictionaryHistoryPageState
    extends BasePageState<RecursiveDictionaryHistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: buildAppBar(),
      body: SafeArea(
        child: DictionaryResultPage(
          result: widget.result,
          onSearch: onSearch,
          onStash: onStash,
          onShare: onShare,
          updateHistory: false,
        ),
      ),
    );
  }

  Widget buildTitle() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: JidoujishoMarquee(
            text: widget.result.searchTerm.replaceAll('\n', ' '),
            style: TextStyle(
              fontSize: textTheme.titleMedium?.fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget? buildAppBar() {
    return AppBar(
      leading: buildBackButton(),
      title: buildTitle(),
      titleSpacing: 8,
    );
  }

  Widget buildBackButton() {
    return JidoujishoIconButton(
      tooltip: t.back,
      icon: Icons.arrow_back,
      onTap: () {
        Navigator.pop(context);
      },
    );
  }
}
