import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hanasasou/admin/admin_uid.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _deleteProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.uid != adminUid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('削除権限がありません')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('確認'),
        content: Text('プロフィールデータを削除してもよろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await FirebaseFirestore.instance.collection('profile').doc('main').delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('プロフィールを削除しました')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('削除に失敗しました: $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール'),
        actions: [
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              final user = snapshot.data;
              if (user?.uid == adminUid) {
                return IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: _deleteProfile,
                );
              }
              return SizedBox.shrink();
            },
          ),
        ],
      ),
      
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // プロフィールヘッダー
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Center(
                        child:  CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage('assets/Sou.jpg'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '花紗そう',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'セミリアルイラストレーター',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // 自己紹介
              Sou(
                title: '自己紹介',
                text: '''セミリアルイラストレーターとして活動しています。
美しい風景や人物描写を得意としており、
様々なプロジェクトに参加しています。''',
              ),
              const SizedBox(height: 16),
              
              // スキル
              Sou(
                title: 'スキル',
                text: '''・デジタル絵画
・キャラクターデザイン
・風景イラスト
・カラーコンセプト
・アニメーション基礎''',
              ),
              const SizedBox(height: 16),
              
              // 経歴
              Sou(
                title: '経歴',
                text: '''2020年：個人でイラスト活動を開始
2021年：複数のプロジェクトに参加
2022年：セミリアルスタイルを確立
2023年：ギャラリーサイト開設
2024年：商業案件多数受注''',
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpandableSection extends StatefulWidget {
  final String title;
  final String content;

  const _ExpandableSection({
    required this.title,
    required this.content,
  });

  @override
  State<_ExpandableSection> createState() => _ExpandableSectionState();
}

Widget Sou({
  required String title,
  required String text,
}) {
  return ExpansionTile(
    title: Text(title),
    children: [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(text),
      ),
    ],
  );
}

class _ExpandableSectionState extends State<_ExpandableSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(widget.title),
            trailing: RotationTransition(
              turns: _animation,
              child: Icon(Icons.expand_more),
            ),
            onTap: _toggle,
          ),
          SizeTransition(
            sizeFactor: _animation,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(widget.content),
            ),
          ),
        ],
      ),
    );
  }
}

class Sou_page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProfilePage();
  }
}

