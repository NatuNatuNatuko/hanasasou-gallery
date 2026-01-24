import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hanasasou/admin/admin_uid.dart';
import 'package:hanasasou/news/news_service.dart';

class NewsDetailPage extends StatefulWidget {
  final String title;
  final String content;
  final DateTime? date;
  final String newsId;

  const NewsDetailPage({
    Key? key,
    required this.title,
    required this.content,
    this.date,
    required this.newsId,
  }) : super(key: key);

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  final _commentController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isAdmin = user?.uid == adminUid;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (isAdmin)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NewsEditPage(
                          newsId: widget.newsId,
                          title: widget.title,
                          content: widget.content,
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('削除確認'),
                        content: const Text('この投稿を削除しますか？'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('キャンセル'),
                          ),
                          TextButton(
                            onPressed: () async {
                          try {
                            await FirebaseFirestore.instance
                                .collection('news')
                                .doc(widget.newsId)
                                .delete();
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('削除しました')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('削除に失敗しました: $e')),
                            );
                          }
                        },
                        child: const Text('削除'),
                      ),
                    ],
                  ),
                );
              },
            ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.date != null)
                Text(
                  '${widget.date!.year}/${widget.date!.month}/${widget.date!.day}',
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 16),
              Text(
                widget.content,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              const Text('コメント', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildCommentForm(),
              const SizedBox(height: 16),
              _buildCommentsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentForm() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'お名前',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              hintText: 'コメントを入力...',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submitComment,
            child: Text(_isSubmitting ? '投稿中...' : 'コメント投稿'),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('news')
          .doc(widget.newsId)
          .collection('comments')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('コメントがありません'),
          );
        }

        final user = FirebaseAuth.instance.currentUser;
        final isAdmin = user?.uid == adminUid;

        return Column(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final userName = data['name'] as String? ?? '匿名';
            final content = data['content'] as String? ?? '';
            final timestamp = data['createdAt'] as Timestamp?;
            final date = timestamp?.toDate();

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          if (date != null)
                            Text(
                              '${date.year}/${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                        ],
                      ),
                      if (isAdmin)
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('確認'),
                                content: const Text('このコメントを削除しますか？'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('キャンセル'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('削除'),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true) {
                              await FirebaseFirestore.instance
                                  .collection('news')
                                  .doc(widget.newsId)
                                  .collection('comments')
                                  .doc(doc.id)
                                  .delete();
                            }
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(content),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _submitComment() async {
    final name = _nameController.text.trim();
    final content = _commentController.text.trim();

    if (name.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('お名前とコメントを入力してください')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance
          .collection('news')
          .doc(widget.newsId)
          .collection('comments')
          .add({
            'name': name,
            'content': content,
            'createdAt': FieldValue.serverTimestamp(),
          });

      _commentController.clear();
      _nameController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('コメントを投稿しました')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラー: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

class NewsEditPage extends StatefulWidget {
  final String newsId;
  final String title;
  final String content;

  const NewsEditPage({
    Key? key,
    required this.newsId,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  State<NewsEditPage> createState() => _NewsEditPageState();
}

class _NewsEditPageState extends State<NewsEditPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _contentController = TextEditingController(text: widget.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('タイトルと内容を入力してください')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await NewsService.updateNews(
        id: widget.newsId,
        title: _titleController.text,
        body: _contentController.text,
      );

      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('投稿を更新しました')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラー: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('投稿を編集')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'タイトル',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: '内容',
                  border: OutlineInputBorder(),
                ),
                maxLines: 8,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: Text(_isSubmitting ? '更新中...' : '更新'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
