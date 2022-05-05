import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';
import 'package:yuuna/models.dart';

/// The page used for the Card Creator to modify a note before export. Relies
/// on the [CreatorModel].
class CreatorPage extends BasePage {
  /// Construct an instance of the [HomePage].
  const CreatorPage({
    required this.decks,
    Key? key,
  }) : super(key: key);

  /// List of decks that are fetched prior to navigating to this page.
  final List<String> decks;

  @override
  BasePageState<CreatorPage> createState() => _CreatorPageState();
}

class _CreatorPageState extends BasePageState<CreatorPage> {
  String get creatorExportingAsLabel =>
      appModel.translate('creator_exporting_as');
  String get creatorExportCard => appModel.translate('creator_export_card');

  /// Access the global model responsible for creator state management.
  CreatorModel get creatorModel => ref.watch(creatorProvider);

  /// Get the export details pertaining to the fields.
  ExportDetails get exportDetails => creatorModel.getExportDetails(ref);

  final ScrollController _scrollController = ScrollController();

  Future<bool> onWillPop() async {
    creatorModel.clearAll();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: buildAppBar(),
          body: buildBody(),
        ),
      ),
    );
  }

  PreferredSizeWidget? buildAppBar() {
    return AppBar(
      leading: buildLeading(),
      title: buildTitle(),
      actions: buildActions(),
      titleSpacing: 8,
    );
  }

  Widget buildExportButton() {
    bool isExportable = exportDetails.isExportable;
    Color activeButtonColor =
        Theme.of(context).unselectedWidgetColor.withOpacity(0.1);
    Color inactiveButtonColor =
        Theme.of(context).unselectedWidgetColor.withOpacity(0.05);
    Color activeTextColor = Theme.of(context).appBarTheme.foregroundColor!;
    Color inactiveTextColor = Theme.of(context).unselectedWidgetColor;

    return Padding(
      padding: Spacing.of(context).insets.all.normal,
      child: InkWell(
        onTap: isExportable ? () {} : null,
        child: Container(
          padding: Spacing.of(context).insets.vertical.normal,
          alignment: Alignment.center,
          width: double.infinity,
          color: isExportable ? activeButtonColor : inactiveButtonColor,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.note_add,
                size: textTheme.titleSmall?.fontSize,
                color: isExportable ? activeTextColor : inactiveTextColor,
              ),
              const Space.small(),
              Text(
                creatorExportCard,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isExportable ? activeTextColor : inactiveTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget? buildBody() {
    return Column(
      children: [
        Expanded(child: buildPortraitFields()),
        buildExportButton(),
      ],
    );
  }

  Widget buildPortraitFields() {
    return Padding(
      padding: Spacing.of(context).insets.horizontal.small,
      child: Scrollbar(
        controller: _scrollController,
        child: ListView(
          controller: _scrollController,
          children: [
            buildDeckDropdown(),
            buildTextFields(),
          ],
        ),
      ),
    );
  }

  Widget buildDeckDropdown() {
    return JidoujishoDropdown<String>(
      options: widget.decks,
      initialOption: appModel.lastSelectedDeckName,
      generateLabel: (deckName) => deckName,
      onChanged: (deckName) {
        appModel.setLastSelectedDeck(deckName!);
        setState(() {});
      },
    );
  }

  Widget buildTextFields() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: Field.values.length - 1,
      itemBuilder: (context, index) {
        Field field = Field.values[index];
        return buildTextField(field: field);
      },
    );
  }

  Widget? buildLeading() {
    return const BackButton();
  }

  Widget buildTitle() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              JidoujishoMarquee(
                text: creatorExportingAsLabel,
                style: TextStyle(fontSize: textTheme.labelSmall?.fontSize),
              ),
              JidoujishoMarquee(
                text: appModel.lastSelectedMappingName,
                style: TextStyle(fontSize: textTheme.titleMedium?.fontSize),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildTextField({
    required Field field,
  }) {
    return TextFormField(
      onChanged: (value) {
        setState(() {});
      },
      controller: creatorModel.getFieldController(field),
      decoration: InputDecoration(
        prefixIcon: Icon(field.icon(appModel)),
        labelText: field.label(appModel),
        hintText: field.hint(appModel),
      ),
    );
  }

  List<Widget> buildActions() {
    return [
      buildManageEnhancementsButton(),
      const Space.small(),
      buildSwitchProfilesButton(),
      const Space.extraSmall(),
    ];
  }

  Widget buildSwitchProfilesButton() {
    return JidoujishoIconButton(
      tooltip: appModel.translate('switch_profiles'),
      icon: Icons.switch_account,
      onTapDown: openProfilesMenu,
    );
  }

  Widget buildManageEnhancementsButton() {
    return JidoujishoIconButton(
      tooltip: appModel.translate('enhancements'),
      icon: Icons.auto_fix_high,
      onTap: () {},
    );
  }

  PopupMenuItem<VoidCallback> buildPopupItem({
    required String label,
    required Function() action,
    IconData? icon,
    Color? color,
  }) {
    return PopupMenuItem<VoidCallback>(
      child: Row(
        children: [
          if (icon != null)
            Icon(
              icon,
              size: textTheme.bodyMedium?.fontSize,
              color: color,
            ),
          if (icon != null) const Space.normal(),
          Text(
            label,
            style: TextStyle(color: color),
          ),
        ],
      ),
      value: action,
    );
  }

  void openProfilesMenu(TapDownDetails details) async {
    RelativeRect position = RelativeRect.fromLTRB(
        details.globalPosition.dx, details.globalPosition.dy, 0, 0);
    Function()? selectedAction = await showMenu(
      context: context,
      position: position,
      items: getProfileItems(),
    );

    selectedAction?.call();
  }

  List<PopupMenuItem<VoidCallback>> getProfileItems() {
    return appModel.mappings.map((mapping) {
      return buildPopupItem(
        label: mapping.label,
        action: () async {
          await appModel.setLastSelectedMapping(mapping);
          setState(() {});
        },
      );
    }).toList();
  }
}
