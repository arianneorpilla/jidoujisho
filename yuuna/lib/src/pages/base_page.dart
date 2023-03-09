import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/models.dart';
import 'package:yuuna/utils.dart';

/// A page template which assumes use of [BasePageState] by which all pages
/// in the app will conveniently share base functionality.
abstract class BasePage extends ConsumerStatefulWidget {
  /// Create an instance of this page.
  const BasePage({super.key});

  @override
  BasePageState<BasePage> createState() => BasePageState();
}

/// A base class for providing all pages in the app with a collection
/// of shared functions and variables. In large part, this was implemented to
/// define shortcuts for common lengthy methods across UI code.
class BasePageState<T extends BasePage> extends ConsumerState<T> {
  /// Access the global model responsible for app-wide state management.
  AppModel get appModel => ref.watch(appProvider);

  /// Access the global model responsible for creator state management.
  CreatorModel get creatorModel => ref.watch(creatorProvider);

  /// Access the global model responsible for app-wide state management without
  /// listening to state updates. Useful when accessing state from [initState].
  AppModel get appModelNoUpdate => ref.read(appProvider);

  /// Access the global model responsible for creator state management. without
  /// listening to state updates. Useful when accessing state from [initState].
  CreatorModel get creatorModelNoUpdate => ref.read(creatorProvider);

  /// Shortcut for accessing the app-wide theme-defined text theme.
  TextTheme get textTheme => Theme.of(context).textTheme;

  /// Shortcut for accessing the app-wide theme.
  ThemeData get theme => Theme.of(context);

  /// Get the selection controls for a [SelectableText].
  MaterialTextSelectionControls get selectionControls =>
      JidoujishoTextSelectionControls(
        searchAction: onContextSearch,
        searchActionLabel: t.search,
        stashAction: onContextStash,
        stashActionLabel: t.stash,
        allowCopy: true,
        allowSelectAll: true,
        allowCut: true,
        allowPaste: true,
      );

  /// Action to perform upon using the Search context option.
  void onContextSearch(String searchTerm, {String? sentence = ''}) async {
    await appModel.openRecursiveDictionarySearch(
      searchTerm: searchTerm,
      killOnPop: false,
    );
  }

  /// Action to perform upon using the Stash context option.
  void onContextStash(String searchTerm) {
    appModel.addToStash(terms: [searchTerm]);
  }

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }

  /// Standard error message for use across the application.
  /// General widget for showing an error or a retry screen.
  Widget buildError({
    Object? error,
    StackTrace? stack,
    Function()? refresh,
  }) {
    return Center(
      child: JidoujishoPlaceholderMessage(
        icon: Icons.error,
        message: '$error',
      ),
    );
  }

  /// Standard loading circle for use across the application.
  Widget buildLoading() {
    return Center(
      child: SizedBox(
        height: Spacing.of(context).spaces.big,
        width: Spacing.of(context).spaces.big,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
        ),
      ),
    );
  }
}
