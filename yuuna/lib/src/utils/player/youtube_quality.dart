import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

/// Extension for the [VideoQuality] class.
extension VideoQualityIcon on VideoQuality {
  /// Get the icon for this quality.
  IconData? get icon {
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
}
