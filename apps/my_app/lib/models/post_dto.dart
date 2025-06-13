import 'package:dart_mappable/dart_mappable.dart';

part 'post_dto.mapper.dart';

@MappableClass()
class PostDto with PostDtoMappable {
  final int userId;
  final int id;
  final String title;
  final String body;

  PostDto({required this.userId, required this.id, required this.title, required this.body});
}
