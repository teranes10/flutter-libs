import 'package:dio/dio.dart';
import 'package:my_pos/features/product/product_dto.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'product_api.g.dart';

class ProductApi {
  final Dio _dio = Dio();

  Future<List<ProductDto>> fetchProducts() async {
    final response = await _dio.get('https://api.escuelajs.co/api/v1/products?limit=250');
    return (response.data as List).map((e) => ProductDtoMapper.fromMap(e)).toList();
  }
}

@riverpod
ProductApi productApi(Ref ref) {
  return ProductApi();
}
