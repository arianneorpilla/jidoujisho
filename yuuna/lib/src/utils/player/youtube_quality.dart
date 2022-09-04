import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

/// Extension for the [VideoQuality] class.
extension VideoQualityIcon on VideoQuality {
  /// Get the icon for this quality.
  IconData get icon {
    switch (this) {
      case VideoQuality.unknown:
        return Icons.help;
      case VideoQuality.low144:
      case VideoQuality.low240:
      case VideoQuality.medium360:
      case VideoQuality.medium480:
      case VideoQuality.high720:
        return Icons.sd;
      case VideoQuality.high1080:
      case VideoQuality.high1440:
        return Icons.hd;
      case VideoQuality.high2160:
      case VideoQuality.high2880:
      case VideoQuality.high3072:
      case VideoQuality.high4320:
        return Icons.four_k;
    }
  }

  /// Get the icon for this quality.
  String get label {
    switch (this) {
      case VideoQuality.unknown:
        return 'Unknown';
      case VideoQuality.low144:
        return '144p';
      case VideoQuality.low240:
        return '240p';
      case VideoQuality.medium360:
        return '360p';
      case VideoQuality.medium480:
        return '480p';
      case VideoQuality.high720:
        return '720p';
      case VideoQuality.high1080:
        return '1080p';
      case VideoQuality.high1440:
        return '1440p';
      case VideoQuality.high2160:
        return '2160p';
      case VideoQuality.high2880:
        return '2880p';
      case VideoQuality.high3072:
        return '3072p';
      case VideoQuality.high4320:
        return '4320p';
    }
  }
}
