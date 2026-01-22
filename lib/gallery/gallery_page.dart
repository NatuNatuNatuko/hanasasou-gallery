import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hanasasou/gallery/gallery_service.dart';
import 'package:hanasasou/admin/admin_uid.dart';
import 'package:hanasasou/gallery/gallery_detail_page.dart';

class GalleryPage extends StatefulWidget {
  final String filter;

  const GalleryPage({
    Key? key,
    required this.filter,
  }) : super(key: key);

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ギャラリー')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: GalleryService.getItems(category: widget.filter == 'all' ? null : widget.filter),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!.docs;
          if (items.isEmpty) {
            return const Center(child: Text('画像がありません'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index].data();
              final itemId = items[index].id;
              final imageUrl = item['imageUrl'] as String?;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GalleryDetailPage(
                        itemId: itemId,
                        imageUrl: imageUrl ?? '',
                        caption: item['caption'] ?? '',
                        tags: List<String>.from(item['tags'] ?? []),
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? Image.network(imageUrl, fit: BoxFit.cover)
                      : Container(color: Colors.grey[300]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
