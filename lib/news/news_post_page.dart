import 'package:flutter/material.dart';
import 'package:hanasasou/news/news_service.dart';

class NewsPostPage extends StatefulWidget {
  @override
  State<NewsPostPage> createState() => _NewsPostPageState();
}

class _NewsPostPageState extends State<NewsPostPage> {
  final titleController = TextEditingController();
  final bodyController = TextEditingController();
  final imageUrlController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    titleController.dispose();
    bodyController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = titleController.text.trim();
    final body = bodyController.text.trim();
    final imageUrl = imageUrlController.text.trim();

    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('タイトルと本文を入力してください')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await NewsService.createNews(
        title: title,
        body: body,
        imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('投稿しました')),
      );
      Navigator.pop(context);
    } catch (e, st) {
      debugPrint('createNews error: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('投稿に失敗しました: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ニュース投稿")),
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(
                  labelText: '画像URL（任意）',
                  hintText: 'https://example.com/image.jpg',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'タイトル'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bodyController,
                decoration: const InputDecoration(labelText: '本文'),
                maxLines: 6,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text("投稿する"),
                  onPressed: _isSubmitting ? null : _submit,
                ),
              ),
              if (_isSubmitting)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    '投稿中...',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
