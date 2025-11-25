import 'package:dart_mappable/dart_mappable.dart';

part 'category_dto.mapper.dart';

@MappableClass()
class CategoryDto with CategoryDtoMappable {
  final int id;
  final String name;
  final String slug;
  final String image;
  final DateTime creationAt;
  final DateTime updatedAt;

  CategoryDto({
    required this.id,
    required this.name,
    required this.slug,
    required this.image,
    required this.creationAt,
    required this.updatedAt,
  });
}
