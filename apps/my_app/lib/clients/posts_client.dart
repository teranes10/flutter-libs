import 'package:dio/dio.dart';
import 'package:my_app/models/post_dto.dart';
import 'package:te_widgets/te_widgets.dart';

class PostsClient {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com'));

  Future<(List<PostDto>, int)> fetchPosts({int start = 0, int limit = 10, String? query}) async {
    final response = await _dio.get(
      '/posts',
      queryParameters: {
        '_start': start,
        '_limit': limit,
        'title_like': query,
      },
      options: Options(headers: {
        'Accept': 'application/json',
      }),
    );

    final total = int.tryParse(response.headers['x-total-count']?.first ?? '0') ?? 0;
    final items = (response.data as List).map((x) => PostDtoMapper.fromMap(x)).toList();
    return (items, total);
  }

  Future<TLoadResult<PostDto>> loadMore(TLoadOptions<PostDto> o) async {
    final (items, total) = await fetchPosts(start: o.offset, limit: o.itemsPerPage);
    return TLoadResult(items, total);
  }
}
