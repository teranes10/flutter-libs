import 'package:my_pos/features/category/category_api.dart';
import 'package:my_pos/models/category.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'categories.g.dart';

@riverpod
class Categories extends _$Categories {
  @override
  Future<Map<String, Category>> build() async {
    final api = ref.read(categoryApiProvider);
    final categories = await api.fetchCategories();

    return {
      for (var category in categories)
        category.id.toString(): Category(id: category.id.toString(), name: category.name, image: category.image),
    };
  }
}

@riverpod
class CurrentCategory extends _$CurrentCategory {
  @override
  String? build() {
    return null;
  }

  void selectCategory(String categoryId) {
    state = categoryId;
  }

  void clearSelection() {
    state = null;
  }
}
