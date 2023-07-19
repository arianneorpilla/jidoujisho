import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// The content of the dialog when editing [SubtitleOptions].
class SubtitleAudioSeekControlDialogPage extends BasePage {
  /// Create an instance of this page.
  const SubtitleAudioSeekControlDialogPage({
    required this.notifier,
    super.key,
  });

  /// Notifier for the subtitle options.
  final ValueNotifier<SubtitleOptions> notifier;

  @override
  BasePageState createState() => _SubtitleAudioSeekControlDialogPage();
}

class _SubtitleAudioSeekControlDialogPage
    extends BasePageState<SubtitleAudioSeekControlDialogPage> {
  // late SubtitleOptions _options;

  @override
  void initState() {
    super.initState();
    // _options = widget.notifier.value;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: MediaQuery.of(context).orientation == Orientation.portrait
          ? Spacing.of(context).insets.exceptBottom.big
          : Spacing.of(context).insets.exceptBottom.normal.copyWith(
                left: Spacing.of(context).spaces.semiBig,
                right: Spacing.of(context).spaces.semiBig,
              ),
      actionsPadding: Spacing.of(context).insets.exceptBottom.normal.copyWith(
            left: Spacing.of(context).spaces.normal,
            right: Spacing.of(context).spaces.normal,
            bottom: Spacing.of(context).spaces.normal,
            top: Spacing.of(context).spaces.extraSmall,
          ),
      content: buildContent(),
      actions: actions,
    );
  }

  Widget buildContent() {
    ScrollController scrollController = ScrollController();
    return RawScrollbar(
      thickness: 3,
      thumbVisibility: true,
      controller: scrollController,
      child: Padding(
        padding: Spacing.of(context).insets.onlyRight.normal,
        child: SingleChildScrollView(
          controller: scrollController,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * (1 / 3),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text('text')],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> setValues({required bool saveOptions}) async {
    Navigator.pop(context);
  }

  List<Widget> get actions => [
        buildSaveButton(),
        buildSetButton(),
      ];

  Widget buildSaveButton() {
    return TextButton(
      onPressed: executeSave,
      child: Text(
        t.dialog_save,
      ),
    );
  }

  Widget buildSetButton() {
    return TextButton(
      onPressed: executeSet,
      child: Text(
        t.dialog_set,
      ),
    );
  }

  void executeCancel() async {
    Navigator.pop(context);
  }

  void executeSave() async {
    await setValues(saveOptions: true);
  }

  void executeSet() async {
    await setValues(saveOptions: false);
  }
}
