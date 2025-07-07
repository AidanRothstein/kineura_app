// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../models/article.dart';
// import '../services/article_service.dart';

// // Article service provider
// final articleServiceProvider = Provider<ArticleService>((ref) {
//   return ArticleService();
// });

// // Articles list provider
// final articlesProvider = FutureProvider<List<Article>>((ref) async {
//   final service = ref.read(articleServiceProvider);
//   return service.fetchArticles();
// });

// // Search query provider
// final searchQueryProvider = StateProvider<String>((ref) => '');

// // Filtered articles provider
// final filteredArticlesProvider = FutureProvider<List<Article>>((ref) async {
//   final query = ref.watch(searchQueryProvider);
//   final service = ref.read(articleServiceProvider);
  
//   if (query.isEmpty) {
//     return service.fetchArticles();
//   } else {
//     return service.searchArticles(query);
//   }
// });

// // Single article provider
// final articleProvider = FutureProvider.family<Article?, String>((ref, id) async {
//   final service = ref.read(articleServiceProvider);
//   return service.getArticle(id);
// });

// // Article upload state provider
// final articleUploadProvider = StateNotifierProvider<ArticleUploadNotifier, ArticleUploadState>((ref) {
//   final service = ref.read(articleServiceProvider);
//   return ArticleUploadNotifier(service);
// });

// // Article upload state
// class ArticleUploadState {
//   final bool isLoading;
//   final String? error;
//   final Article? uploadedArticle;

//   ArticleUploadState({
//     this.isLoading = false,
//     this.error,
//     this.uploadedArticle,
//   });

//   ArticleUploadState copyWith({
//     bool? isLoading,
//     String? error,
//     Article? uploadedArticle,
//   }) {
//     return ArticleUploadState(
//       isLoading: isLoading ?? this.isLoading,
//       error: error,
//       uploadedArticle: uploadedArticle ?? this.uploadedArticle,
//     );
//   }
// }

// // Article upload notifier
// class ArticleUploadNotifier extends StateNotifier<ArticleUploadState> {
//   final ArticleService _service;

//   ArticleUploadNotifier(this._service) : super(ArticleUploadState());

//   Future<void> uploadArticle(ArticleUpload articleUpload) async {
//     state = state.copyWith(isLoading: true, error: null);
    
//     try {
//       final article = await _service.createArticle(articleUpload);
//       if (article != null) {
//         state = state.copyWith(
//           isLoading: false,
//           uploadedArticle: article,
//         );
//       } else {
//         state = state.copyWith(
//           isLoading: false,
//           error: 'Failed to upload article',
//         );
//       }
//     } catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         error: e.toString(),
//       );
//     }
//   }

//   void reset() {
//     state = ArticleUploadState();
//   }
// }
