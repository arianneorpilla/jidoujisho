import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:subtitle_wrapper_package/data/models/subtitle.dart';
import 'package:subtitle_wrapper_package/data/models/subtitles.dart';

import 'package:http/http.dart' as http;
import 'package:subtitle_wrapper_package/subtitle_controller.dart';

abstract class SubtitleRepository {
  Future<dynamic> getSubtitles();
}

class SubtitleDataRepository extends SubtitleRepository {
  final SubtitleController subtitleController;

  SubtitleDataRepository({@required this.subtitleController});

  // Gets the subtitle content type
  SubtitleDecoder requestContentType(Map<String, dynamic> headers) {
    // Extracts the subtitle content type from the headers
    var encoding = _encodingForHeaders(headers);
    if (encoding == latin1) {
      // If encoding type is latin1 return this type
      return SubtitleDecoder.latin1;
    } else {
      // If encoding type is utf8 return this type
      return SubtitleDecoder.utf8;
    }
  }

  // Extract the encoding type from the headers
  Encoding _encodingForHeaders(Map<String, String> headers) =>
      encodingForCharset(
        _contentTypeForHeaders(headers).parameters['charset'],
      );

  // Gets the content type from the headers and returns it as a media type
  MediaType _contentTypeForHeaders(Map<String, String> headers) {
    var _contentType = headers['content-type'];
    if (_hasSemiColonEnding(_contentType)) {
      _contentType = _fixSemiColonEnding(_contentType);
    }
    return MediaType.parse(_contentType);
  }

  // Check if the string is ending with a semicolon.
  bool _hasSemiColonEnding(String _string) {
    return _string.substring(_string.length - 1, _string.length) == ';';
  }

  // Remove ending semicolon from string.
  String _fixSemiColonEnding(String _string) {
    return _string.substring(0, _string.length - 1);
  }

  // Gets the encoding type for the charset string with a fall back to utf8
  Encoding encodingForCharset(String charset, [Encoding fallback = utf8]) {
    // If the charset is empty we use the encoding fallback
    if (charset == null) return fallback;
    // If the charset is not empty we will return the encoding type for this charset
    return Encoding.getByName(charset) ?? fallback;
  }

  // Handles the subtitle loading, parsing.
  @override
  Future<dynamic> getSubtitles() async {
    var subtitlesContent = subtitleController.subtitlesContent;
    var subtitleUrl = subtitleController.subtitleUrl;

    // If the subtitle content parameter is empty we will load the subtitle from the specified url
    if (subtitlesContent == null && subtitleUrl != null) {
      // Lets load the subtitle content from the url
      subtitlesContent = await loadRemoteSubtitleContent(
        subtitleUrl,
      );
    }
    // Tries parsing the subtitle data
    // Lets try to parse the subtitle content with the specified subtitle type
    return getSubtitlesData(
      subtitlesContent,
      subtitleController.subtitleType,
    );
  }

  // Loads the remote subtitle content
  Future<String> loadRemoteSubtitleContent(subtitleUrl) async {
    var subtitleDecoder = subtitleController.subtitleDecoder;
    String subtitlesContent;
    // Try loading the subtitle content with http.get
    var response = await http.get(subtitleUrl);
    // Lets check if the request was succesfull
    if (response.statusCode == 200) {
      // If the subtitle decoder type is utf8 lets decode it with utf8
      if (subtitleDecoder == SubtitleDecoder.utf8) {
        subtitlesContent = utf8.decode(
          response.bodyBytes,
          allowMalformed: true,
        );
      }
      // If the subtitle decoder type is latin1 lets decode it with latin1
      else if (subtitleDecoder == SubtitleDecoder.latin1) {
        subtitlesContent = latin1.decode(
          response.bodyBytes,
          allowInvalid: true,
        );
      }
      // The  subtitle decoder was not defined so we will extract it from the response headers send from the server
      else {
        var subtitleServerDecoder = requestContentType(
          response.headers,
        );
        // If the subtitle decoder type is utf8 lets decode it with utf8
        if (subtitleServerDecoder == SubtitleDecoder.utf8) {
          subtitlesContent = utf8.decode(
            response.bodyBytes,
            allowMalformed: true,
          );
        }
        // If the subtitle decoder type is latin1 lets decode it with latin1
        else if (subtitleServerDecoder == SubtitleDecoder.latin1) {
          subtitlesContent = latin1.decode(
            response.bodyBytes,
            allowInvalid: true,
          );
        }
      }
    }
    // Return the subtitle content
    return subtitlesContent;
  }

  Subtitles getSubtitlesData(
      String subtitlesContent, SubtitleType subtitleType) {
    RegExp regExp;
    if (subtitleType == SubtitleType.webvtt) {
      regExp = RegExp(
        r'((\d{2}):(\d{2}):(\d{2})\.(\d+)) +--> +((\d{2}):(\d{2}):(\d{2})\.(\d{3})).*[\r\n]+\s*((?:(?!\r?\n\r?).)*(\r\n|\r|\n)(?:.*))',
        caseSensitive: false,
        multiLine: true,
      );
    } else if (subtitleType == SubtitleType.srt) {
      regExp = RegExp(
        r'((\d{2}):(\d{2}):(\d{2})\,(\d+)) +--> +((\d{2}):(\d{2}):(\d{2})\,(\d{3})).*[\r\n]+\s*((?:(?!\r?\n\r?).)*(\r\n|\r|\n)(?:.*))',
        caseSensitive: false,
        multiLine: true,
      );
    } else {
      throw ('Incorrect subtitle type');
    }

    var matches = regExp.allMatches(subtitlesContent).toList();
    var subtitleList = [];

    matches.forEach((RegExpMatch regExpMatch) {
      var startTimeHours = int.parse(regExpMatch.group(2));
      var startTimeMinutes = int.parse(regExpMatch.group(3));
      var startTimeSeconds = int.parse(regExpMatch.group(4));
      var startTimeMilliseconds = int.parse(regExpMatch.group(5));

      var endTimeHours = int.parse(regExpMatch.group(7));
      var endTimeMinutes = int.parse(regExpMatch.group(8));
      var endTimeSeconds = int.parse(regExpMatch.group(9));
      var endTimeMilliseconds = int.parse(regExpMatch.group(10));
      var text = removeAllHtmlTags(regExpMatch.group(11));

      var startTime = Duration(
          hours: startTimeHours,
          minutes: startTimeMinutes,
          seconds: startTimeSeconds,
          milliseconds: startTimeMilliseconds);
      var endTime = Duration(
          hours: endTimeHours,
          minutes: endTimeMinutes,
          seconds: endTimeSeconds,
          milliseconds: endTimeMilliseconds);

      subtitleList.add(
          Subtitle(startTime: startTime, endTime: endTime, text: text.trim()));
    });

    var subtitles = Subtitles(subtitles: subtitleList);
    return subtitles;
  }

  String removeAllHtmlTags(String htmlText) {
    var exp = RegExp(r'(<[^>]*>)', multiLine: true, caseSensitive: true);
    var newHtmlText = htmlText;
    exp.allMatches(htmlText).toList().forEach((RegExpMatch regExpMathc) {
      if (regExpMathc.group(0) == '<br>') {
        newHtmlText = newHtmlText.replaceAll(regExpMathc.group(0), '\n');
      } else {
        newHtmlText = newHtmlText.replaceAll(regExpMathc.group(0), '');
      }
    });
    return newHtmlText;
  }
}
