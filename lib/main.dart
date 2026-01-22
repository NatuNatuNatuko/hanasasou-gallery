import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hanasasou/admin/admin_uid.dart';
import 'package:hanasasou/firebase_options.dart';
import 'package:hanasasou/gallery/gallery_post_page.dart';
import 'package:hanasasou/gallery/gallery_detail_page.dart';
import 'package:hanasasou/login_page.dart';
import 'package:hanasasou/news/news_post_page.dart';
import 'package:hanasasou/news/news_service.dart';
import 'package:hanasasou/pages/blog_page.dart';
import 'package:hanasasou/pages/contact_page.dart';
import 'package:hanasasou/gallery/gallery_page.dart';
import 'package:hanasasou/pages/Sou_page.dart';
import 'package:hanasasou/pages/you_awesome_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyPortfolioApp());
}

class MyPortfolioApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Portfolio',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      routes: {
        '/gallery/all': (context) => GalleryPage(filter: 'all'),
        '/gallery/fanart': (context) => GalleryPage(filter: 'fanart'),
        '/gallery/original': (context) => GalleryPage(filter: 'original'),
        '/contact': (context) => ContactPage(),
        '/profile': (context) => ProfilePage(),
        '/blog': (context) => BlogListPage(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 156, 121, 136).withOpacity(0.8),
      appBar: AppBar(
        title: Text('花紗そう',
            style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.7))),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.2),
        actions: [
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              final user = snapshot.data;
              if (user == null) {
                return IconButton(
                  icon: Icon(Icons.login, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LoginPage()),
                    );
                  },
                );
              }
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ニュース投稿
                  IconButton(
                    icon: Icon(Icons.add, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => NewsPostPage()),
                      );
                    },
                  ),
                  // ギャラリー投稿
                  IconButton(
                    icon: Icon(Icons.photo_library, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              GalleryPostPage(),
                        ),
                      );
                    },
                  ),
                  // ログアウト
                  IconButton(
                    icon: Icon(Icons.logout, color: Colors.white),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('ログアウトしました')),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.redAccent.shade100),
              child: const Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () => Navigator.pushNamed(context, '/'),
            ),
            ExpansionTile(
              leading: const Icon(Icons.photo),
              title: const Text("ギャラリー"),
              children: [
                ListTile(
                  title: const Text("全て見る"),
                  onTap: () => Navigator.pushNamed(context, '/gallery/all'),
                ),
                ListTile(
                  title: const Text("ファンアート"),
                  onTap: () => Navigator.pushNamed(context, '/gallery/fanart'),
                ),
                ListTile(
                  title: const Text("オリジナル"),
                  onTap: () => Navigator.pushNamed(context, '/gallery/original'),
                ),
              ],
            ),
            ListTile(
              leading:const Icon(Icons.email),
              title: const Text("コンタクト"),
              onTap: () => Navigator.pushNamed(context, '/contact'),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("花紗そう"),
              onTap: () => Navigator.pushNamed(context, '/profile'),
            ),
            ListTile(
              leading: Icon(Icons.article),
              title: Text("ブログ"),
              onTap: () => Navigator.pushNamed(context, '/blog'),
            ),
          ],
        ),
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 400,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.redAccent.shade100,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(color: Colors.black.withOpacity(0.2)),
                  Image.asset(
                    'assets/header.jpg',
                    width: double.infinity,
                    height: 400,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(color: Colors.redAccent.shade100);
                    },
                  ),
                  const Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "花紗そう",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                                offset: Offset(2, 2),
                                blurRadius: 8,
                                color: Colors.black54)
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'セミリアルイラストレーター',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          shadows: [
                            Shadow(
                                offset: Offset(2, 2),
                                blurRadius: 8,
                                color: Colors.black54)
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              '- GALLERY -',
              style: TextStyle(color: Colors.white, fontSize: 30),
            ),
            const SizedBox(height: 20),
            _AutoScrollingGallery(),
            const SizedBox(height: 40),
            // Flutter1.22以降のみ
            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                icon: const Icon(
                  Icons.view_agenda,
                  color: Color.fromARGB(255, 69, 35, 42),
                ),
                label: const Text('view more'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 69, 35, 42),
                  backgroundColor: const Color.fromARGB(255, 253, 222, 250),
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => GalleryPage(filter: 'all')));
                },
              ),
            ),
            const SizedBox(height: 100),
            const Text(
              '- NEW -',
              style: TextStyle(color: Colors.white, fontSize: 30),
            ),
            const SizedBox(height: 10),
            StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, authSnap) {
                final currentUser = authSnap.data;
                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: NewsService.getLatestNews(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final docs = snapshot.data!.docs;
                    if (docs.isEmpty) {
                      return Text('投稿がありません', style: TextStyle(color: Colors.white70));
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final news = doc.data();
                        final isAdmin = currentUser?.uid == adminUid;
                        DateTime? date;
                        if (news['createdAt'] != null) {
                          final rawDate = news['createdAt'];
                          if (rawDate is Timestamp) {
                            date = rawDate.toDate();
                          } else if (rawDate is DateTime) {
                            date = rawDate;
                          }
                        }

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => NewsDetailPage(
                                  title: news['title'] ?? '',
                                  content: news['body'] ?? '',
                                  date: date,
                                  newsId: doc.id,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.pinkAccent.shade100.withOpacity(0.4),
                                  Colors.purpleAccent.shade100.withOpacity(0.25),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                color: Colors.pinkAccent.shade100.withOpacity(0.6),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.pinkAccent.shade100.withOpacity(0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 3,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(2),
                                          color: Colors.pinkAccent.shade100,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          news['title'] ?? '',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 13),
                                    child: Text(
                                      news['body'] ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      if (date != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            color: Colors.white12,
                                          ),
                                          child: Text(
                                            '${date.year}/${date.month}/${date.day}',
                                            style: const TextStyle(
                                              color: Colors.white60,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      if (isAdmin)
                                        IconButton(
                                          icon: Icon(Icons.delete, color: Colors.red.shade300, size: 18),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title: Text('削除'),
                                                content: Text('この投稿を削除しますか？'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(ctx),
                                                    child: Text('キャンセル'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      try {
                                                        await FirebaseFirestore.instance
                                                            .collection('news')
                                                            .doc(doc.id)
                                                            .delete();
                                                        if (!context.mounted) return;
                                                        Navigator.pop(ctx);
                                                      } catch (e) {
                                                        ScaffoldMessenger.of(context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                              content: Text('削除失敗: $e')),
                                                        );
                                                      }
                                                    },
                                                    child: Text('削除'),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                icon: const Icon(
                  Icons.view_agenda,
                  color: const Color.fromARGB(255, 69, 35, 42),
                ),
                label: const Text('view more'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 69, 35, 42),
                  backgroundColor: const Color.fromARGB(255, 253, 222, 250),
                ),
                onPressed: () {},
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

class _AutoScrollingGallery extends StatefulWidget {
  @override
  State<_AutoScrollingGallery> createState() => _AutoScrollingGalleryState();
}

class _AutoScrollingGalleryState extends State<_AutoScrollingGallery>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    _animationController.addListener(_autoScroll);
  }

  void _autoScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = maxScroll * _animationController.value;
      _scrollController.jumpTo(currentScroll);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('gallery')
          .orderBy('createdAt', descending: true)
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final items = snapshot.data!.docs;
        if (items.isEmpty) {
          return const SizedBox(
            height: 200,
            child: Center(
              child: Text(
                'ギャラリーに画像がありません',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          );
        }

        return SizedBox(
          height: 200,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index].data();
              final itemId = items[index].id;
              final imageUrl = item['imageUrl'] as String?;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GestureDetector(
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
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: imageUrl != null && imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey[700],
                                child: const Icon(Icons.broken_image),
                              ),
                            )
                          : Container(
                              color: Colors.grey[700],
                              child: const Icon(Icons.image),
                            ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
