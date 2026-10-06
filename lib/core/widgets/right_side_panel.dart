import 'package:flutter/material.dart';

Future<T?> showRightSidePanel<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  String barrierLabel = 'Close',
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Align(
        alignment: Alignment.centerRight,
        child: Material(
          elevation: 16,
          child: Container(
            width: MediaQuery.of(context).size.width / 2, // Half the screen width
            height: double.infinity,
            color: Theme.of(context).scaffoldBackgroundColor,
            child: builder(context),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: child,
      );
    },
  );
}
