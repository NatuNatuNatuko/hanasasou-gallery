import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hanasasou/admin/admin_uid.dart';

class NewsDetailPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isAdmin = user?.uid == adminUid;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (isAdmin)
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
                                .doc(newsId)
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (date != null)
                Text(
                  '${date!.year}/${date!.month}/${date!.day}',
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 16),
              Text(
                content,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
