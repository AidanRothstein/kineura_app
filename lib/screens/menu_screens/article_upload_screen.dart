import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../../models/article.dart';
import '../../providers/article_providers.dart';

class ArticleUploadScreen extends ConsumerStatefulWidget {
  const ArticleUploadScreen({super.key});

  @override
  ConsumerState<ArticleUploadScreen> createState() => _ArticleUploadScreenState();
}

class _ArticleUploadScreenState extends ConsumerState<ArticleUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _summaryController = TextEditingController();
  final _tagsController = TextEditingController();
  final _readTimeController = TextEditingController();
  
  File? _selectedImage;
  String? _uploadedImageUrl;
  bool _isPublished = true;
  String _currentUserName = '';

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    try {
      final user = await Amplify.Auth.getCurrentUser();
      setState(() {
        _currentUserName = user.username;
      });
    } catch (e) {
      setState(() {
        _currentUserName = 'Unknown Author';
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _summaryController.dispose();
    _tagsController.dispose();
    _readTimeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    try {
      final service = ref.read(articleServiceProvider);
      final imageUrl = await service.uploadImage(_selectedImage!);
      
      if (imageUrl != null) {
        setState(() {
          _uploadedImageUrl = imageUrl;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload image')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
    }
  }

  Future<void> _submitArticle() async {
    if (!_formKey.currentState!.validate()) return;

    // Upload image if selected but not uploaded
    if (_selectedImage != null && _uploadedImageUrl == null) {
      await _uploadImage();
    }

    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    final readTime = int.tryParse(_readTimeController.text) ?? 0;

    final articleUpload = ArticleUpload(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      author: _currentUserName,
      imageUrl: _uploadedImageUrl,
      summary: _summaryController.text.trim().isEmpty 
          ? null 
          : _summaryController.text.trim(),
      tags: tags,
      readTime: readTime,
      isPublished: _isPublished,
    );

    await ref.read(articleUploadProvider.notifier).uploadArticle(articleUpload);
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(articleUploadProvider);

    // Listen to upload state changes
    ref.listen<ArticleUploadState>(articleUploadProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${next.error}'),
            backgroundColor: Colors.red,
          ),
        );
      } else if (next.uploadedArticle != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Article uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Invalidate articles list to refresh
        ref.invalidate(articlesProvider);
        Navigator.pop(context);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Article'),
        actions: [
          TextButton(
            onPressed: uploadState.isLoading ? null : _submitArticle,
            child: uploadState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Publish',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              const Text(
                'Featured Image',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to add image',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Article Title *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Summary
              TextFormField(
                controller: _summaryController,
                decoration: const InputDecoration(
                  labelText: 'Summary (Optional)',
                  hintText: 'Brief description of the article',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Content
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Article Content *',
                  hintText: 'Write your article content here. You can use HTML tags.',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter article content';
                  }
                  return null;
                },
                maxLines: 15,
              ),
              const SizedBox(height: 16),

              // Tags
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (Optional)',
                  hintText: 'Enter tags separated by commas',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Read Time
              TextFormField(
                controller: _readTimeController,
                decoration: const InputDecoration(
                  labelText: 'Estimated Read Time (minutes)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Published Toggle
              SwitchListTile(
                title: const Text('Publish immediately'),
                subtitle: const Text('Article will be visible to all users'),
                value: _isPublished,
                onChanged: (value) {
                  setState(() {
                    _isPublished = value;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Author Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue[100],
                      child: Text(
                        _currentUserName.isNotEmpty 
                            ? _currentUserName[0].toUpperCase()
                            : 'A',
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Author',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          _currentUserName.isNotEmpty 
                              ? _currentUserName 
                              : 'Loading...',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
