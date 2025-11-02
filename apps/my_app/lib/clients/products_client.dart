import 'package:dio/dio.dart';
import 'package:my_app/models/product_dto.dart';
import 'package:te_widgets/te_widgets.dart';

class ProductsClient {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://dummyjson.com'));

  Future<(List<ProductDto>, int)> fetchProducts({int offset = 0, int limit = 10, String search = ''}) async {
    final res = await _dio.get('/products/search', queryParameters: {'q': search, 'skip': offset, 'limit': limit});
    final items = (res.data['products'] as List).map((json) => ProductDtoMapper.fromMap(json)).toList();
    final total = (res.data['total']) as int;

    return (items, total);
  }

  Future<TLoadResult<ProductDto>> loadMore(TLoadOptions<ProductDto> o) async {
    final (items, total) = await fetchProducts(offset: o.offset, limit: o.itemsPerPage, search: o.search ?? '');
    return TLoadResult(items, total);
  }
}
