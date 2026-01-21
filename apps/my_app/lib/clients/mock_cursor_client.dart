import 'dart:async';

/// Mock user model for cursor pagination demo
class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String status;
  final DateTime createdAt;

  User({required this.id, required this.name, required this.email, required this.role, required this.status, required this.createdAt});
}

/// Mock response for cursor-based pagination
class CursorPaginatedResponse {
  final List<User> items;
  final String? nextCursor;
  final String? previousCursor;
  final bool hasNext;
  final bool hasPrevious;

  CursorPaginatedResponse({required this.items, this.nextCursor, this.previousCursor, required this.hasNext, required this.hasPrevious});
}

/// Mock client that simulates cursor-based pagination
/// In a real app, this would call an actual API
class MockCursorApiClient {
  // Simulated database of 100 users
  static final List<User> _allUsers = List.generate(
    100,
    (index) => User(
      id: index + 1,
      name: 'User ${index + 1}',
      email: 'user${index + 1}@example.com',
      role: ['Admin', 'Editor', 'Viewer'][(index % 3)],
      status: ['Active', 'Inactive', 'Pending'][(index % 3)],
      createdAt: DateTime.now().subtract(Duration(days: index)),
    ),
  );

  /// Simulates fetching users with cursor pagination
  ///
  /// In cursor pagination, we use the cursor (last item ID) to determine
  /// where to start fetching the next page
  Future<CursorPaginatedResponse> getUsers({String? cursor, int limit = 10, String? search}) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500));

    // Filter by search if provided
    var filteredUsers = _allUsers;
    if (search != null && search.isNotEmpty) {
      filteredUsers = _allUsers.where((user) {
        return user.name.toLowerCase().contains(search.toLowerCase()) ||
            user.email.toLowerCase().contains(search.toLowerCase()) ||
            user.role.toLowerCase().contains(search.toLowerCase());
      }).toList();
    }

    // Determine starting index from cursor
    int startIndex = 0;
    if (cursor != null) {
      // Cursor is the ID of the last item from previous page
      final cursorId = int.tryParse(cursor);
      if (cursorId != null) {
        startIndex = filteredUsers.indexWhere((user) => user.id == cursorId);
        if (startIndex != -1) {
          startIndex++; // Start after the cursor item
        } else {
          startIndex = 0;
        }
      }
    }

    // Get the page of items
    final endIndex = (startIndex + limit).clamp(0, filteredUsers.length);
    final pageItems = filteredUsers.sublist(startIndex, endIndex);

    // Determine cursors for next/previous pages
    String? nextCursor;
    String? previousCursor;
    bool hasNext = endIndex < filteredUsers.length;
    bool hasPrevious = startIndex > 0;

    if (hasNext && pageItems.isNotEmpty) {
      nextCursor = pageItems.last.id.toString();
    }

    if (hasPrevious && startIndex > 0) {
      // For previous, we'd need to go back
      final prevStartIndex = (startIndex - limit).clamp(0, startIndex);
      if (prevStartIndex < filteredUsers.length) {
        previousCursor = filteredUsers[prevStartIndex].id.toString();
      }
    }

    return CursorPaginatedResponse(
      items: pageItems,
      nextCursor: nextCursor,
      previousCursor: previousCursor,
      hasNext: hasNext,
      hasPrevious: hasPrevious,
    );
  }
}
