import 'package:flutter/material.dart';

class ContactPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('contact')),
      body: const SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Text(
                "ご依頼やお問い合わせは、こちらのページを確認の上、ページ下のメールアドレスまでご連絡ください。",
                style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    Text("〈ご依頼について〉",
                        style: TextStyle(
                            fontSize: 23, fontWeight: FontWeight.bold)),
                    Text("イラストのご依頼は、商用・非商用問わず承っております。\nご依頼の際には\n")        
            ],
          ),
        ),
    ));
  }
}
