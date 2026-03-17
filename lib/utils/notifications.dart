import 'package:flutter/material.dart';
import '../widgets/bottom_popup_card.dart';

Future<void> showBottomPopup(BuildContext context,
    {required String message, bool success = true, Duration? duration}) async {
  final d = duration ?? const Duration(seconds: 3);
  final route = showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: false,
    builder: (_) => SafeArea(
      child: BottomPopupCard(message: message, success: success),
    ),
  );

  Future.delayed(d, () {
    // ignore: unawaited_futures
    Navigator.of(context).maybePop();
  });

  return route;
}
