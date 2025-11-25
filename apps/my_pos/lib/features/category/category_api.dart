import 'package:dio/dio.dart';
import 'package:my_pos/features/category/category_dto.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'category_api.g.dart';

class CategoryApi {
  final Dio _dio = Dio();

  Future<List<CategoryDto>> fetchCategories() async {
    final response = await _dio.get('https://api.escuelajs.co/api/v1/categories?limit=50');
    return (response.data as List).map((e) => CategoryDtoMapper.fromMap(e)).toList();
  }
}

@riverpod
CategoryApi categoryApi(Ref ref) {
  return CategoryApi();
}
