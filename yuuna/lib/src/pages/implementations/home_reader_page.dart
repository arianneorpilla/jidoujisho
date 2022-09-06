import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';

/// The body content for the Reader tab in the main menu.
class HomeReaderPage extends BaseTabPage {
  /// Create an instance of this page.
  const HomeReaderPage({super.key});

  @override
  BaseTabPageState<BaseTabPage> createState() => _HomeReaderPageState();
}

class _HomeReaderPageState<T extends BaseTabPage> extends BaseTabPageState {
  @override
  MediaType get mediaType => ReaderMediaType.instance;
}
