// 利用規約画面
import 'package:dating/constants.dart';
import 'package:dating/main.dart';
import 'package:dating/model/User.dart';
import 'package:dating/services/helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// class TermsofuseScreen extends StatelessWidget {
//   UserInformation user;

//   TermsofuseScreen({Key? key, required this.user}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: Color(0xffFAFAFA),
//         appBar: AppBar(
//           automaticallyImplyLeading: false,
//           //ちょい透かし
//           backgroundColor: Color(0xffFAFAFA),
//           elevation: 0,
//         ),
//         body: SingleChildScrollView(
//           child: Container(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 Image.asset(
//                   'assets/images/mattyo2.png',
//                   width: 150.0,
//                   height: 150.0,
//                   color: Color(COLOR_PRIMARY),
//                   fit: BoxFit.cover,
//                 ),
//                 Container(
//                   height: 430,
//                   child: List(),
//                 ),
//                 SizedBox(
//                   height: 30,
//                 ),
//                 SizedBox(
//                   height: 50,
//                   width: 300,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.all(Radius.circular(30))),
//                       primary: Color(COLOR_PRIMARY),
//                       onPrimary: Colors.white,
//                     ),
//                     onPressed: () {
//                       pushAndRemoveUntil(context, OnTutorial(), false);
//                     },
//                     child: const Text('同意する'),
//                   ),
//                 ),
//                 SizedBox(
//                   height: 20,
//                 ),
//               ],
//             ),
//           ),
//         ));
//   }
// }

// class List extends StatelessWidget {
//   const List({Key? key}) : super(key: key);

//   get length => null;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Expanded(
//           child: ListView(
//             physics: const NeverScrollableScrollPhysics(),
//             children: [
//               SizedBox(
//                 height: 70,
//                 child: ListTile(
//                   title: Text('男性のマッチョ以外はご利用できません！',
//                       style:
//                           TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
//                   subtitle: Text('マッチョじゃないと判断した場合は強制退会を行うことがございます。',
//                       style: TextStyle(
//                         fontSize: 15,
//                         color: Color(COLOR_PRIMARY),
//                       )),
//                 ),
//               ),
//               SizedBox(
//                 height: 70,
//                 child: ListTile(
//                   title: Text('安全第一！',
//                       style:
//                           TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
//                   subtitle: Text('しっかりやりとりをし、安全を確認した上で個人情報を教えよう。',
//                       style: TextStyle(
//                         fontSize: 15,
//                         color: Color(COLOR_PRIMARY),
//                       )),
//                 ),
//               ),
//               SizedBox(
//                 height: 70,
//                 child: ListTile(
//                   title: Text('正確な情報を！',
//                       style:
//                           TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
//                   subtitle: Text('プロフォール欄は正確な情報を入力しよう!\n男性は必ず筋肉の写真を一枚登録してください！',
//                       style: TextStyle(
//                         fontSize: 15,
//                         color: Color(COLOR_PRIMARY),
//                       )),
//                 ),
//               ),
//               SizedBox(
//                 height: 70,
//                 child: ListTile(
//                   title: Text('トラブルは避けよう！',
//                       style:
//                           TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
//                   subtitle: Text('トラブルは未然に防ぎましょう！心配な場合は周りの人に相談を。',
//                       style: TextStyle(
//                         fontSize: 15,
//                         color: Color(COLOR_PRIMARY),
//                       )),
//                 ),
//               ),
//               SizedBox(
//                 height: 70,
//                 child: ListTile(
//                   title: Text('18歳未満の方は使用しないでください！',
//                       style:
//                           TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
//                   subtitle: Text(
//                       '18歳未満のマッチングアプリの使用は法律上禁止のため使用しないでください。（18歳以上の高校生を含む）',
//                       style: TextStyle(
//                         fontSize: 15,
//                         color: Colors.red,
//                       )),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         InkWell(
//           child: Text(
//             "利用規約を見る",
//             style: TextStyle(
//               decoration: TextDecoration.underline,
//               fontSize: 17,
//             ),
//           ),
//           onTap: () async {
//             const url = "https://www.turings.jp/termsofuse";
//             if (await canLaunch(url)) {
//               await launch(url);
//             }
//           },
//         ),
//       ],
//     );
//   }

//   void clear() {}
// }
