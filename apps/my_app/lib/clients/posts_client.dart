import 'package:dio/dio.dart';
import 'package:my_app/models/post_dto.dart';
import 'package:te_widgets/mixins/pagination/pagination_config.dart';

class PostsClient {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com'));

  Future<(List<PostDto>, int)> fetchPosts({int start = 0, int limit = 10}) async {
    final response = await _dio.get(
      '/posts',
      queryParameters: {
        '_start': start,
        '_limit': limit,
      },
      options: Options(headers: {
        'Accept': 'application/json',
      }),
    );

    final total = int.tryParse(response.headers['x-total-count']?.first ?? '0') ?? 0;
    final items = (response.data as List).map((x) => PostDtoMapper.fromMap(x)).toList();
    return (items, total);
  }

  void loadMore(TLoadOptions<PostDto> o) async {
    final (items, total) = await fetchPosts(start: o.offset, limit: o.itemsPerPage);
    o.callback(items, total);
  }
}
