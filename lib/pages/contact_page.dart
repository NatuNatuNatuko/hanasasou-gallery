import 'package:flutter/material.dart';
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
class ContactPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('contact')),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "ご依頼やお問い合わせは、こちらのページを確認の上、ページ下のメールアドレスまでご連絡ください。",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              Sou( 
                title: '〈ご依頼について〉',
                text: 'イラストのご依頼は、商用・非商用問わず承っております。\nご依頼の際には\n・担当者様のお名前\n・制作内容（例：キャラクターデザイン、アイコンイラストなど）\n・納期\n・ご予算\n・返信期日\nを明記の上、ご連絡ください。\n内容を確認次第、折り返しご連絡いたします。\nスケジュールにより、お受けできない場合もございますので、ご了承ください。',
              ),
              const SizedBox(height: 25),  
              Sou(title: '〈引受不可能な案件について〉',
               text: '以下のような案件については、引き受けができかねますので、ご了承ください。\n・NFTのお誘い\n・R18に該当する内容\n・その他、当方が不適切と判断した内容'),
              const SizedBox(height: 25),  
              Sou(title: '〈料金の目安について〉',
               text: '料金は案件の内容や規模によって異なりますが、以下はあくまで目安となります。\n・アイコンイラスト：5000円〜\n・キャラクターデザイン：13000円〜\n・風景イラスト（夜）：2000円〜\n・風景イラスト（夕、昼）：3000円〜\n具体的な料金については、ご依頼内容を確認の上、お見積もりを提示いたします。'),
              const SizedBox(height: 25),  
              Sou(
                title: '〈著作権について〉',
                text: '納品したイラストの著作権は基本的に当方に帰属します。商用利用や二次配布、改変などを行う場合は、事前にご相談ください。また、当方の名前をクレジット表記していただけると幸いです。',
              ),
              const SizedBox(height: 30),
              Sou(title: '〈連絡先〉', text: 'メールアドレス：hanasasouarashino@gmail.com'),
              const SizedBox(height: 30),
              Sou(title: '〈SNS〉', text: 'X（旧Twitter）：https://x.com/hana_sa_sou'),
              const SizedBox(height: 30),
        ]),
    )));}}