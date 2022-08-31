import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating/constants.dart';
import 'package:dating/main.dart';
import 'package:dating/model/User.dart';
import 'package:dating/services/FirebaseHelper.dart';
import 'package:dating/services/helper.dart';
import 'package:dating/ui/accountDetails/AccountDetailsScreen.dart';
import 'package:dating/ui/auth/AuthScreen.dart';
import 'package:dating/ui/contactUs/ContactUsScreen.dart';
import 'package:dating/ui/reauthScreen/reauth_user_screen.dart';
import 'package:dating/ui/settings/SettingsScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

//?設定画面
class AllSettingScreen extends StatefulWidget {
  final UserInformation user;

  AllSettingScreen({Key? key, required this.user}) : super(key: key);

  @override
  _AllSettingScreenState createState() => _AllSettingScreenState();
}

class _AllSettingScreenState extends State<AllSettingScreen> {
  late UserInformation user;
  @override
  void initState() {
    user = widget.user;
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFAFAFA),
      appBar: AppBar(
        backgroundColor: Color(0xffFAFAFA),
        iconTheme: IconThemeData(color: Colors.black),
        title: Text('設定',
            style: TextStyle(
                fontSize: 15,
                color: Color(COLOR_PRIMARY),
                fontWeight: FontWeight.w700)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ListTile(
              dense: true,
              onTap: () async {
                await push(context, AccountDetailsScreen(user: user));
              },
              title: Text(
                'アカウント詳細'.tr(),
                style: TextStyle(fontSize: 16),
              ),
              leading: Icon(
                Icons.person,
                color: Colors.blue,
              ),
            ),
            // ListTile(
            //   dense: true,
            //   onTap: () {
            //     showModalBottomSheet(
            //       isScrollControlled: true,
            //       context: context,
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.vertical(
            //           top: Radius.circular(20),
            //         ),
            //       ),
            //       builder: (context) {
            //         return UpgradeAccount();
            //       },
            //     );
            //   },
            //   title: Text(
            //     user.isVip ? 'サブスクリプションのキャンセル'.tr() : 'アカウントのアップグレード'.tr(),
            //     style: TextStyle(fontSize: 16),
            //   ),
            //   leading: Image.asset(
            //     'assets/images/vip.png',
            //     height: 24,
            //     width: 24,
            //   ),
            // ),
            ListTile(
              dense: true,
              onTap: () async {
                await push(context, SettingsScreen(user: user));
              },
              title: Text(
                '各種設定'.tr(),
                style: TextStyle(fontSize: 16),
              ),
              leading: Icon(
                Icons.settings,
                color: Colors.black45,
              ),
            ),
            ListTile(
              dense: true,
              onTap: () {
                push(context, ContactUsScreen());
              },
              title: Text(
                'お問い合わせ'.tr(),
                style: TextStyle(fontSize: 16),
              ),
              leading: Icon(
                Icons.mail,
                color: Colors.green,
              ),
            ),
            ListTile(
              dense: true,
              onTap: () async {
                AuthProviders? authProvider;
                List<auth.UserInfo> userInfoList =
                    auth.FirebaseAuth.instance.currentUser?.providerData ?? [];
                await Future.forEach(userInfoList, (auth.UserInfo info) {
                  switch (info.providerId) {
                    case 'password':
                      authProvider = AuthProviders.PASSWORD;
                      break;
                    case 'phone':
                      authProvider = AuthProviders.PHONE;
                      break;
                    case 'facebook.com':
                      authProvider = AuthProviders.FACEBOOK;
                      break;
                    case 'apple.com':
                      authProvider = AuthProviders.APPLE;
                      break;
                  }
                });
                bool? result = await showDialog(
                  context: context,
                  builder: (context) => ReAuthUserScreen(
                    provider: authProvider!,
                    email: auth.FirebaseAuth.instance.currentUser!.email,
                    phoneNumber:
                        auth.FirebaseAuth.instance.currentUser!.phoneNumber,
                    deleteUser: true,
                  ),
                );
                if (result != null && result) {
                  await showProgress(context, 'アカウントを削除しています...'.tr(), false);
                  await FireStoreUtils.deleteUser();
                  await hideProgress();
                  MyAppState.currentUser = null;
                  pushAndRemoveUntil(context, AuthScreen(), false);
                }
              },
              title: Text(
                'アカウント削除'.tr(),
                style: TextStyle(fontSize: 16),
              ),
              leading: Icon(
                CupertinoIcons.delete,
                color: Colors.red,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: double.infinity),
                child: TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.transparent,
                    padding: EdgeInsets.only(top: 12, bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Text(
                    'ログアウト'.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  onPressed: () async {
                    user.active = false;
                    user.lastOnlineTimestamp = Timestamp.now();
                    //!これはなんかログアウトの時にデータベース更新したやつ消されるやつ
                    // await FireStoreUtils.updateCurrentUser(user);
                    await auth.FirebaseAuth.instance.signOut();
                    MyAppState.currentUser = null;
                    pushAndRemoveUntil(context, AuthScreen(), false);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
