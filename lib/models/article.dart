import 'package:freezed_annotation/freezed_annotation.dart';

part 'article.freezed.dart';
part 'article.g.dart';

@freezed
class Article with _$Article {
  const factory Article({
    required String id,
    required String title,
    required String content,
    required String author,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? imageUrl,
    String? summary,
    @Default([]) List<String> tags,
    @Default(0) int readTime,
    @Default(false) bool isPublished,
  }) = _Article;

  factory Article.fromJson(Map<String, dynamic> json) => _$ArticleFromJson(json);
}

@freezed
class ArticleUpload with _$ArticleUpload {
  const factory ArticleUpload({
    required String title,
    required String content,
    required String author,
    String? imageUrl,
    String? summary,
    @Default([]) List<String> tags,
    @Default(0) int readTime,
    @Default(true) bool isPublished,
  }) = _ArticleUpload;

  factory ArticleUpload.fromJson(Map<String, dynamic> json) => _$ArticleUploadFromJson(json);
}
