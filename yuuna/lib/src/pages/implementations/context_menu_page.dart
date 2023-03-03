import 'package:flutter/material.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/pages.dart';

/// The page shown after performing a recursive dictionary lookup.
class ContextMenuPage extends BasePage {
  /// Create an instance of this page.
  const ContextMenuPage({
    required this.searchTerm,
    super.key,
  });

  /// The initial search term that this page searches on initialisation.
  final String searchTerm;

  @override
  BasePageState<ContextMenuPage> createState() => _ContextMenuPageState();
}

class _ContextMenuPageState extends BasePageState<ContextMenuPage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.background,
      body: FutureBuilder<DictionarySearchResult>(
          future: appModel.searchDictionary(
            searchTerm: widget.searchTerm,
            searchWithWildcards: false,
          ),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: Container(
                  height: 48,
                  width: 48,
                  padding: const EdgeInsets.all(16),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(
                        Theme.of(context).unselectedWidgetColor),
                  ),
                ),
              );
            }

            return Theme(
              data: Theme.of(context)
                  .copyWith(scaffoldBackgroundColor: Colors.transparent),
              child: DictionaryResultPage(
                result: snapshot.data!,
                onSearch: (searchTerm) => super.onContextSearch(searchTerm),
                onStash: (searchTerm) => super.onContextStash(searchTerm),
              ),
            );
          }),
    );
  }
}
