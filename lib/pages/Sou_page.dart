import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ---------------- 管理者UID ----------------
const Set<String> adminUids = {
  'hASD1FmadwhhpvHTcfQknNSG41d2',
  'p6hQ9mVDawYFtuzsgs7KMZfIQwA3',
};

bool isAdmin(User? user) {
  return user != null && adminUids.contains(user.uid);
}

// ---------------- メイン ----------------
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyPortfolioApp());
}

class MyPortfolioApp extends StatelessWidget {
  const MyPortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Portfolio',
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

// ---------------- HomePage ----------------
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('花紗そう'),
        actions: [
          if (user == null)
            IconButton(
              icon: const Icon(Icons.login, color: Colors.white),
              onPressed: () {
                // ログインページを呼ぶ場合
              },
            ),
          if (user != null)
            IconButton(
              icon: const Icon(Icons.account_circle, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
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
              child: const Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage())),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("プロフィール"),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage())),
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text('ホーム画面コンテンツ'),
      ),
    );
  }
}

// ---------------- Profile Page ----------------
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール'),
        actions: [
          if (isAdmin(user))
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfilePageDynamic()),
                );
              },
            ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('profile').doc('main').get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          final fields = List<Map<String, dynamic>>.from(data['fields'] ?? []);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage(data['avatar'] ?? 'assets/Sou.jpg'),
                ),
                const SizedBox(height: 16),
                Text(data['name'] ?? '花紗そう', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(data['title'] ?? '', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 24),
                ...fields.map((f) => Sou(title: f['title'] ?? '', text: f['content'] ?? '')),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ---------------- Edit Profile Page ----------------
class EditProfilePageDynamic extends StatefulWidget {
  const EditProfilePageDynamic({super.key});

  @override
  State<EditProfilePageDynamic> createState() => _EditProfilePageDynamicState();
}

class _EditProfilePageDynamicState extends State<EditProfilePageDynamic> {
  final _formKey = GlobalKey<FormState>();
  List<TextEditingController> _titleControllers = [];
  List<TextEditingController> _contentControllers = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final doc = await FirebaseFirestore.instance.collection('profile').doc('main').get();
    final data = doc.data() ?? {};
    final fields = List<Map<String, dynamic>>.from(data['fields'] ?? []);

    _titleControllers = fields.map((f) => TextEditingController(text: f['title'] ?? '')).toList();
    _contentControllers = fields.map((f) => TextEditingController(text: f['content'] ?? '')).toList();
    setState(() {});
  }

  void _addField() {
    setState(() {
      _titleControllers.add(TextEditingController());
      _contentControllers.add(TextEditingController());
    });
  }

  void _removeField(int index) {
    setState(() {
      _titleControllers.removeAt(index);
      _contentControllers.removeAt(index);
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final fields = List.generate(
      _titleControllers.length,
      (i) => {
        'title': _titleControllers[i].text,
        'content': _contentControllers[i].text,
      },
    );

    try {
      await FirebaseFirestore.instance.collection('profile').doc('main').set({
        'fields': fields,
      });
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('プロフィールを更新しました')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('更新に失敗しました: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('プロフィール編集')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              for (int i = 0; i < _titleControllers.length; i++)
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        TextFormField(controller: _titleControllers[i], decoration: const InputDecoration(labelText: '項目名')),
                        TextFormField(controller: _contentControllers[i], decoration: const InputDecoration(labelText: '内容'), maxLines: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeField(i),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _addField,
                icon: const Icon(Icons.add),
                label: const Text('項目追加'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _saveProfile, child: const Text('保存')),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- Expandable Section ----------------
Widget Sou({required String title, required String text}) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8),
    child: ExpansionTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(text),
        ),
      ],
    ),
  );
}
