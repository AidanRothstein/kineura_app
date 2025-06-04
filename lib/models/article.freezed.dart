// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'article.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Article _$ArticleFromJson(Map<String, dynamic> json) {
  return _Article.fromJson(json);
}

/// @nodoc
mixin _$Article {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  String get author => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get summary => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  int get readTime => throw _privateConstructorUsedError;
  bool get isPublished => throw _privateConstructorUsedError;

  /// Serializes this Article to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Article
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ArticleCopyWith<Article> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ArticleCopyWith<$Res> {
  factory $ArticleCopyWith(Article value, $Res Function(Article) then) =
      _$ArticleCopyWithImpl<$Res, Article>;
  @useResult
  $Res call(
      {String id,
      String title,
      String content,
      String author,
      DateTime createdAt,
      DateTime updatedAt,
      String? imageUrl,
      String? summary,
      List<String> tags,
      int readTime,
      bool isPublished});
}

/// @nodoc
class _$ArticleCopyWithImpl<$Res, $Val extends Article>
    implements $ArticleCopyWith<$Res> {
  _$ArticleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Article
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? content = null,
    Object? author = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? imageUrl = freezed,
    Object? summary = freezed,
    Object? tags = null,
    Object? readTime = null,
    Object? isPublished = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      author: null == author
          ? _value.author
          : author // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      summary: freezed == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      readTime: null == readTime
          ? _value.readTime
          : readTime // ignore: cast_nullable_to_non_nullable
              as int,
      isPublished: null == isPublished
          ? _value.isPublished
          : isPublished // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ArticleImplCopyWith<$Res> implements $ArticleCopyWith<$Res> {
  factory _$$ArticleImplCopyWith(
          _$ArticleImpl value, $Res Function(_$ArticleImpl) then) =
      __$$ArticleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String content,
      String author,
      DateTime createdAt,
      DateTime updatedAt,
      String? imageUrl,
      String? summary,
      List<String> tags,
      int readTime,
      bool isPublished});
}

/// @nodoc
class __$$ArticleImplCopyWithImpl<$Res>
    extends _$ArticleCopyWithImpl<$Res, _$ArticleImpl>
    implements _$$ArticleImplCopyWith<$Res> {
  __$$ArticleImplCopyWithImpl(
      _$ArticleImpl _value, $Res Function(_$ArticleImpl) _then)
      : super(_value, _then);

  /// Create a copy of Article
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? content = null,
    Object? author = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? imageUrl = freezed,
    Object? summary = freezed,
    Object? tags = null,
    Object? readTime = null,
    Object? isPublished = null,
  }) {
    return _then(_$ArticleImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      author: null == author
          ? _value.author
          : author // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      summary: freezed == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      readTime: null == readTime
          ? _value.readTime
          : readTime // ignore: cast_nullable_to_non_nullable
              as int,
      isPublished: null == isPublished
          ? _value.isPublished
          : isPublished // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ArticleImpl implements _Article {
  const _$ArticleImpl(
      {required this.id,
      required this.title,
      required this.content,
      required this.author,
      required this.createdAt,
      required this.updatedAt,
      this.imageUrl,
      this.summary,
      final List<String> tags = const [],
      this.readTime = 0,
      this.isPublished = false})
      : _tags = tags;

  factory _$ArticleImpl.fromJson(Map<String, dynamic> json) =>
      _$$ArticleImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String content;
  @override
  final String author;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final String? imageUrl;
  @override
  final String? summary;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @JsonKey()
  final int readTime;
  @override
  @JsonKey()
  final bool isPublished;

  @override
  String toString() {
    return 'Article(id: $id, title: $title, content: $content, author: $author, createdAt: $createdAt, updatedAt: $updatedAt, imageUrl: $imageUrl, summary: $summary, tags: $tags, readTime: $readTime, isPublished: $isPublished)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ArticleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.readTime, readTime) ||
                other.readTime == readTime) &&
            (identical(other.isPublished, isPublished) ||
                other.isPublished == isPublished));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      content,
      author,
      createdAt,
      updatedAt,
      imageUrl,
      summary,
      const DeepCollectionEquality().hash(_tags),
      readTime,
      isPublished);

  /// Create a copy of Article
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ArticleImplCopyWith<_$ArticleImpl> get copyWith =>
      __$$ArticleImplCopyWithImpl<_$ArticleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ArticleImplToJson(
      this,
    );
  }
}

abstract class _Article implements Article {
  const factory _Article(
      {required final String id,
      required final String title,
      required final String content,
      required final String author,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final String? imageUrl,
      final String? summary,
      final List<String> tags,
      final int readTime,
      final bool isPublished}) = _$ArticleImpl;

  factory _Article.fromJson(Map<String, dynamic> json) = _$ArticleImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get content;
  @override
  String get author;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  String? get imageUrl;
  @override
  String? get summary;
  @override
  List<String> get tags;
  @override
  int get readTime;
  @override
  bool get isPublished;

  /// Create a copy of Article
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ArticleImplCopyWith<_$ArticleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ArticleUpload _$ArticleUploadFromJson(Map<String, dynamic> json) {
  return _ArticleUpload.fromJson(json);
}

/// @nodoc
mixin _$ArticleUpload {
  String get title => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  String get author => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get summary => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  int get readTime => throw _privateConstructorUsedError;
  bool get isPublished => throw _privateConstructorUsedError;

  /// Serializes this ArticleUpload to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ArticleUpload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ArticleUploadCopyWith<ArticleUpload> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ArticleUploadCopyWith<$Res> {
  factory $ArticleUploadCopyWith(
          ArticleUpload value, $Res Function(ArticleUpload) then) =
      _$ArticleUploadCopyWithImpl<$Res, ArticleUpload>;
  @useResult
  $Res call(
      {String title,
      String content,
      String author,
      String? imageUrl,
      String? summary,
      List<String> tags,
      int readTime,
      bool isPublished});
}

/// @nodoc
class _$ArticleUploadCopyWithImpl<$Res, $Val extends ArticleUpload>
    implements $ArticleUploadCopyWith<$Res> {
  _$ArticleUploadCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ArticleUpload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? content = null,
    Object? author = null,
    Object? imageUrl = freezed,
    Object? summary = freezed,
    Object? tags = null,
    Object? readTime = null,
    Object? isPublished = null,
  }) {
    return _then(_value.copyWith(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      author: null == author
          ? _value.author
          : author // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      summary: freezed == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      readTime: null == readTime
          ? _value.readTime
          : readTime // ignore: cast_nullable_to_non_nullable
              as int,
      isPublished: null == isPublished
          ? _value.isPublished
          : isPublished // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ArticleUploadImplCopyWith<$Res>
    implements $ArticleUploadCopyWith<$Res> {
  factory _$$ArticleUploadImplCopyWith(
          _$ArticleUploadImpl value, $Res Function(_$ArticleUploadImpl) then) =
      __$$ArticleUploadImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String title,
      String content,
      String author,
      String? imageUrl,
      String? summary,
      List<String> tags,
      int readTime,
      bool isPublished});
}

/// @nodoc
class __$$ArticleUploadImplCopyWithImpl<$Res>
    extends _$ArticleUploadCopyWithImpl<$Res, _$ArticleUploadImpl>
    implements _$$ArticleUploadImplCopyWith<$Res> {
  __$$ArticleUploadImplCopyWithImpl(
      _$ArticleUploadImpl _value, $Res Function(_$ArticleUploadImpl) _then)
      : super(_value, _then);

  /// Create a copy of ArticleUpload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? content = null,
    Object? author = null,
    Object? imageUrl = freezed,
    Object? summary = freezed,
    Object? tags = null,
    Object? readTime = null,
    Object? isPublished = null,
  }) {
    return _then(_$ArticleUploadImpl(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      author: null == author
          ? _value.author
          : author // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      summary: freezed == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      readTime: null == readTime
          ? _value.readTime
          : readTime // ignore: cast_nullable_to_non_nullable
              as int,
      isPublished: null == isPublished
          ? _value.isPublished
          : isPublished // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ArticleUploadImpl implements _ArticleUpload {
  const _$ArticleUploadImpl(
      {required this.title,
      required this.content,
      required this.author,
      this.imageUrl,
      this.summary,
      final List<String> tags = const [],
      this.readTime = 0,
      this.isPublished = true})
      : _tags = tags;

  factory _$ArticleUploadImpl.fromJson(Map<String, dynamic> json) =>
      _$$ArticleUploadImplFromJson(json);

  @override
  final String title;
  @override
  final String content;
  @override
  final String author;
  @override
  final String? imageUrl;
  @override
  final String? summary;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @JsonKey()
  final int readTime;
  @override
  @JsonKey()
  final bool isPublished;

  @override
  String toString() {
    return 'ArticleUpload(title: $title, content: $content, author: $author, imageUrl: $imageUrl, summary: $summary, tags: $tags, readTime: $readTime, isPublished: $isPublished)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ArticleUploadImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.readTime, readTime) ||
                other.readTime == readTime) &&
            (identical(other.isPublished, isPublished) ||
                other.isPublished == isPublished));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      title,
      content,
      author,
      imageUrl,
      summary,
      const DeepCollectionEquality().hash(_tags),
      readTime,
      isPublished);

  /// Create a copy of ArticleUpload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ArticleUploadImplCopyWith<_$ArticleUploadImpl> get copyWith =>
      __$$ArticleUploadImplCopyWithImpl<_$ArticleUploadImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ArticleUploadImplToJson(
      this,
    );
  }
}

abstract class _ArticleUpload implements ArticleUpload {
  const factory _ArticleUpload(
      {required final String title,
      required final String content,
      required final String author,
      final String? imageUrl,
      final String? summary,
      final List<String> tags,
      final int readTime,
      final bool isPublished}) = _$ArticleUploadImpl;

  factory _ArticleUpload.fromJson(Map<String, dynamic> json) =
      _$ArticleUploadImpl.fromJson;

  @override
  String get title;
  @override
  String get content;
  @override
  String get author;
  @override
  String? get imageUrl;
  @override
  String? get summary;
  @override
  List<String> get tags;
  @override
  int get readTime;
  @override
  bool get isPublished;

  /// Create a copy of ArticleUpload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ArticleUploadImplCopyWith<_$ArticleUploadImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
