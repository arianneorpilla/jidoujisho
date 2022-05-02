import 'package:chisa/media/media_type.dart';
import 'package:flutter/material.dart';

abstract class MediaPage extends StatefulWidget {
  const MediaPage({
    required this.mediaType,
    required this.uri,
    Key? key,
    this.initialProgress = 0,
  }) : super(key: key);

  final MediaType mediaType;
  final Uri uri;
  final int initialProgress;
}

abstract class MediaPageState extends State<MediaPage> {
  /// A list of parameters pertaining to the media currently being used that
  /// is initialised by the preparation method. Once loading is finished, the
  /// page is reloaded and actual content is shown.
  Map<String, dynamic> mediaParameters = {};

  /// Make the necessary preparations and prepare the media parameters. This
  /// should be called at [initState] with a then, once finished, the page
  /// should reload, showing the actual page content.
  Future<Map<String, dynamic>> prepareMediaParameters();

  /// This should call every time progress changes, or when the media page
  /// is started. This should push a history item to the latest end, and
  /// remove any duplicates if they exist with the same Uri. See
  /// [MediaHistory] for specific implementation details.
  Future<void> updateHistory();

  /// Show the content that appears during loading.
  Widget showLoadingWidget() {
    return Container(
      color: Colors.black.withOpacity(0.75),
      child: Center(
        child: SizedBox(
          height: 32,
          width: 32,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Theme.of(context).focusColor),
          ),
        ),
      ),
    );
  }
}
