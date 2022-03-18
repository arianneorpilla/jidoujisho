import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A global [Provider] for app-wide configuration and state management.
final creatorProvider = ChangeNotifierProvider<CreatorModel>((ref) {
  return CreatorModel();
});

/// A scoped model for parameters that affect the card creator.
/// RiverPod is used for global state management across multiple layers,
/// and is useful for showing the creator and sharing code across the
/// entire application.
class CreatorModel with ChangeNotifier {}
