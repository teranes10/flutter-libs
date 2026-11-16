import 'package:flutter/material.dart';
import 'package:my_app/clients/mock_cursor_client.dart';
import 'package:my_app/models/user_status.dart';
import 'package:te_widgets/te_widgets.dart';

/// Demo page showcasing cursor-based pagination with TDataTable
class CursorPaginationPage extends StatelessWidget {
  const CursorPaginationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TDataTable<User, int>(
      headers: [
        TTableHeader<User, int>.map('ID', (user) => user.id),
        TTableHeader<User, int>.map('Name', (user) => user.name),
        TTableHeader<User, int>.map('Email', (user) => user.email),
        TTableHeader<User, int>.map('Role', (user) => user.role),
        TTableHeader<User, int>.chip('Status', (user) => user.status, color: (user) => user.statusColor(context)),
      ],
      itemKey: (user) => user.id,
      onLoad: (options) async {
        final client = MockCursorApiClient();
        final response = await client.getUsers(cursor: options.cursor, limit: options.itemsPerPage, search: options.search);

        return TLoadResult(response.items, 0, nextCursor: response.nextCursor, hasNextPage: response.hasNext);
      },
    );
  }
}
