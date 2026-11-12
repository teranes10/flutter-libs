import 'dart:convert';
import 'package:http/http.dart' as http;

/// Minimal JSON-over-HTTP helper. Throws on non-2xx (like Dio did), returns the decoded body.
Future<dynamic> httpJson(http.Client client, String url, {Map<String, String>? query, Map<String, String>? headers, Object? body}) async {
  var uri = Uri.parse(url);
  if (query != null && query.isNotEmpty) uri = uri.replace(queryParameters: {...uri.queryParameters, ...query});
  final response = body == null
      ? await client.get(uri, headers: headers)
      : await client.post(uri, headers: {'Content-Type': 'application/json', ...?headers}, body: jsonEncode(body));
  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw http.ClientException('HTTP ${response.statusCode}', uri);
  }
  return response.body.isEmpty ? null : jsonDecode(utf8.decode(response.bodyBytes));
}
