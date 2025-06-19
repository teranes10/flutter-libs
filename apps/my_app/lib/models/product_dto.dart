import 'package:dart_mappable/dart_mappable.dart';
import 'package:my_app/models/meta_dto.dart';

part 'product_dto.mapper.dart';

@MappableClass()
class ProductDto with ProductDtoMappable {
  final int id;
  final String title;
  final String description;
  final String category;
  final num price;
  final num discountPercentage;
  final num rating;
  final int stock;
  final String sku;
  final String? thumbnail;
  final List<String>? images;
  final MetaDto? meta;

  const ProductDto(
      {required this.id,
      required this.title,
      required this.description,
      required this.price,
      required this.discountPercentage,
      required this.rating,
      required this.stock,
      required this.category,
      required this.sku,
      this.thumbnail,
      this.images,
      this.meta});
}
