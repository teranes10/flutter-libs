// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'post_dto.dart';

class PostDtoMapper extends ClassMapperBase<PostDto> {
  PostDtoMapper._();

  static PostDtoMapper? _instance;
  static PostDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PostDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'PostDto';

  static int _$userId(PostDto v) => v.userId;
  static const Field<PostDto, int> _f$userId = Field('userId', _$userId);
  static int _$id(PostDto v) => v.id;
  static const Field<PostDto, int> _f$id = Field('id', _$id);
  static String _$title(PostDto v) => v.title;
  static const Field<PostDto, String> _f$title = Field('title', _$title);
  static String _$body(PostDto v) => v.body;
  static const Field<PostDto, String> _f$body = Field('body', _$body);

  @override
  final MappableFields<PostDto> fields = const {
    #userId: _f$userId,
    #id: _f$id,
    #title: _f$title,
    #body: _f$body,
  };

  static PostDto _instantiate(DecodingData data) {
    return PostDto(
        userId: data.dec(_f$userId),
        id: data.dec(_f$id),
        title: data.dec(_f$title),
        body: data.dec(_f$body));
  }

  @override
  final Function instantiate = _instantiate;

  static PostDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PostDto>(map);
  }

  static PostDto fromJson(String json) {
    return ensureInitialized().decodeJson<PostDto>(json);
  }
}

mixin PostDtoMappable {
  String toJson() {
    return PostDtoMapper.ensureInitialized()
        .encodeJson<PostDto>(this as PostDto);
  }

  Map<String, dynamic> toMap() {
    return PostDtoMapper.ensureInitialized()
        .encodeMap<PostDto>(this as PostDto);
  }

  PostDtoCopyWith<PostDto, PostDto, PostDto> get copyWith =>
      _PostDtoCopyWithImpl<PostDto, PostDto>(
          this as PostDto, $identity, $identity);
  @override
  String toString() {
    return PostDtoMapper.ensureInitialized().stringifyValue(this as PostDto);
  }

  @override
  bool operator ==(Object other) {
    return PostDtoMapper.ensureInitialized()
        .equalsValue(this as PostDto, other);
  }

  @override
  int get hashCode {
    return PostDtoMapper.ensureInitialized().hashValue(this as PostDto);
  }
}

extension PostDtoValueCopy<$R, $Out> on ObjectCopyWith<$R, PostDto, $Out> {
  PostDtoCopyWith<$R, PostDto, $Out> get $asPostDto =>
      $base.as((v, t, t2) => _PostDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PostDtoCopyWith<$R, $In extends PostDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({int? userId, int? id, String? title, String? body});
  PostDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PostDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PostDto, $Out>
    implements PostDtoCopyWith<$R, PostDto, $Out> {
  _PostDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PostDto> $mapper =
      PostDtoMapper.ensureInitialized();
  @override
  $R call({int? userId, int? id, String? title, String? body}) =>
      $apply(FieldCopyWithData({
        if (userId != null) #userId: userId,
        if (id != null) #id: id,
        if (title != null) #title: title,
        if (body != null) #body: body
      }));
  @override
  PostDto $make(CopyWithData data) => PostDto(
      userId: data.get(#userId, or: $value.userId),
      id: data.get(#id, or: $value.id),
      title: data.get(#title, or: $value.title),
      body: data.get(#body, or: $value.body));

  @override
  PostDtoCopyWith<$R2, PostDto, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _PostDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
