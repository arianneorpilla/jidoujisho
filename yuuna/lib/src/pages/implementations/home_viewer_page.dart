import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';

/// The body content for the Viewer tab in the main menu.
class HomeViewerPage extends BaseTabPage {
  /// Create an instance of this page.
  const HomeViewerPage({super.key});

  @override
  BaseTabPageState<BaseTabPage> createState() => _HomeViewerPageState();
}

class _HomeViewerPageState<T extends BaseTabPage> extends BaseTabPageState {
  @override
  MediaType get mediaType => ViewerMediaType.instance;
}
