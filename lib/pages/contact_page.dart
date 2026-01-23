import 'package:flutter/material.dart';

class ContactPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('contact')),
      body: const SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "ご依頼やお問い合わせは、こちらのページを確認の上、ページ下のメールアドレスまでご連絡ください。",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 25),
              Text("〈ご依頼について〉",
                  style: TextStyle(
                      fontSize: 23, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              Text("イラストのご依頼は、商用・非商用問わず承っております。\nご依頼の際には\n・担当者様のお名前\n・制作内容（例：キャラクターデザイン、アイコンイラストなど）\n・納期\n・ご予算\n・返信期日\nを明記の上、ご連絡ください。\n内容を確認次第、折り返しご連絡いたします。\nスケジュールにより、お受けできない場合もございますので、ご了承ください。",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center),      
              SizedBox(height: 25),  
              Text("〈引受不可能な案件について〉",
                  style: TextStyle(
                      fontSize: 23, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              Text("以下のような案件については、引き受けができかねますので、ご了承ください。\n・NFTのお誘い\n・R18に該当する内容\n・その他、当方が不適切と判断した内容",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center),
              SizedBox(height: 25),  
              Text("〈料金の目安について〉",
                  style: TextStyle(
                      fontSize: 23, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              SizedBox(height: 10),
              Text("[基本料金一覧]\n・キャラクターデザイン：10,000円〜\n・アイコンイラスト：8,000円〜\n・風景イラスト（夜）：2,000円〜\n・背景イラスト（夕）:2,500円〜\n・一枚絵：30,000円〜\n※料金はあくまで目安です。内容や納期により変動する場合がございますので、ご了承ください。",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center),
          ]),
        ),
    ));
  }
}
