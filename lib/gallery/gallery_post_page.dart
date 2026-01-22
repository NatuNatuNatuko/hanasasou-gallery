import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hanasasou/gallery/gallery_service.dart';

class GalleryPostPage extends StatefulWidget {
  const GalleryPostPage({super.key});

  @override
  State<GalleryPostPage> createState() => _GalleryPostPageState();
}

class _GalleryPostPageState extends State<GalleryPostPage> {
  final _imageUrlController = TextEditingController();
  final _captionController = TextEditingController();
  final Set<String> _selectedTags = {};
  bool _submitting = false;

  @override
  void dispose() {
    _imageUrlController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_imageUrlController.text.isEmpty ||
        _captionController.text.isEmpty ||
        _selectedTags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('画像URL・説明・タグを入力してください')),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('ログインが必要です');

      await GalleryService.createItem(
        imageUrl: _imageUrlController.text.trim(),
        caption: _captionController.text.trim(),
        tags: _selectedTags.toList(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('投稿しました')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('投稿失敗: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _tagChip(String tag, String label) {
    return FilterChip(
      label: Text(label),
      selected: _selectedTags.contains(tag),
      onSelected: (selected) {
        setState(() {
          selected ? _selectedTags.add(tag) : _selectedTags.remove(tag);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('イラスト投稿')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: '画像URL',
                  hintText: 'https://example.com/image.jpg',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _captionController,
                decoration: const InputDecoration(labelText: '説明'),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  _tagChip('fanart', 'ファンアート'),
                  _tagChip('original', 'オリジナル'),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(),
                        )
                      : const Text('投稿する'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

