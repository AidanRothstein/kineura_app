import 'dart:convert';
import 'dart:io';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/article.dart';

class ArticleService {
  static const String _cacheKey = 'cached_articles';
  static const String _lastFetchKey = 'last_fetch_time';
  static const Duration _cacheExpiry = Duration(hours: 1);

  // GraphQL mutations and queries
  static const String _createArticleMutation = '''
    mutation CreateArticle(\$input: CreateArticleInput!) {
      createArticle(input: \$input) {
        id
        title
        content
        author
        createdAt
        updatedAt
        imageUrl
        summary
        tags
        readTime
        isPublished
      }
    }
  ''';

  static const String _listArticlesQuery = '''
    query ListArticles(\$limit: Int, \$nextToken: String) {
      listArticles(limit: \$limit, nextToken: \$nextToken) {
        items {
          id
          title
          content
          author
          createdAt
          updatedAt
          imageUrl
          summary
          tags
          readTime
          isPublished
        }
        nextToken
      }
    }
  ''';

  static const String _getArticleQuery = '''
    query GetArticle(\$id: ID!) {
      getArticle(id: \$id) {
        id
        title
        content
        author
        createdAt
        updatedAt
        imageUrl
        summary
        tags
        readTime
        isPublished
      }
    }
  ''';

  // Fetch articles from API
  Future<List<Article>> fetchArticles({bool forceRefresh = false}) async {
    try {
      // Check cache first
      if (!forceRefresh) {
        final cachedArticles = await _getCachedArticles();
        if (cachedArticles.isNotEmpty) {
          return cachedArticles;
        }
      }

      final request = GraphQLRequest<String>(
        document: _listArticlesQuery,
        variables: {
          'limit': 50,
        },
      );

      final response = await Amplify.API.query(request: request).response;

      if (response.hasErrors) {
        throw Exception('GraphQL errors: ${response.errors}');
      }

      final data = json.decode(response.data!);
      final items = data['listArticles']['items'] as List;
      
      final articles = items
          .map((item) => Article.fromJson(item))
          .where((article) => article.isPublished)
          .toList();

      // Cache the results
      await _cacheArticles(articles);
      
      return articles;
    } catch (e) {
      safePrint('Error fetching articles: $e');
      // Return cached articles as fallback
      return await _getCachedArticles();
    }
  }

  // Get single article
  Future<Article?> getArticle(String id) async {
    try {
      final request = GraphQLRequest<String>(
        document: _getArticleQuery,
        variables: {'id': id},
      );

      final response = await Amplify.API.query(request: request).response;

      if (response.hasErrors) {
        throw Exception('GraphQL errors: ${response.errors}');
      }

      final data = json.decode(response.data!);
      final articleData = data['getArticle'];
      
      if (articleData != null) {
        return Article.fromJson(articleData);
      }
      
      return null;
    } catch (e) {
      safePrint('Error fetching article: $e');
      return null;
    }
  }

  // Upload image to S3
  Future<String?> uploadImage(File imageFile) async {
  try {
    final fileName = '${const Uuid().v4()}.${imageFile.path.split('.').last}';
    final key = 'articles/images/$fileName';

    final uploadTask = Amplify.Storage.uploadFile(
      localFile: AWSFile.fromPath(imageFile.path),
      key: key,
      options: const StorageUploadFileOptions(
        accessLevel: StorageAccessLevel.guest,
      ),
    );

    final result = await uploadTask.result;

    // FIX: Await .result and then access .url
    final urlResult = await Amplify.Storage.getUrl(
      key: result.uploadedItem.key,
      options: const StorageGetUrlOptions(
        accessLevel: StorageAccessLevel.guest,
      ),
    ).result;

    return urlResult.url.toString();
  } catch (e) {
    safePrint('Error uploading image: $e');
    return null;
  }
}


  // Create new article
  Future<Article?> createArticle(ArticleUpload articleUpload) async {
    try {
      final input = {
        'id': const Uuid().v4(),
        'title': articleUpload.title,
        'content': articleUpload.content,
        'author': articleUpload.author,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
        'imageUrl': articleUpload.imageUrl,
        'summary': articleUpload.summary,
        'tags': articleUpload.tags,
        'readTime': articleUpload.readTime,
        'isPublished': articleUpload.isPublished,
      };

      final request = GraphQLRequest<String>(
        document: _createArticleMutation,
        variables: {'input': input},
      );

      final response = await Amplify.API.mutate(request: request).response;

      if (response.hasErrors) {
        throw Exception('GraphQL errors: ${response.errors}');
      }

      final data = json.decode(response.data!);
      final articleData = data['createArticle'];
      
      if (articleData != null) {
        final article = Article.fromJson(articleData);
        // Invalidate cache
        await _clearCache();
        return article;
      }
      
      return null;
    } catch (e) {
      safePrint('Error creating article: $e');
      return null;
    }
  }

  // Search articles
  Future<List<Article>> searchArticles(String query) async {
    final articles = await fetchArticles();
    return articles.where((article) {
      return article.title.toLowerCase().contains(query.toLowerCase()) ||
             article.content.toLowerCase().contains(query.toLowerCase()) ||
             article.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()));
    }).toList();
  }

  // Cache management
  Future<void> _cacheArticles(List<Article> articles) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final articlesJson = articles.map((a) => a.toJson()).toList();
      await prefs.setString(_cacheKey, json.encode(articlesJson));
      await prefs.setInt(_lastFetchKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      safePrint('Error caching articles: $e');
    }
  }

  Future<List<Article>> _getCachedArticles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastFetch = prefs.getInt(_lastFetchKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      // Check if cache is expired
      if (now - lastFetch > _cacheExpiry.inMilliseconds) {
        return [];
      }

      final cachedData = prefs.getString(_cacheKey);
      if (cachedData != null) {
        final List<dynamic> articlesJson = json.decode(cachedData);
        return articlesJson.map((json) => Article.fromJson(json)).toList();
      }
    } catch (e) {
      safePrint('Error reading cached articles: $e');
    }
    return [];
  }

  Future<void> _clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_lastFetchKey);
    } catch (e) {
      safePrint('Error clearing cache: $e');
    }
  }
}
