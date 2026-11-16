import 'package:flutter/material.dart';
import 'package:my_app/clients/mock_cursor_client.dart';
import 'package:te_widgets/te_widgets.dart';

/// Design tokens of a [User]'s status string, so tables never switch on it inline.
extension UserStatusX on User {
  bool get isActive => status == 'Active';

  Color statusColor(BuildContext context) => switch (status) {
        'Active' => context.theme.success,
        'Inactive' => context.theme.danger,
        _ => context.theme.warning,
      };
}
