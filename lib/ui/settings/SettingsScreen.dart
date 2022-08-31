import 'package:dating/constants.dart';
import 'package:dating/main.dart';
import 'package:dating/model/User.dart';
import 'package:dating/services/FirebaseHelper.dart';
import 'package:dating/services/helper.dart';
import 'package:dating/ui/home/HomeScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

//?マッチングの設定画面,settingsScreenやけど
class SettingsScreen extends StatefulWidget {
  final UserInformation user;

  const SettingsScreen({Key? key, required this.user}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late UserInformation user;

  late bool showMe, newMatches, messages, superLikes, topPicks;

  late String radius, gender, prefGender;

  @override
  void initState() {
    user = widget.user;
    showMe = user.showMe;
    newMatches = user.settings.pushNewMatchesEnabled;
    messages = user.settings.pushNewMessages;
    superLikes = user.settings.pushSuperLikesEnabled;
    topPicks = user.settings.pushTopPicksEnabled;
    radius = user.settings.distanceRadius;
    gender = user.settings.gender;
    prefGender = user.settings.genderPreference;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFAFAFA),
      appBar: AppBar(
        backgroundColor: Color(0xffFAFAFA),
        iconTheme: IconThemeData(color: Color(COLOR_PRIMARY)),
        elevation: 0.0,
        centerTitle: true,
        title: Text('各種設定',
            style: TextStyle(
                fontSize: 15,
                color: Color(COLOR_PRIMARY),
                fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        child: Builder(
            builder: (buildContext) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                          right: 16.0, left: 16, top: 16, bottom: 8),
                      child: Text(
                        'マッチングの設定'.tr(),
                        style: TextStyle(
                            color: Color(COLOR_PRIMARY), fontSize: 18),
                      ),
                    ),
                    Material(
                      elevation: 2,
                      color: Colors.white,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SwitchListTile.adaptive(
                              activeColor: Color(COLOR_ACCENT),
                              title: Text(
                                'アプリ内で私を表示する'.tr(),
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.black,
                                ),
                              ),
                              value: showMe,
                              onChanged: (bool newValue) {
                                showMe = newValue;
                                setState(() {});
                              }),
                          ListTile(
                            title: Text(
                              '距離'.tr(),
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.black,
                              ),
                            ),
                            trailing: GestureDetector(
                              onTap: _onDistanceRadiusClick,
                              child: Text(
                                  radius.isNotEmpty
                                      ? '$radius km'.tr()
                                      : '無制限'.tr(),
                                  style: TextStyle(
                                      fontSize: 17,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          right: 16.0, left: 16, top: 16, bottom: 8),
                      child: Text(
                        'プッシュ通知'.tr(),
                        style: TextStyle(
                            color: Color(COLOR_PRIMARY), fontSize: 18),
                      ),
                    ),
                    Material(
                      elevation: 2,
                      color: Colors.white,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SwitchListTile.adaptive(
                              activeColor: Color(COLOR_ACCENT),
                              title: Text(
                                'マッチング成立'.tr(),
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.black,
                                ),
                              ),
                              value: newMatches,
                              onChanged: (bool newValue) {
                                newMatches = newValue;
                                setState(() {});
                              }),
                          Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: SwitchListTile.adaptive(
                                  activeColor: Color(COLOR_ACCENT),
                                  title: Text(
                                    'メッセージ'.tr(),
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: Colors.black,
                                    ),
                                  ),
                                  value: messages,
                                  onChanged: (bool newValue) {
                                    messages = newValue;
                                    setState(() {});
                                  })),
                          // Padding(
                          //     padding: const EdgeInsets.only(top: 8),
                          //     child: SwitchListTile.adaptive(
                          //         activeColor: Color(COLOR_ACCENT),
                          //         title: Text(
                          //           'スーパーライク'.tr(),
                          //           style: TextStyle(
                          //             fontSize: 17,
                          //             color: isDarkMode(context)
                          //                 ? Colors.white
                          //                 : Colors.black,
                          //           ),
                          //         ),
                          //         value: superLikes,
                          //         onChanged: (bool newValue) {
                          //           superLikes = newValue;
                          //           setState(() {});
                          //         })),
                          Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: SwitchListTile.adaptive(
                                  activeColor: Color(COLOR_ACCENT),
                                  title: Text(
                                    'おすすめを表示'.tr(),
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: Colors.black,
                                    ),
                                  ),
                                  value: topPicks,
                                  onChanged: (bool newValue) {
                                    topPicks = newValue;
                                    setState(() {});
                                  })),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 32.0, bottom: 16),
                      child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(minWidth: double.infinity),
                        child: Material(
                          elevation: 2,
                          color: Colors.white,
                          child: CupertinoButton(
                            padding: const EdgeInsets.all(12.0),
                            onPressed: () async {
                              showProgress(context, '設定中...'.tr(), true);
                              user.settings.genderPreference = prefGender;
                              user.settings.gender = gender;
                              user.settings.showMe = showMe;
                              user.showMe = showMe;
                              user.settings.pushTopPicksEnabled = topPicks;
                              user.settings.pushNewMessages = messages;
                              user.settings.pushSuperLikesEnabled = superLikes;
                              user.settings.pushNewMatchesEnabled = newMatches;
                              user.settings.distanceRadius = radius;
                              UserInformation? updateUser =
                                  await FireStoreUtils.updateCurrentUser(user);
                              hideProgress();
                              if (updateUser != null) {
                                pushReplacement(
                                    context, HomeScreen(user: user));
                                this.user = updateUser;
                                MyAppState.currentUser = user;
                                ScaffoldMessenger.of(buildContext).showSnackBar(
                                  SnackBar(
                                    duration: Duration(seconds: 3),
                                    content: Text(
                                      '設定完了'.tr(),
                                      style: TextStyle(fontSize: 17),
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              '保存'.tr(),
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(COLOR_PRIMARY),
                              ),
                            ),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
      ),
    );
  }

  _onDistanceRadiusClick() {
    final action = CupertinoActionSheet(
      message: Text(
        '距離'.tr(),
        style: TextStyle(fontSize: 15.0),
      ),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text('8 km'.tr()),
          isDefaultAction: false,
          onPressed: () {
            Navigator.pop(context);
            radius = '8';
            setState(() {});
          },
        ),
        CupertinoActionSheetAction(
          child: Text('16 km'.tr()),
          isDestructiveAction: false,
          onPressed: () {
            Navigator.pop(context);
            radius = '16';
            setState(() {});
          },
        ),
        CupertinoActionSheetAction(
          child: Text('24 km'.tr()),
          isDestructiveAction: false,
          onPressed: () {
            Navigator.pop(context);
            radius = '24';
            setState(() {});
          },
        ),
        CupertinoActionSheetAction(
          child: Text('32 km'.tr()),
          isDestructiveAction: false,
          onPressed: () {
            Navigator.pop(context);
            radius = '32';
            setState(() {});
          },
        ),
        CupertinoActionSheetAction(
          child: Text('40 km'.tr()),
          isDestructiveAction: false,
          onPressed: () {
            Navigator.pop(context);
            radius = '40';
            setState(() {});
          },
        ),
        CupertinoActionSheetAction(
          child: Text('80 km'.tr()),
          isDestructiveAction: false,
          onPressed: () {
            Navigator.pop(context);
            radius = '80';
            setState(() {});
          },
        ),
        CupertinoActionSheetAction(
          child: Text('160km'.tr()),
          isDestructiveAction: false,
          onPressed: () {
            Navigator.pop(context);
            radius = '160';
            setState(() {});
          },
        ),
        CupertinoActionSheetAction(
          child: Text('無制限'.tr()),
          isDestructiveAction: false,
          onPressed: () {
            Navigator.pop(context);
            radius = '';
            setState(() {});
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text('Cancel'.tr()),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  _onGenderClick() {
    final action = CupertinoActionSheet(
      message: Text(
        '性別'.tr(),
        style: TextStyle(fontSize: 15.0),
      ),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text('女性'.tr()),
          isDefaultAction: false,
          onPressed: () {
            Navigator.pop(context);
            gender = '女性';
            setState(() {});
          },
        ),
        CupertinoActionSheetAction(
          child: Text('男性'.tr()),
          isDestructiveAction: false,
          onPressed: () {
            Navigator.pop(context);
            gender = '男性';
            setState(() {});
          },
        )
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text('キャンセル'.tr()),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  _onGenderPrefClick() {
    final action = CupertinoActionSheet(
      message: Text(
        'マッチングしたい性別'.tr(),
        style: TextStyle(fontSize: 15.0),
      ),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text('女性'.tr()),
          isDefaultAction: false,
          onPressed: () {
            Navigator.pop(context);
            prefGender = '女性';
            setState(() {});
          },
        ),
        CupertinoActionSheetAction(
          child: Text('男性'.tr()),
          isDestructiveAction: false,
          onPressed: () {
            Navigator.pop(context);
            prefGender = '男性';
            setState(() {});
          },
        ),
        CupertinoActionSheetAction(
          child: Text('All'.tr()),
          isDestructiveAction: false,
          onPressed: () {
            Navigator.pop(context);
            prefGender = 'All';
            setState(() {});
          },
        )
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text('キャンセル'.tr()),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }
}
