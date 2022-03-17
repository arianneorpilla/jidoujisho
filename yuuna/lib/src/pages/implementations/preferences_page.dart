import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/pages.dart';

/// Appears when the settings icon is tapped on from the home screen. This
/// screen houses and categorises top-level settings page choices.
class SettingsPage extends BasePage {
  /// Construct an instance of the [HomePage].
  const SettingsPage({Key? key}) : super(key: key);

  @override
  BasePageState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends BasePageState<SettingsPage> {
  String get preferences => appModel.translate('preferences');
  String get generalTitle => appModel.translate('section_general');
  String get generalDesc => appModel.translate('section_desc_general');
  String get dictionariesTitle => appModel.translate('section_dictionaries');
  String get dictionariesDesc =>
      appModel.translate('section_desc_dictionaries');
  String get creatorTitle => appModel.translate('section_creator');
  String get creatorDesc => appModel.translate('section_desc_creator');
  String get mediaTitle => appModel.translate('section_media');
  String get mediaDesc => appModel.translate('section_desc_media');
  String get languageTitle => appModel.translate('section_language');
  String get languageDesc => appModel.translate('section_desc_language');
  String get debuggingTitle => appModel.translate('section_debugging');
  String get debuggingDesc => appModel.translate('section_desc_debugging');
  String get licensesTitle => appModel.translate('section_licenses');
  String get licensesDesc => appModel.translate('section_desc_licenses');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: buildBody(),
    );
  }

  PreferredSizeWidget? buildAppBar() {
    return AppBar(
      leading: const BackButton(),
      title: Text(preferences),
    );
  }

  Widget buildBody() {
    return SettingsList(
      lightTheme: lightTheme,
      darkTheme: darkTheme,
      sections: [
        SettingsSection(
          tiles: [
            SettingsTile(
              leading: const Icon(Icons.tune_outlined),
              title: Text(generalTitle),
              description: Text(generalDesc),
              onPressed: (_) => showGeneralSection(),
            ),
            SettingsTile(
              leading: const Icon(Icons.auto_stories_outlined),
              title: Text(dictionariesTitle),
              description: Text(dictionariesDesc),
              onPressed: (_) => showDictionariesSection(),
            ),
            SettingsTile(
              leading: const Icon(Icons.note_add_outlined),
              title: Text(creatorTitle),
              description: Text(creatorDesc),
              onPressed: (_) => showCreatorSection(),
            ),
            SettingsTile(
              leading: const Icon(Icons.perm_media_outlined),
              title: Text(mediaTitle),
              description: Text(mediaDesc),
              onPressed: (_) => showMediaSection(),
            ),
            SettingsTile(
              leading: const Icon(Icons.translate_outlined),
              title: Text(languageTitle),
              description: Text(languageDesc),
              onPressed: (_) => showLanguageSection(),
            ),
            SettingsTile(
              leading: const Icon(Icons.developer_mode_outlined),
              title: Text(debuggingTitle),
              description: Text(debuggingDesc),
              onPressed: (_) => showDebuggingSection(),
            ),
            SettingsTile(
              leading: const Icon(Icons.info_outline),
              title: Text(licensesTitle),
              description: Text(licensesDesc),
              onPressed: (_) => showLicensesSection(),
            ),
          ],
        ),
      ],
    );
  }

  void showGeneralSection() {}
  void showDictionariesSection() {}
  void showCreatorSection() {}
  void showMediaSection() {}
  void showLanguageSection() {}
  void showDebuggingSection() {}

  void showLicensesSection() {
    String applicationLegalese = 'A highly versatile and modular framework '
        'enabling language-agnostic immersion learning on mobile. \n\n'
        'Originally built for the Japanese language learning '
        'community by Leo Rafael Orpilla. Logo by suzy and Aaron Marbella.'
        '\n\njidoujisho is free and open source software. Visit the '
        'repository for a more comprehensive list of other licenses '
        'and attribution notices. Liking the application? Help out by '
        'providing feedback, making a donation, reporting issues or '
        'collaborating for further improvements on GitHub.';

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => Theme(
          data: Theme.of(context).copyWith(
            cardColor: Theme.of(context).backgroundColor,
          ),
          child: LicensePage(
            applicationName: appModel.packageInfo.appName,
            applicationVersion: appModel.packageInfo.version,
            applicationLegalese: applicationLegalese,
            applicationIcon: Padding(
              padding: Spacing.of(context).insets.all.normal,
              child: Image.asset(
                'assets/meta/icon.png',
                height: 128,
                width: 128,
              ),
            ),
          ),
        ),
      ),
    );
  }

  SettingsThemeData get lightTheme => SettingsThemeData(
        settingsListBackground: Colors.white,
        titleTextColor: Theme.of(context).unselectedWidgetColor,
        leadingIconsColor: Colors.red,
      );

  SettingsThemeData get darkTheme => SettingsThemeData(
        settingsListBackground: Colors.black,
        titleTextColor: Theme.of(context).unselectedWidgetColor,
        leadingIconsColor: Colors.red,
      );
}
