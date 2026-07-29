import 'package:flutter/material.dart';
import 'package:te_widgets/extensions/build_context_x.dart';
import 'package:te_widgets/widgets/error/error.dart';

/// A banner displaying error messages
class TErrorBuilder extends StatelessWidget {
  final TError error;
  final Color? color;
  final bool showIcon;

  const TErrorBuilder({
    super.key,
    required this.error,
    this.color,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!error.hasError) return const SizedBox.shrink();

    final rColor = color ?? context.theme.danger;
    final hasMainMessage = error.message != null && error.message!.isNotEmpty;
    final hasFieldErrors = error.errors != null && error.errors!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showIcon) Icon(Icons.error_outline, color: rColor, size: 20),
            if (showIcon) const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasMainMessage)
                    Text(
                      error.message!,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: rColor),
                    ),
                  if (hasMainMessage && hasFieldErrors) const SizedBox(height: 5),
                  if (hasFieldErrors)
                    ...error.errors!.entries.map(
                      (entry) {
                        final key = entry.key;
                        final messages = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                key,
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: rColor),
                              ),
                              const SizedBox(height: 2),
                              ...messages.map(
                                (msg) => Padding(
                                  padding: const EdgeInsets.only(left: 12, top: 2),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '• ',
                                        style: TextStyle(color: rColor, fontWeight: FontWeight.w400, fontSize: 13),
                                      ),
                                      Expanded(
                                        child: Text(
                                          msg,
                                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w300, color: rColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
