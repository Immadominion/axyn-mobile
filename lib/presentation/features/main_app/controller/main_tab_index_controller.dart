import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Exposes the notifier that tracks which main tab is currently active.
final mainTabIndexProvider = NotifierProvider<MainTabIndexController, int>(
  MainTabIndexController.new,
);

/// Maintains the selected index for the bottom navigation scaffold.
class MainTabIndexController extends Notifier<int> {
  @override
  int build() => 0;

  /// Updates the selected tab when the new index falls within the valid range.
  void setIndex(int index) {
    if (index >= 0 && index < 4) {
      state = index;
    }
  }
}
