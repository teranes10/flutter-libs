// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'meta_dto.dart';

class MetaDtoMapper extends ClassMapperBase<MetaDto> {
  MetaDtoMapper._();

  static MetaDtoMapper? _instance;
  static MetaDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MetaDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'MetaDto';

  static String _$createdAt(MetaDto v) => v.createdAt;
  static const Field<MetaDto, String> _f$createdAt =
      Field('createdAt', _$createdAt);
  static String _$updatedAt(MetaDto v) => v.updatedAt;
  static const Field<MetaDto, String> _f$updatedAt =
      Field('updatedAt', _$updatedAt);
  static String _$barcode(MetaDto v) => v.barcode;
  static const Field<MetaDto, String> _f$barcode = Field('barcode', _$barcode);
  static String _$qrCode(MetaDto v) => v.qrCode;
  static const Field<MetaDto, String> _f$qrCode = Field('qrCode', _$qrCode);

  @override
  final MappableFields<MetaDto> fields = const {
    #createdAt: _f$createdAt,
    #updatedAt: _f$updatedAt,
    #barcode: _f$barcode,
    #qrCode: _f$qrCode,
  };

  static MetaDto _instantiate(DecodingData data) {
    return MetaDto(
        createdAt: data.dec(_f$createdAt),
        updatedAt: data.dec(_f$updatedAt),
        barcode: data.dec(_f$barcode),
        qrCode: data.dec(_f$qrCode));
  }

  @override
  final Function instantiate = _instantiate;

  static MetaDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MetaDto>(map);
  }

  static MetaDto fromJson(String json) {
    return ensureInitialized().decodeJson<MetaDto>(json);
  }
}

mixin MetaDtoMappable {
  String toJson() {
    return MetaDtoMapper.ensureInitialized()
        .encodeJson<MetaDto>(this as MetaDto);
  }

  Map<String, dynamic> toMap() {
    return MetaDtoMapper.ensureInitialized()
        .encodeMap<MetaDto>(this as MetaDto);
  }

  MetaDtoCopyWith<MetaDto, MetaDto, MetaDto> get copyWith =>
      _MetaDtoCopyWithImpl<MetaDto, MetaDto>(
          this as MetaDto, $identity, $identity);
  @override
  String toString() {
    return MetaDtoMapper.ensureInitialized().stringifyValue(this as MetaDto);
  }

  @override
  bool operator ==(Object other) {
    return MetaDtoMapper.ensureInitialized()
        .equalsValue(this as MetaDto, other);
  }

  @override
  int get hashCode {
    return MetaDtoMapper.ensureInitialized().hashValue(this as MetaDto);
  }
}

extension MetaDtoValueCopy<$R, $Out> on ObjectCopyWith<$R, MetaDto, $Out> {
  MetaDtoCopyWith<$R, MetaDto, $Out> get $asMetaDto =>
      $base.as((v, t, t2) => _MetaDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class MetaDtoCopyWith<$R, $In extends MetaDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call(
      {String? createdAt, String? updatedAt, String? barcode, String? qrCode});
  MetaDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _MetaDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MetaDto, $Out>
    implements MetaDtoCopyWith<$R, MetaDto, $Out> {
  _MetaDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MetaDto> $mapper =
      MetaDtoMapper.ensureInitialized();
  @override
  $R call(
          {String? createdAt,
          String? updatedAt,
          String? barcode,
          String? qrCode}) =>
      $apply(FieldCopyWithData({
        if (createdAt != null) #createdAt: createdAt,
        if (updatedAt != null) #updatedAt: updatedAt,
        if (barcode != null) #barcode: barcode,
        if (qrCode != null) #qrCode: qrCode
      }));
  @override
  MetaDto $make(CopyWithData data) => MetaDto(
      createdAt: data.get(#createdAt, or: $value.createdAt),
      updatedAt: data.get(#updatedAt, or: $value.updatedAt),
      barcode: data.get(#barcode, or: $value.barcode),
      qrCode: data.get(#qrCode, or: $value.qrCode));

  @override
  MetaDtoCopyWith<$R2, MetaDto, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _MetaDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
