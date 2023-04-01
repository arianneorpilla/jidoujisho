import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// The page for browsing a catalog until a volume is opened.
class MokuroCatalogBrowsePage extends BasePage {
  /// Create an instance of this page.
  const MokuroCatalogBrowsePage({
    required this.catalog,
    super.key,
  });

  /// The catalog pertaining to this page.
  final MokuroCatalog catalog;

  @override
  BasePageState createState() => _MokuroCatalogBrowsePageState();
}

class _MokuroCatalogBrowsePageState
    extends BasePageState<MokuroCatalogBrowsePage> {
  late final ValueNotifier<String> _titleNotifier;
  late final ValueNotifier<String> _urlNotifier;
  final ValueNotifier<bool> _backAvailableNotifier = ValueNotifier<bool>(false);

  late InAppWebViewController _controller;

  @override
  void initState() {
    super.initState();

    _titleNotifier = ValueNotifier<String>(widget.catalog.name);
    _urlNotifier = ValueNotifier<String>(widget.catalog.url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: buildBody(),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      leading: buildBackButton(),
      title: buildTitle(),
      actions: buildActions(),
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

  List<Widget> buildActions() {
    return [
      buildGoBackButton(),
      const Space.small(),
      buildBookmarkButton(),
      const Space.extraSmall(),
    ];
  }

  Widget buildGoBackButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: _backAvailableNotifier,
      builder: (context, value, child) {
        if (!value) {
          return const SizedBox.shrink();
        } else {
          return JidoujishoIconButton(
            tooltip: t.back,
            icon: Icons.keyboard_return,
            onTap: _controller.goBack,
          );
        }
      },
    );
  }

  Widget buildBookmarkButton() {
    return JidoujishoIconButton(
      tooltip: t.enhancements,
      icon: Icons.bookmark_add,
      onTap: () async {
        showDialog(
          context: context,
          builder: (context) => MokuroCatalogEditDialogPage(
            catalog: MokuroCatalog(
              name: _titleNotifier.value,
              url: _urlNotifier.value,
              order: appModel.nextCatalogOrder,
            ),
          ),
        );
      },
    );
  }

  Widget buildTitle() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              ValueListenableBuilder<String>(
                valueListenable: _titleNotifier,
                builder: (context, value, child) {
                  return JidoujishoMarquee(
                    text: value,
                    style: TextStyle(fontSize: textTheme.titleMedium?.fontSize),
                  );
                },
              ),
              ValueListenableBuilder<String>(
                valueListenable: _urlNotifier,
                builder: (context, value, child) {
                  return JidoujishoMarquee(
                    text: value,
                    style: TextStyle(fontSize: textTheme.labelSmall?.fontSize),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildBody() {
    return InAppWebView(
      initialOptions: InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          userAgent: 'Mozilla 5.0 (Linux; U; Android 13) Chrome/104.0.5112.99',
        ),
        android: AndroidInAppWebViewOptions(
          forceDark: appModel.isDarkMode
              ? AndroidForceDark.FORCE_DARK_ON
              : AndroidForceDark.FORCE_DARK_OFF,
        ),
      ),
      initialUrlRequest: URLRequest(url: Uri.parse(widget.catalog.url)),
      onWebViewCreated: (controller) {
        _controller = controller;
      },
      onLoadStop: (controller, uri) async {
        String title = await controller.getTitle() ?? '';
        String url = (await controller.getUrl()).toString();
        bool canGoBack = await controller.canGoBack();

        _titleNotifier.value = title;
        _urlNotifier.value = url;
        _backAvailableNotifier.value = canGoBack;

        MediaItem? item =
            await ReaderMokuroSource.instance.generateMediaItemFromWebView(
          appModel: appModel,
          controller: controller,
        );
        if (item != null) {
          Navigator.popUntil(context, (route) => route.isFirst);
          appModel.openMedia(
            context: context,
            ref: ref,
            mediaSource: ReaderMokuroSource.instance,
            item: item,
          );
        }
      },
    );
  }
}
