import 'package:dating/constants.dart';
import 'package:dating/main.dart';
import 'package:dating/model/User.dart';
import 'package:dating/services/FirebaseHelper.dart';
import 'package:dating/services/helper.dart';
import 'package:dating/ui/home/HomeScreen.dart';
import 'package:dating/ui/reauthScreen/reauth_user_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AccountDetailsScreen extends StatefulWidget {
  final UserInformation user;

  AccountDetailsScreen({Key? key, required this.user}) : super(key: key);

  @override
  _AccountDetailsScreenState createState() {
    return _AccountDetailsScreenState();
  }
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  late UserInformation user;
  GlobalKey<FormState> _key = GlobalKey();
  AutovalidateMode _validate = AutovalidateMode.disabled;
  String? firstName, lastName, age, bio, email, mobile;

  @override
  void initState() {
    user = widget.user;
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
          title: Text('アカウント',
              style: TextStyle(
                  fontSize: 15,
                  color: Color(COLOR_PRIMARY),
                  fontWeight: FontWeight.w700)),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _key,
            autovalidateMode: _validate,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                    Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16, bottom: 8, top: 24),
                child: Text(
                  '公開情報'.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(COLOR_PRIMARY),
                  ),
                ),
              ),
              Material(
                  elevation: 2,
                  color: Colors.white,
                  child: ListView(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: ListTile.divideTiles(context: context, tiles: [
                        ListTile(
                          title: Text(
                            '氏名'.tr(),
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          trailing: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 100),
                            child: TextFormField(
                              onSaved: (String? val) {
                                firstName = val;
                              },
                              validator: validateName,
                              textInputAction: TextInputAction.next,
                              textAlign: TextAlign.end,
                              initialValue: user.firstName,
                              style:
                                  TextStyle(fontSize: 18, color: Colors.black),
                              cursorColor: Color(COLOR_ACCENT),
                              textCapitalization: TextCapitalization.words,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '氏名'.tr(),
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 5)),
                            ),
                          ),
                        ),
                        ListTile(
                          title: Text(
                            'ニックネーム'.tr(),
                            style: TextStyle(color: Colors.black),
                          ),
                          trailing: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 100),
                            child: TextFormField(
                              onSaved: (String? val) {
                                lastName = val;
                              },
                              validator: validateName,
                              textInputAction: TextInputAction.next,
                              textAlign: TextAlign.end,
                              initialValue: user.lastName,
                              style:
                                  TextStyle(fontSize: 18, color: Colors.black),
                              cursorColor: Color(COLOR_ACCENT),
                              textCapitalization: TextCapitalization.words,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'ニックネーム'.tr(),
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 5)),
                            ),
                          ),
                        ),
                        // ListTile(
                        //   title: Text(
                        //     '年齢'.tr(),
                        //     style: TextStyle(
                        //         color: isDarkMode(context)
                        //             ? Colors.white
                        //             : Colors.black),
                        //   ),
                        //   trailing: ConstrainedBox(
                        //     constraints: BoxConstraints(maxWidth: 100),
                        //     child: TextFormField(
                        //       onSaved: (String? val) {
                        //         age = val;
                        //       },
                        //       textInputAction: TextInputAction.next,
                        //       textAlign: TextAlign.end,
                        //       initialValue: user.age,
                        //       style: TextStyle(
                        //           fontSize: 18,
                        //           color: isDarkMode(context)
                        //               ? Colors.white
                        //               : Colors.black),
                        //       cursorColor: Color(COLOR_ACCENT),
                        //       textCapitalization: TextCapitalization.words,
                        //       keyboardType: TextInputType.number,
                        //       decoration: InputDecoration(
                        //           border: InputBorder.none,
                        //           hintText: '年齢'.tr(),
                        //           contentPadding:
                        //               EdgeInsets.symmetric(vertical: 5)),
                        //     ),
                        //   ),
                        // ),
                        ListTile(
                          title: Text(
                            '自己紹介'.tr(),
                            style: TextStyle(color: Colors.black),
                          ),
                          trailing: ConstrainedBox(
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * .5),
                            child: TextFormField(
                              onSaved: (String? val) {
                                bio = val;
                              },
                              initialValue: user.bio,
                              minLines: 1,
                              maxLines: 3,
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                  fontSize: 18, color: Colors.black45),
                              cursorColor: Color(COLOR_ACCENT),
                              textCapitalization: TextCapitalization.words,
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '例) 初めまして！'.tr(),
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 5)),
                            ),
                          ),
                        ),
                      ]).toList())),
              Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16, bottom: 8, top: 24),
                child: Text(
                  'プライベート詳細'.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(COLOR_PRIMARY),
                  ),
                ),
              ),
              Material(
                elevation: 2,
                color: Colors.white,
                child: ListView(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: ListTile.divideTiles(
                      context: context,
                      tiles: [
                        ListTile(
                          title: Text(
                            'メールアドレス'.tr(),
                            style: TextStyle(color: Colors.black),
                          ),
                          trailing: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 200),
                            child: TextFormField(
                              onSaved: (String? val) {
                                email = val;
                              },
                              validator: validateEmail,
                              textInputAction: TextInputAction.next,
                              initialValue: user.email,
                              textAlign: TextAlign.end,
                              style:
                                  TextStyle(fontSize: 18, color: Colors.black),
                              cursorColor: Color(COLOR_ACCENT),
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Email Address'.tr(),
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 5)),
                            ),
                          ),
                        ),
                      ],
                    ).toList()),
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
                          _validateAndSave();
                        },
                        child: Text(
                          '保存'.tr(),
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(COLOR_PRIMARY),
                          ),
                        ),
                      ),
                    ),
                  )),
            ]),
          ),
        ));
  }

  _validateAndSave() async {
    if (_key.currentState?.validate() ?? false) {
      _key.currentState!.save();
      AuthProviders? authProvider;
      List<auth.UserInfo> userInfoList =
          auth.FirebaseAuth.instance.currentUser?.providerData ?? [];
      await Future.forEach(userInfoList, (auth.UserInfo info) {
        if (info.providerId == 'password') {
          authProvider = AuthProviders.PASSWORD;
        } else if (info.providerId == 'phone') {
          authProvider = AuthProviders.PHONE;
        }
      });
      bool? result = false;
      if (authProvider == AuthProviders.PHONE &&
          auth.FirebaseAuth.instance.currentUser!.phoneNumber != mobile) {
        result = await showDialog(
          context: context,
          builder: (context) => ReAuthUserScreen(
            provider: authProvider!,
            phoneNumber: mobile,
            deleteUser: false,
          ),
        );
        if (result != null && result) {
          await showProgress(context, '保存中...'.tr(), false);
          await _updateUser();
          await hideProgress();
          pushReplacement(context, HomeScreen(user: user));
        }
      } else if (authProvider == AuthProviders.PASSWORD &&
          auth.FirebaseAuth.instance.currentUser!.email != email) {
        result = await showDialog(
          context: context,
          builder: (context) => ReAuthUserScreen(
            provider: authProvider!,
            email: email,
            deleteUser: false,
          ),
        );
        if (result != null && result) {
          await showProgress(context, '保存中...'.tr(), false);
          await _updateUser();
          await hideProgress();
          pushReplacement(context, HomeScreen(user: user));
        }
      } else {
        showProgress(context, '保存中...'.tr(), false);
        await _updateUser();
        hideProgress();
        pushReplacement(context, HomeScreen(user: user));
      }
    } else {
      setState(() {
        _validate = AutovalidateMode.onUserInteraction;
      });
    }
  }

  _updateUser() async {
    user.firstName = firstName!;
    user.lastName = lastName!;
    user.bio = bio!;
    user.email = email!;

    UserInformation? updatedUser = await FireStoreUtils.updateCurrentUser(user);
    if (updatedUser != null) {
      MyAppState.currentUser = user;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '保存しました'.tr(),
            style: TextStyle(fontSize: 17),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Couldn\'t save details, Please try again.'.tr(),
            style: TextStyle(fontSize: 17),
          ),
        ),
      );
    }
  }
}
