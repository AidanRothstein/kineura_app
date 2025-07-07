// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_html/flutter_html.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:intl/intl.dart';
// import '../../providers/article_providers.dart';

// class ArticleDetailScreen extends ConsumerWidget {
//   final String articleId;

//   const ArticleDetailScreen({
//     super.key,
//     required this.articleId,
//   });

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final articleAsync = ref.watch(articleProvider(articleId));

//     return Scaffold(
//       body: articleAsync.when(
//         data: (article) {
//           if (article == null) {
//             return const Scaffold(
//               body: Center(
//                 child: Text('Article not found'),
//               ),
//             );
//           }

//           return CustomScrollView(
//             slivers: [
//               // App Bar with Image
//               SliverAppBar(
//                 expandedHeight: article.imageUrl != null ? 300 : 100,
//                 pinned: true,
//                 flexibleSpace: FlexibleSpaceBar(
//                   title: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                     decoration: BoxDecoration(
//                       color: Colors.black.withOpacity(0.7),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       article.title,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                   background: article.imageUrl != null
//                       ? CachedNetworkImage(
//                           imageUrl: article.imageUrl!,
//                           fit: BoxFit.cover,
//                           placeholder: (context, url) => Container(
//                             color: Colors.grey[300],
//                             child: const Center(
//                               child: CircularProgressIndicator(),
//                             ),
//                           ),
//                           errorWidget: (context, url, error) => Container(
//                             color: Colors.grey[300],
//                             child: const Icon(
//                               Icons.error,
//                               color: Colors.grey,
//                             ),
//                           ),
//                         )
//                       : Container(
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               begin: Alignment.topCenter,
//                               end: Alignment.bottomCenter,
//                               colors: [
//                                 Colors.blue[400]!,
//                                 Colors.blue[600]!,
//                               ],
//                             ),
//                           ),
//                         ),
//                 ),
//               ),
//               // Article Content
//               SliverToBoxAdapter(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Article Title (if no image)
//                       if (article.imageUrl == null) ...[
//                         Text(
//                           article.title,
//                           style: const TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                       ],
//                       // Meta Information
//                       Container(
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           color: Colors.grey[50],
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Column(
//                           children: [
//                             Row(
//                               children: [
//                                 CircleAvatar(
//                                   backgroundColor: Colors.blue[100],
//                                   child: Text(
//                                     article.author[0].toUpperCase(),
//                                     style: TextStyle(
//                                       color: Colors.blue[800],
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 12),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         article.author,
//                                         style: const TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 16,
//                                         ),
//                                       ),
//                                       Text(
//                                         DateFormat('MMMM dd, yyyy').format(article.createdAt),
//                                         style: TextStyle(
//                                           color: Colors.grey[600],
//                                           fontSize: 14,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 if (article.readTime > 0)
//                                   Container(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 12,
//                                       vertical: 6,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: Colors.blue[100],
//                                       borderRadius: BorderRadius.circular(20),
//                                     ),
//                                     child: Text(
//                                       '${article.readTime} min read',
//                                       style: TextStyle(
//                                         color: Colors.blue[800],
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ),
//                               ],
//                             ),
//                             // Tags
//                             if (article.tags.isNotEmpty) ...[
//                               const SizedBox(height: 12),
//                               Wrap(
//                                 spacing: 8,
//                                 runSpacing: 8,
//                                 children: article.tags.map((tag) {
//                                   return Container(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 12,
//                                       vertical: 6,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: Colors.grey[200],
//                                       borderRadius: BorderRadius.circular(20),
//                                     ),
//                                     child: Text(
//                                       tag,
//                                       style: const TextStyle(
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     ),
//                                   );
//                                 }).toList(),
//                               ),
//                             ],
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 24),
//                       // Article Content
//                       Html(
//                         data: article.content,
//                         style: {
//                           "body": Style(
//                             fontSize: FontSize(16),
//                             lineHeight: const LineHeight(1.6),
//                             margin: Margins.zero,
//                             padding: HtmlPaddings.zero,
//                           ),
//                           "h1": Style(
//                             fontSize: FontSize(24),
//                             fontWeight: FontWeight.bold,
//                             margin: Margins.only(top: 20, bottom: 10),
//                           ),
//                           "h2": Style(
//                             fontSize: FontSize(20),
//                             fontWeight: FontWeight.bold,
//                             margin: Margins.only(top: 16, bottom: 8),
//                           ),
//                           "h3": Style(
//                             fontSize: FontSize(18),
//                             fontWeight: FontWeight.bold,
//                             margin: Margins.only(top: 12, bottom: 6),
//                           ),
//                           "p": Style(
//                             margin: Margins.only(bottom: 12),
//                           ),
//                           "blockquote": Style(
//                             backgroundColor: Colors.grey[100],
//                             border: Border(
//                               left: BorderSide(
//                                 color: Colors.blue[400]!,
//                                 width: 4,
//                               ),
//                             ),
//                             padding: HtmlPaddings.all(16),
//                             margin: Margins.only(bottom: 16),
//                           ),
//                           "code": Style(
//                             backgroundColor: Colors.grey[200],
//                             padding: HtmlPaddings.symmetric(horizontal: 4, vertical: 2),
//                             fontFamily: 'monospace',
//                           ),
//                           "pre": Style(
//                             backgroundColor: Colors.grey[100],
//                             padding: HtmlPaddings.all(16),
//                             margin: Margins.only(bottom: 16),
//                             fontFamily: 'monospace',
//                           ),
//                         },
//                       ),
//                       const SizedBox(height: 32),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//         loading: () => const Scaffold(
//           body: Center(
//             child: CircularProgressIndicator(),
//           ),
//         ),
//         error: (error, stack) => Scaffold(
//           appBar: AppBar(),
//           body: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(
//                   Icons.error_outline,
//                   size: 64,
//                   color: Colors.red,
//                 ),
//                 const SizedBox(height: 16),
//                 const Text(
//                   'Error loading article',
//                   style: TextStyle(fontSize: 18),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   error.toString(),
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: Colors.grey[600],
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () {
//                     ref.invalidate(articleProvider(articleId));
//                   },
//                   child: const Text('Retry'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
