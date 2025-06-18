// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'product_dto.dart';

class ProductDtoMapper extends ClassMapperBase<ProductDto> {
  ProductDtoMapper._();

  static ProductDtoMapper? _instance;
  static ProductDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ProductDtoMapper._());
      MetaDtoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ProductDto';

  static int _$id(ProductDto v) => v.id;
  static const Field<ProductDto, int> _f$id = Field('id', _$id);
  static String _$title(ProductDto v) => v.title;
  static const Field<ProductDto, String> _f$title = Field('title', _$title);
  static String _$description(ProductDto v) => v.description;
  static const Field<ProductDto, String> _f$description =
      Field('description', _$description);
  static num _$price(ProductDto v) => v.price;
  static const Field<ProductDto, num> _f$price = Field('price', _$price);
  static num _$discountPercentage(ProductDto v) => v.discountPercentage;
  static const Field<ProductDto, num> _f$discountPercentage =
      Field('discountPercentage', _$discountPercentage);
  static num _$rating(ProductDto v) => v.rating;
  static const Field<ProductDto, num> _f$rating = Field('rating', _$rating);
  static int _$stock(ProductDto v) => v.stock;
  static const Field<ProductDto, int> _f$stock = Field('stock', _$stock);
  static String _$category(ProductDto v) => v.category;
  static const Field<ProductDto, String> _f$category =
      Field('category', _$category);
  static String _$sku(ProductDto v) => v.sku;
  static const Field<ProductDto, String> _f$sku = Field('sku', _$sku);
  static String _$thumbnail(ProductDto v) => v.thumbnail;
  static const Field<ProductDto, String> _f$thumbnail =
      Field('thumbnail', _$thumbnail);
  static List<String> _$images(ProductDto v) => v.images;
  static const Field<ProductDto, List<String>> _f$images =
      Field('images', _$images);
  static MetaDto _$meta(ProductDto v) => v.meta;
  static const Field<ProductDto, MetaDto> _f$meta = Field('meta', _$meta);

  @override
  final MappableFields<ProductDto> fields = const {
    #id: _f$id,
    #title: _f$title,
    #description: _f$description,
    #price: _f$price,
    #discountPercentage: _f$discountPercentage,
    #rating: _f$rating,
    #stock: _f$stock,
    #category: _f$category,
    #sku: _f$sku,
    #thumbnail: _f$thumbnail,
    #images: _f$images,
    #meta: _f$meta,
  };

  static ProductDto _instantiate(DecodingData data) {
    return ProductDto(
        id: data.dec(_f$id),
        title: data.dec(_f$title),
        description: data.dec(_f$description),
        price: data.dec(_f$price),
        discountPercentage: data.dec(_f$discountPercentage),
        rating: data.dec(_f$rating),
        stock: data.dec(_f$stock),
        category: data.dec(_f$category),
        sku: data.dec(_f$sku),
        thumbnail: data.dec(_f$thumbnail),
        images: data.dec(_f$images),
        meta: data.dec(_f$meta));
  }

  @override
  final Function instantiate = _instantiate;

  static ProductDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ProductDto>(map);
  }

  static ProductDto fromJson(String json) {
    return ensureInitialized().decodeJson<ProductDto>(json);
  }
}

mixin ProductDtoMappable {
  String toJson() {
    return ProductDtoMapper.ensureInitialized()
        .encodeJson<ProductDto>(this as ProductDto);
  }

  Map<String, dynamic> toMap() {
    return ProductDtoMapper.ensureInitialized()
        .encodeMap<ProductDto>(this as ProductDto);
  }

  ProductDtoCopyWith<ProductDto, ProductDto, ProductDto> get copyWith =>
      _ProductDtoCopyWithImpl<ProductDto, ProductDto>(
          this as ProductDto, $identity, $identity);
  @override
  String toString() {
    return ProductDtoMapper.ensureInitialized()
        .stringifyValue(this as ProductDto);
  }

  @override
  bool operator ==(Object other) {
    return ProductDtoMapper.ensureInitialized()
        .equalsValue(this as ProductDto, other);
  }

  @override
  int get hashCode {
    return ProductDtoMapper.ensureInitialized().hashValue(this as ProductDto);
  }
}

extension ProductDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ProductDto, $Out> {
  ProductDtoCopyWith<$R, ProductDto, $Out> get $asProductDto =>
      $base.as((v, t, t2) => _ProductDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ProductDtoCopyWith<$R, $In extends ProductDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get images;
  MetaDtoCopyWith<$R, MetaDto, MetaDto> get meta;
  $R call(
      {int? id,
      String? title,
      String? description,
      num? price,
      num? discountPercentage,
      num? rating,
      int? stock,
      String? category,
      String? sku,
      String? thumbnail,
      List<String>? images,
      MetaDto? meta});
  ProductDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ProductDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ProductDto, $Out>
    implements ProductDtoCopyWith<$R, ProductDto, $Out> {
  _ProductDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ProductDto> $mapper =
      ProductDtoMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get images =>
      ListCopyWith($value.images, (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(images: v));
  @override
  MetaDtoCopyWith<$R, MetaDto, MetaDto> get meta =>
      $value.meta.copyWith.$chain((v) => call(meta: v));
  @override
  $R call(
          {int? id,
          String? title,
          String? description,
          num? price,
          num? discountPercentage,
          num? rating,
          int? stock,
          String? category,
          String? sku,
          String? thumbnail,
          List<String>? images,
          MetaDto? meta}) =>
      $apply(FieldCopyWithData({
        if (id != null) #id: id,
        if (title != null) #title: title,
        if (description != null) #description: description,
        if (price != null) #price: price,
        if (discountPercentage != null) #discountPercentage: discountPercentage,
        if (rating != null) #rating: rating,
        if (stock != null) #stock: stock,
        if (category != null) #category: category,
        if (sku != null) #sku: sku,
        if (thumbnail != null) #thumbnail: thumbnail,
        if (images != null) #images: images,
        if (meta != null) #meta: meta
      }));
  @override
  ProductDto $make(CopyWithData data) => ProductDto(
      id: data.get(#id, or: $value.id),
      title: data.get(#title, or: $value.title),
      description: data.get(#description, or: $value.description),
      price: data.get(#price, or: $value.price),
      discountPercentage:
          data.get(#discountPercentage, or: $value.discountPercentage),
      rating: data.get(#rating, or: $value.rating),
      stock: data.get(#stock, or: $value.stock),
      category: data.get(#category, or: $value.category),
      sku: data.get(#sku, or: $value.sku),
      thumbnail: data.get(#thumbnail, or: $value.thumbnail),
      images: data.get(#images, or: $value.images),
      meta: data.get(#meta, or: $value.meta));

  @override
  ProductDtoCopyWith<$R2, ProductDto, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _ProductDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
