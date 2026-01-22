import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hanasasou/gallery/gallery_service.dart';
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
  late String _currentFilter;

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.filter;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ギャラリー')),
      body: Column(
        children: [
          // タブバー
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _filterButton('全て', 'all'),
                const SizedBox(width: 8),
                _filterButton('ファンアート', 'fanart'),
                const SizedBox(width: 8),
                _filterButton('オリジナル', 'original'),
              ],
            ),
          ),
          // グリッド
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: GalleryService.getItems(
                category: _currentFilter == 'all' ? null : _currentFilter,
              ),
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
          ),
        ],
      ),
    );
  }

  Widget _filterButton(String label, String filter) {
    final isActive = _currentFilter == filter;
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive
              ? Colors.pinkAccent.shade100
              : Colors.white.withOpacity(0.2),
          foregroundColor: isActive ? Colors.black : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        onPressed: () {
          setState(() {
            _currentFilter = filter;
          });
        },
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
