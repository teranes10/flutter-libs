import 'package:dart_mappable/dart_mappable.dart';
import 'package:my_pos/features/category/category_dto.dart';

part 'product_dto.mapper.dart';

@MappableClass()
class ProductDto with ProductDtoMappable {
  final int id;
  final String title;
  final String slug;
  final double price;
  final String? description;
  final CategoryDto category;
  final List<String> images;
  final DateTime creationAt;
  final DateTime updatedAt;

  ProductDto({
    required this.id,
    required this.title,
    required this.slug,
    required this.price,
    this.description,
    required this.category,
    required this.images,
    required this.creationAt,
    required this.updatedAt,
  });
}
