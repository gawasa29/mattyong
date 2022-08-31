import 'package:dating/constants.dart';
import 'package:dating/main.dart';
import 'package:dating/model/User.dart';
import 'package:dating/services/FirebaseHelper.dart';
import 'package:dating/services/helper.dart';
import 'package:dating/ui/home/HomeScreen.dart';
import 'package:dating/ui/resetPasswordScreen/ResetPasswordScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

class LoginScreen extends StatefulWidget {
  @override
  State createState() {
    return _LoginScreen();
  }
}

class _LoginScreen extends State<LoginScreen> {
  GlobalKey<FormState> _key = GlobalKey();
  AutovalidateMode _validate = AutovalidateMode.disabled;
  Position? currentLocation;
  String? email, password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFAFAFA),
      appBar: AppBar(
        backgroundColor: Color(0xffFAFAFA),
        iconTheme: IconThemeData(color: Color(COLOR_PRIMARY)),
        elevation: 0.0,
      ),
      body: Form(
        key: _key,
        autovalidateMode: _validate,
        child: ListView(
          children: <Widget>[
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: double.infinity),
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 32.0, right: 16.0, left: 16.0),
                child: Text('ログイン'.tr(),
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Color(COLOR_PRIMARY),
                    )),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: double.infinity),
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 32.0, right: 24.0, left: 24.0),
                child: TextFormField(
                  textAlignVertical: TextAlignVertical.center,
                  textInputAction: TextInputAction.next,
                  style: TextStyle(fontSize: 18.0),
                  validator: (val) => validateEmail(val),
                  onSaved: (val) => email = val,
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: Color(COLOR_PRIMARY),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(left: 16, right: 16),
                    hintText: 'メールアドレス'.tr(),
                    hintStyle: TextStyle(color: Colors.grey),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide:
                            BorderSide(color: Color(COLOR_ACCENT), width: 2.0)),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(COLOR_PRIMARY)),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(COLOR_ACCENT)),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(COLOR_PRIMARY)),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                ),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: double.infinity),
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 32.0, right: 24.0, left: 24.0),
                child: TextFormField(
                  textAlignVertical: TextAlignVertical.center,
                  onSaved: (val) => password = val,
                  obscureText: true,
                  validator: (val) => validatePassword(val),
                  onFieldSubmitted: (password) => _login(),
                  textInputAction: TextInputAction.done,
                  style: TextStyle(fontSize: 18.0),
                  cursorColor: Color(COLOR_PRIMARY),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(left: 16, right: 16),
                    hintText: 'パスワード'.tr(),
                    hintStyle: TextStyle(color: Colors.grey),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide:
                            BorderSide(color: Color(COLOR_ACCENT), width: 2.0)),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(COLOR_PRIMARY)),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(COLOR_ACCENT)),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(COLOR_PRIMARY)),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                ),
              ),
            ),

            /// forgot password text, navigates user to ResetPasswordScreen
            /// and this is only visible when logging with email and password
            /// forgot password text, ResetPasswordScreenにユーザーをナビゲートする。
            /// 電子メールとパスワードでログインした場合のみ表示されます。
            Padding(
              padding: const EdgeInsets.only(top: 16, right: 24),
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => push(context, ResetPasswordScreen()),
                  child: Text(
                    'パスワードを覚えていませんか?'.tr(),
                    style: TextStyle(
                        color: Colors.lightBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 1),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: double.infinity),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color(COLOR_PRIMARY),
                    padding: EdgeInsets.only(top: 12, bottom: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        side: BorderSide(color: Color(COLOR_PRIMARY))),
                  ),
                  child: Text(
                    'ログイン'.tr(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xffFAFAFA),
                    ),
                  ),
                  onPressed: () => _login(),
                ),
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.all(32.0),
            //   child: Center(
            //     child: Text(
            //       'OR'.tr(),
            //       style: TextStyle(
            //           color: isDarkMode(context) ? Colors.white : Colors.black),
            //     ),
            //   ),
            // ),
            // Padding(
            //   padding:
            //       const EdgeInsets.only(right: 40.0, left: 40.0, bottom: 20),
            //   child: ConstrainedBox(
            //     constraints: const BoxConstraints(minWidth: double.infinity),
            //     child: ElevatedButton.icon(
            //       label: Expanded(
            //         child: Text(
            //           'Facebook Login'.tr(),
            //           textAlign: TextAlign.center,
            //           style: TextStyle(
            //               fontSize: 20,
            //               fontWeight: FontWeight.bold,
            //               color: Colors.white),
            //         ),
            //       ),
            //       icon: Padding(
            //         padding: const EdgeInsets.symmetric(vertical: 8.0),
            //         child: Image.asset(
            //           'assets/images/facebook_logo.png',
            //           color: Colors.white,
            //           height: 30,
            //           width: 30,
            //         ),
            //       ),
            //       style: ElevatedButton.styleFrom(
            //         primary: Color(FACEBOOK_BUTTON_COLOR),
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(25.0),
            //           side: BorderSide(
            //             color: Color(FACEBOOK_BUTTON_COLOR),
            //           ),
            //         ),
            //       ),
            //       onPressed: () async => loginWithFacebook(),
            //     ),
            //   ),
            // ),

            // InkWell(
            //   onTap: () {
            //     push(context, PhoneNumberInputScreen(login: true));
            //   },
            //   child: Center(
            //     child: Padding(
            //       padding: EdgeInsets.all(8.0),
            //       child: Text(
            //         '電話番号でログインする'.tr(),
            //         style: TextStyle(
            //             color: Colors.lightBlue,
            //             fontWeight: FontWeight.bold,
            //             fontSize: 15,
            //             letterSpacing: 1),
            //       ),
            //     ),
            //   ),
            // )
          ],
        ),
      ),
    );
  }

  _login() async {
    if (_key.currentState?.validate() ?? false) {
      _key.currentState!.save();
      await _loginWithEmailAndPassword();
    } else {
      setState(() {
        _validate = AutovalidateMode.onUserInteraction;
      });
    }
  }

  /// login with email and password with firebase
  /// @param email user email
  /// @param password user password
  /// firebaseでメールとパスワードを使ってログインする
  /// @param email ユーザのメールアドレス
  /// @param password ユーザのパスワード
  _loginWithEmailAndPassword() async {
    await showProgress(context, 'ログインしています、お待ちください...'.tr(), false);
    currentLocation = await getCurrentLocation();
    if (currentLocation != null) {
      dynamic result = await FireStoreUtils.loginWithEmailAndPassword(
          email!.trim(), password!.trim(), currentLocation!);
      await hideProgress();
      if (result != null && result is UserInformation) {
        MyAppState.currentUser = result;
        pushAndRemoveUntil(context, HomeScreen(user: result), false);
      } else if (result != null && result is String) {
        showAlertDialog(context, 'ログイン\ できませんでした'.tr(), result);
      } else {
        showAlertDialog(
            context, 'ログイン\ できませんでした'.tr(), 'ログインに失敗しました、もう一度お試しください.'.tr());
      }
    } else {
      await hideProgress();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('位置情報は、あなたが住んでいる地域の人々とマッチングするために必要です。'.tr()),
        duration: Duration(seconds: 6),
      ));
    }
  }

  loginWithFacebook() async {
    try {
      await showProgress(context, 'ログインしています、お待ちください...'.tr(), false);
      dynamic result = await FireStoreUtils.loginWithFacebook();
      await hideProgress();
      if (result != null && result is UserInformation) {
        MyAppState.currentUser = result;
        pushAndRemoveUntil(context, HomeScreen(user: result), false);
      } else if (result != null && result is String) {
        showAlertDialog(context, 'Error'.tr(), result.tr());
      } else {
        showAlertDialog(
            context, 'Error', 'Couldn\'t login with facebook.'.tr());
      }
    } catch (e, s) {
      await hideProgress();
      print('_LoginScreen.loginWithFacebook $e $s');
      showAlertDialog(context, 'Error', 'Couldn\'t login with facebook.'.tr());
    }
  }
}
