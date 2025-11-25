// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'category_dto.dart';

class CategoryDtoMapper extends ClassMapperBase<CategoryDto> {
  CategoryDtoMapper._();

  static CategoryDtoMapper? _instance;
  static CategoryDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CategoryDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'CategoryDto';

  static int _$id(CategoryDto v) => v.id;
  static const Field<CategoryDto, int> _f$id = Field('id', _$id);
  static String _$name(CategoryDto v) => v.name;
  static const Field<CategoryDto, String> _f$name = Field('name', _$name);
  static String _$slug(CategoryDto v) => v.slug;
  static const Field<CategoryDto, String> _f$slug = Field('slug', _$slug);
  static String _$image(CategoryDto v) => v.image;
  static const Field<CategoryDto, String> _f$image = Field('image', _$image);
  static DateTime _$creationAt(CategoryDto v) => v.creationAt;
  static const Field<CategoryDto, DateTime> _f$creationAt = Field(
    'creationAt',
    _$creationAt,
  );
  static DateTime _$updatedAt(CategoryDto v) => v.updatedAt;
  static const Field<CategoryDto, DateTime> _f$updatedAt = Field(
    'updatedAt',
    _$updatedAt,
  );

  @override
  final MappableFields<CategoryDto> fields = const {
    #id: _f$id,
    #name: _f$name,
    #slug: _f$slug,
    #image: _f$image,
    #creationAt: _f$creationAt,
    #updatedAt: _f$updatedAt,
  };

  static CategoryDto _instantiate(DecodingData data) {
    return CategoryDto(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      slug: data.dec(_f$slug),
      image: data.dec(_f$image),
      creationAt: data.dec(_f$creationAt),
      updatedAt: data.dec(_f$updatedAt),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CategoryDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CategoryDto>(map);
  }

  static CategoryDto fromJson(String json) {
    return ensureInitialized().decodeJson<CategoryDto>(json);
  }
}

mixin CategoryDtoMappable {
  String toJson() {
    return CategoryDtoMapper.ensureInitialized().encodeJson<CategoryDto>(
      this as CategoryDto,
    );
  }

  Map<String, dynamic> toMap() {
    return CategoryDtoMapper.ensureInitialized().encodeMap<CategoryDto>(
      this as CategoryDto,
    );
  }

  CategoryDtoCopyWith<CategoryDto, CategoryDto, CategoryDto> get copyWith =>
      _CategoryDtoCopyWithImpl<CategoryDto, CategoryDto>(
        this as CategoryDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return CategoryDtoMapper.ensureInitialized().stringifyValue(
      this as CategoryDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return CategoryDtoMapper.ensureInitialized().equalsValue(
      this as CategoryDto,
      other,
    );
  }

  @override
  int get hashCode {
    return CategoryDtoMapper.ensureInitialized().hashValue(this as CategoryDto);
  }
}

extension CategoryDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CategoryDto, $Out> {
  CategoryDtoCopyWith<$R, CategoryDto, $Out> get $asCategoryDto =>
      $base.as((v, t, t2) => _CategoryDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CategoryDtoCopyWith<$R, $In extends CategoryDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    int? id,
    String? name,
    String? slug,
    String? image,
    DateTime? creationAt,
    DateTime? updatedAt,
  });
  CategoryDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _CategoryDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CategoryDto, $Out>
    implements CategoryDtoCopyWith<$R, CategoryDto, $Out> {
  _CategoryDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CategoryDto> $mapper =
      CategoryDtoMapper.ensureInitialized();
  @override
  $R call({
    int? id,
    String? name,
    String? slug,
    String? image,
    DateTime? creationAt,
    DateTime? updatedAt,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (name != null) #name: name,
      if (slug != null) #slug: slug,
      if (image != null) #image: image,
      if (creationAt != null) #creationAt: creationAt,
      if (updatedAt != null) #updatedAt: updatedAt,
    }),
  );
  @override
  CategoryDto $make(CopyWithData data) => CategoryDto(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    slug: data.get(#slug, or: $value.slug),
    image: data.get(#image, or: $value.image),
    creationAt: data.get(#creationAt, or: $value.creationAt),
    updatedAt: data.get(#updatedAt, or: $value.updatedAt),
  );

  @override
  CategoryDtoCopyWith<$R2, CategoryDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CategoryDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

