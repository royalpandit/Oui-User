import 'package:flutter/material.dart';
import '../widgets/bottom_popup_card.dart';

/// Shows a non-modal popup at the bottom of the screen that auto-dismisses.
/// Uses an Overlay instead of a modal route to avoid interfering with navigation.
void showBottomPopup(BuildContext context,
    {required String message, bool success = true, Duration? duration}) {
  final d = duration ?? const Duration(seconds: 3);
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        child: BottomPopupCard(message: message, success: success),
      ),
    ),
  );

  Overlay.of(context).insert(entry);

  Future.delayed(d, () {
    if (entry.mounted) {
      entry.remove();
    }
  });
}
