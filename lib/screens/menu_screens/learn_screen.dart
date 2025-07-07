// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:intl/intl.dart';
// import '../../models/article.dart';
// import '../../providers/article_providers.dart';
// import 'package:amplify_flutter/amplify_flutter.dart';
// import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
// import 'article_detail_screen.dart';
// import 'article_upload_screen.dart';
// import 'dart:convert';

// Future<bool> isUserEditor() async {
//   try {
//     final session = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
//     if (session.isSignedIn) {
//       final accessToken = session.userPoolTokensResult.value.accessToken.raw;
//       final parts = accessToken.split('.');
//       if (parts.length != 3) return false;
//       final payloadMap = jsonDecode(
//         utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))
//       ) as Map<String, dynamic>;
//       final groups = payloadMap['cognito:groups'] as List<dynamic>? ?? [];
//       return groups.contains('Editors');
//     }
//   } catch (e) {
//     safePrint("Error checking user group: $e");
//   }
//   return false;
// }

// class LearnScreen extends ConsumerStatefulWidget {
//   const LearnScreen({super.key});

//   @override
//   ConsumerState<LearnScreen> createState() => _LearnScreenState();
// }

// class _LearnScreenState extends ConsumerState<LearnScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   late Future<bool> _canUpload;

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   void initState() {
//     super.initState();
//     _canUpload = isUserEditor();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final articlesAsync = ref.watch(filteredArticlesProvider);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Learn',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 24,
//           ),
//         ),
//         elevation: 0,
//         actions: [
//           FutureBuilder<bool>(
//             future: _canUpload,
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return Container();
//               }
//               if (snapshot.data == true) {
//                 return IconButton(
//                   icon: const Icon(Icons.add),
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const ArticleUploadScreen(),
//                       ),
//                     );
//                   },
//                 );
//               }
//               return Container();
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Search Bar
//           Container(
//             padding: const EdgeInsets.all(16.0),
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 hintText: 'Search articles...',
//                 prefixIcon: const Icon(Icons.search),
//                 suffixIcon: _searchController.text.isNotEmpty
//                     ? IconButton(
//                         icon: const Icon(Icons.clear),
//                         onPressed: () {
//                           _searchController.clear();
//                           ref.read(searchQueryProvider.notifier).state = '';
//                         },
//                       )
//                     : null,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide.none,
//                 ),
//                 filled: true,
//                 fillColor: Colors.grey[100],
//               ),
//               onChanged: (value) {
//                 ref.read(searchQueryProvider.notifier).state = value;
//               },
//             ),
//           ),
//           // Articles List
//           Expanded(
//             child: RefreshIndicator(
//               onRefresh: () async {
//                 ref.invalidate(filteredArticlesProvider);
//               },
//               child: articlesAsync.when(
//                 data: (articles) {
//                   if (articles.isEmpty) {
//                     return const Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             Icons.article_outlined,
//                             size: 64,
//                             color: Colors.grey,
//                           ),
//                           SizedBox(height: 16),
//                           Text(
//                             'No articles found',
//                             style: TextStyle(
//                               fontSize: 18,
//                               color: Colors.grey,
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }

//                   return ListView.builder(
//                     padding: const EdgeInsets.all(16),
//                     itemCount: articles.length,
//                     itemBuilder: (context, index) {
//                       final article = articles[index];
//                       return ArticleCard(
//                         article: article,
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => ArticleDetailScreen(
//                                 articleId: article.id,
//                               ),
//                             ),
//                           );
//                         },
//                       );
//                     },
//                   );
//                 },
//                 loading: () => const Center(
//                   child: CircularProgressIndicator(),
//                 ),
//                 error: (error, stack) => Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Icon(
//                         Icons.error_outline,
//                         size: 64,
//                         color: Colors.red,
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         'Error loading articles',
//                         style: TextStyle(
//                           fontSize: 18,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         error.toString(),
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           color: Colors.grey[500],
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       ElevatedButton(
//                         onPressed: () {
//                           ref.invalidate(filteredArticlesProvider);
//                         },
//                         child: const Text('Retry'),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class ArticleCard extends StatelessWidget {
//   final Article article;
//   final VoidCallback onTap;

//   const ArticleCard({
//     super.key,
//     required this.article,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Article Image
//             if (article.imageUrl != null)
//               ClipRRect(
//                 borderRadius: const BorderRadius.vertical(
//                   top: Radius.circular(12),
//                 ),
//                 child: CachedNetworkImage(
//                   imageUrl: article.imageUrl!,
//                   height: 200,
//                   width: double.infinity,
//                   fit: BoxFit.cover,
//                   placeholder: (context, url) => Container(
//                     height: 200,
//                     color: Colors.grey[300],
//                     child: const Center(
//                       child: CircularProgressIndicator(),
//                     ),
//                   ),
//                   errorWidget: (context, url, error) => Container(
//                     height: 200,
//                     color: Colors.grey[300],
//                     child: const Icon(
//                       Icons.error,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ),
//               ),
//             // Article Content
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Title
//                   Text(
//                     article.title,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 8),
//                   // Summary
//                   if (article.summary != null)
//                     Text(
//                       article.summary!,
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey[600],
//                       ),
//                       maxLines: 3,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   const SizedBox(height: 12),
//                   // Meta information
//                   Row(
//                     children: [
//                       const Icon(
//                         Icons.person,
//                         size: 16,
//                         color: Colors.grey,
//                       ),
//                       const SizedBox(width: 4),
//                       Flexible(
//                         fit: FlexFit.tight,
//                         child: Text(
//                           article.author,
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey[500],
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       const Icon(
//                         Icons.access_time,
//                         size: 16,
//                         color: Colors.grey,
//                       ),
//                       const SizedBox(width: 4),
//                       Flexible(
//                         fit: FlexFit.tight,
//                         child: Text(
//                           DateFormat('MMM dd, yyyy').format(article.createdAt),
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey[500],
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                       if (article.readTime > 0) ...[
//                         const SizedBox(width: 16),
//                         const Icon(
//                           Icons.schedule,
//                           size: 16,
//                           color: Colors.grey,
//                         ),
//                         const SizedBox(width: 4),
//                         Flexible(
//                           fit: FlexFit.tight,
//                           child: Text(
//                             '${article.readTime} min read',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey[500],
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                   // Tags
//                   if (article.tags.isNotEmpty) ...[
//                     const SizedBox(height: 8),
//                     Wrap(
//                       spacing: 8,
//                       children: article.tags.take(3).map((tag) {
//                         return Chip(
//                           label: Text(
//                             tag,
//                             style: const TextStyle(fontSize: 10),
//                           ),
//                           backgroundColor: Colors.blue[50],
//                           labelPadding: const EdgeInsets.symmetric(horizontal: 4),
//                           visualDensity: VisualDensity.compact,
//                         );
//                       }).toList(),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
