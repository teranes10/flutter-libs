import 'dart:convert';

/// Represents parsed error details.
class TError {
  /// The main error message title.
  final String? message;

  /// Map of field keys to lists of error messages.
  final Map<String, List<String>>? errors;

  const TError({
    this.message,
    this.errors,
  });

  /// Returns true if there is a main error message or field error map.
  bool get hasError => (message != null && message!.isNotEmpty) || (errors != null && errors!.isNotEmpty);

  /// Parses error response from various formats (Map, JSON String, Exception, etc.)
  factory TError.from(dynamic error) {
    if (error == null) return const TError();
    if (error is TError) return error;

    String? mainMessage;
    Map<String, List<String>>? errorsMap;

    dynamic data;

    if (error is Map) {
      data = error;
    } else if (error is String) {
      final trimmed = error.trim();
      if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
        try {
          final decoded = jsonDecode(trimmed);
          if (decoded is Map) {
            data = decoded;
          } else {
            mainMessage = error;
          }
        } catch (_) {
          mainMessage = error;
        }
      } else {
        mainMessage = error;
      }
    } else {
      try {
        dynamic respData;
        try {
          respData = (error as dynamic).response?.data;
        } catch (_) {}
        respData ??= (error as dynamic).data;

        if (respData != null) {
          if (respData is Map) {
            data = respData;
          } else if (respData is String) {
            final trimmed = respData.trim();
            if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
              try {
                final decoded = jsonDecode(trimmed);
                if (decoded is Map) data = decoded;
              } catch (_) {}
            }
          }
        }
      } catch (_) {}

      if (data == null) {
        try {
          final msg = (error as dynamic).message;
          if (msg != null && msg.toString().isNotEmpty) {
            mainMessage = msg.toString();
          }
        } catch (_) {}
        mainMessage ??= error.toString();
      }
    }

    if (data is Map) {
      if (data['title'] != null && data['title'].toString().isNotEmpty) {
        mainMessage = data['title'].toString();
      } else if (data['message'] != null && data['message'].toString().isNotEmpty) {
        mainMessage = data['message'].toString();
      } else if (data['errorMessage'] != null && data['errorMessage'].toString().isNotEmpty) {
        mainMessage = data['errorMessage'].toString();
      } else if (data['detail'] != null && data['detail'].toString().isNotEmpty) {
        mainMessage = data['detail'].toString();
      } else if (data['error'] != null && data['error'] is String) {
        mainMessage = data['error'].toString();
      }

      if (data['errors'] != null && data['errors'] is Map) {
        final rawMap = data['errors'] as Map;
        final map = <String, List<String>>{};
        rawMap.forEach((key, value) {
          final keyStr = key.toString();
          if (value is List) {
            map[keyStr] = value.map((e) => e.toString()).toList();
          } else if (value != null) {
            map[keyStr] = [value.toString()];
          }
        });
        if (map.isNotEmpty) {
          errorsMap = map;
        }
      }
    }

    return TError(
      message: mainMessage,
      errors: errorsMap,
    );
  }
}
