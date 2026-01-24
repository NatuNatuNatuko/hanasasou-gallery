import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hanasasou/news/news_service.dart';

class NewsEditPage extends StatefulWidget {
  final String newsId;
  final String title;
  final String content;

  const NewsEditPage({
    required this.newsId,
    required this.title,
    required this.content,
  });

  @override
  State<NewsEditPage> createState() => _NewsEditPageState();
}

class _NewsEditPageState extends State<NewsEditPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _imageUrlController;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _contentController = TextEditingController(text: widget.content);
    _imageUrlController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('タイトルと本文を入力してください')),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('ログインが必要です');

      await NewsService.updateNews(
        id: widget.newsId,
        title: _titleController.text.trim(),
        body: _contentController.text.trim(),
        imageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('更新しました')));
      Navigator.pop(context);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('更新失敗: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ニュース編集')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'タイトル'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: '本文'),
                maxLines: 5,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: '画像URL（オプション）',
                  hintText: 'https://example.com/image.jpg',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: Text(_submitting ? '更新中...' : '更新'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
