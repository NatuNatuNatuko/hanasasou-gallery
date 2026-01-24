import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hanasasou/gallery/gallery_service.dart';
import 'package:hanasasou/admin/admin_uid.dart';

class GalleryDetailPage extends StatefulWidget {
  final String itemId;
  final String imageUrl;
  final String caption;
  final List<String> tags;

  const GalleryDetailPage({
    required this.itemId,
    required this.imageUrl,
    required this.caption,
    required this.tags,
  });

  @override
  State<GalleryDetailPage> createState() => _GalleryDetailPageState();
}

class _GalleryDetailPageState extends State<GalleryDetailPage> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('ギャラリー詳細'),
        actions: [
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              final user = snapshot.data;
              if (user?.uid == adminUid) {
                return IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: _deleteItem,
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (widget.imageUrl.isNotEmpty)
              Image.network(
                widget.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 300,
                    color: Colors.grey[300],
                    child: const Center(child: Text('画像を読み込めません')),
                  );
                },
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.caption.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'キャプション',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.caption,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  if (widget.tags.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'タグ',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: widget.tags
                              .map(
                                (tag) => Chip(
                                  label: Text(tag),
                                  backgroundColor: Colors.redAccent.shade100,
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
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
          ],
        ),
      ),
    );
  }

  Future<void> _deleteItem() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.uid != adminUid) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('削除権限がありません')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認'),
        content: const Text('このギャラリー投稿を削除してもよろしいですか？'),
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

    if (confirmed != true) return;

    try {
      await GalleryService.deleteItem(widget.itemId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ギャラリー投稿を削除しました')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('削除に失敗しました: $e')),
      );
    }
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
          .collection('gallery')
          .doc(widget.itemId)
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
                                  .collection('gallery')
                                  .doc(widget.itemId)
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
          .collection('gallery')
          .doc(widget.itemId)
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
