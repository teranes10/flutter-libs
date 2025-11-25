// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
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
      CategoryDtoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ProductDto';

  static int _$id(ProductDto v) => v.id;
  static const Field<ProductDto, int> _f$id = Field('id', _$id);
  static String _$title(ProductDto v) => v.title;
  static const Field<ProductDto, String> _f$title = Field('title', _$title);
  static String _$slug(ProductDto v) => v.slug;
  static const Field<ProductDto, String> _f$slug = Field('slug', _$slug);
  static double _$price(ProductDto v) => v.price;
  static const Field<ProductDto, double> _f$price = Field('price', _$price);
  static String? _$description(ProductDto v) => v.description;
  static const Field<ProductDto, String> _f$description = Field(
    'description',
    _$description,
    opt: true,
  );
  static CategoryDto _$category(ProductDto v) => v.category;
  static const Field<ProductDto, CategoryDto> _f$category = Field(
    'category',
    _$category,
  );
  static List<String> _$images(ProductDto v) => v.images;
  static const Field<ProductDto, List<String>> _f$images = Field(
    'images',
    _$images,
  );
  static DateTime _$creationAt(ProductDto v) => v.creationAt;
  static const Field<ProductDto, DateTime> _f$creationAt = Field(
    'creationAt',
    _$creationAt,
  );
  static DateTime _$updatedAt(ProductDto v) => v.updatedAt;
  static const Field<ProductDto, DateTime> _f$updatedAt = Field(
    'updatedAt',
    _$updatedAt,
  );

  @override
  final MappableFields<ProductDto> fields = const {
    #id: _f$id,
    #title: _f$title,
    #slug: _f$slug,
    #price: _f$price,
    #description: _f$description,
    #category: _f$category,
    #images: _f$images,
    #creationAt: _f$creationAt,
    #updatedAt: _f$updatedAt,
  };

  static ProductDto _instantiate(DecodingData data) {
    return ProductDto(
      id: data.dec(_f$id),
      title: data.dec(_f$title),
      slug: data.dec(_f$slug),
      price: data.dec(_f$price),
      description: data.dec(_f$description),
      category: data.dec(_f$category),
      images: data.dec(_f$images),
      creationAt: data.dec(_f$creationAt),
      updatedAt: data.dec(_f$updatedAt),
    );
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
    return ProductDtoMapper.ensureInitialized().encodeJson<ProductDto>(
      this as ProductDto,
    );
  }

  Map<String, dynamic> toMap() {
    return ProductDtoMapper.ensureInitialized().encodeMap<ProductDto>(
      this as ProductDto,
    );
  }

  ProductDtoCopyWith<ProductDto, ProductDto, ProductDto> get copyWith =>
      _ProductDtoCopyWithImpl<ProductDto, ProductDto>(
        this as ProductDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ProductDtoMapper.ensureInitialized().stringifyValue(
      this as ProductDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return ProductDtoMapper.ensureInitialized().equalsValue(
      this as ProductDto,
      other,
    );
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
  CategoryDtoCopyWith<$R, CategoryDto, CategoryDto> get category;
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get images;
  $R call({
    int? id,
    String? title,
    String? slug,
    double? price,
    String? description,
    CategoryDto? category,
    List<String>? images,
    DateTime? creationAt,
    DateTime? updatedAt,
  });
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
  CategoryDtoCopyWith<$R, CategoryDto, CategoryDto> get category =>
      $value.category.copyWith.$chain((v) => call(category: v));
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get images =>
      ListCopyWith(
        $value.images,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(images: v),
      );
  @override
  $R call({
    int? id,
    String? title,
    String? slug,
    double? price,
    Object? description = $none,
    CategoryDto? category,
    List<String>? images,
    DateTime? creationAt,
    DateTime? updatedAt,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (title != null) #title: title,
      if (slug != null) #slug: slug,
      if (price != null) #price: price,
      if (description != $none) #description: description,
      if (category != null) #category: category,
      if (images != null) #images: images,
      if (creationAt != null) #creationAt: creationAt,
      if (updatedAt != null) #updatedAt: updatedAt,
    }),
  );
  @override
  ProductDto $make(CopyWithData data) => ProductDto(
    id: data.get(#id, or: $value.id),
    title: data.get(#title, or: $value.title),
    slug: data.get(#slug, or: $value.slug),
    price: data.get(#price, or: $value.price),
    description: data.get(#description, or: $value.description),
    category: data.get(#category, or: $value.category),
    images: data.get(#images, or: $value.images),
    creationAt: data.get(#creationAt, or: $value.creationAt),
    updatedAt: data.get(#updatedAt, or: $value.updatedAt),
  );

  @override
  ProductDtoCopyWith<$R2, ProductDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ProductDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

