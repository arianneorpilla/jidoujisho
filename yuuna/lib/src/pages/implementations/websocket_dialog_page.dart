import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// Used by the Reader WebSocket Source.
class WebsocketDialogPage extends BasePage {
  /// Create an instance of this page.
  const WebsocketDialogPage({
    required this.address,
    required this.onConnect,
    super.key,
  });

  /// Server address.
  final String address;

  /// On connect action.
  final Function(String) onConnect;

  @override
  BasePageState createState() => _WebsocketDialogPageState();
}

class _WebsocketDialogPageState extends BasePageState<WebsocketDialogPage> {
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();

    _addressController = TextEditingController(text: widget.address);
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

  List<Widget> get actions => [buildConnectButton()];

  Widget buildContent() {
    ScrollController scrollController = ScrollController();
    return RawScrollbar(
      thickness: 3,
      thumbVisibility: true,
      controller: scrollController,
      child: SingleChildScrollView(
        controller: scrollController,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * (1 / 3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                controller: _addressController,
                decoration: InputDecoration(
                  hintText: 'wss://',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelText: t.server_address,
                  suffixIcon: JidoujishoIconButton(
                    size: 18,
                    tooltip: t.clear,
                    onTap: _addressController.clear,
                    icon: Icons.clear,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildConnectButton() {
    return TextButton(
      onPressed: executeSearch,
      child: Text(t.dialog_connect),
    );
  }

  void executeSearch() async {
    widget.onConnect(
      _addressController.text,
    );
  }
}
