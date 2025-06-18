import 'package:dart_mappable/dart_mappable.dart';

part 'meta_dto.mapper.dart';

@MappableClass()
class MetaDto with MetaDtoMappable {
  final String createdAt;
  final String updatedAt;
  final String barcode;
  final String qrCode;

  MetaDto({required this.createdAt, required this.updatedAt, required this.barcode, required this.qrCode});
}
