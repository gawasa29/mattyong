import 'dart:io';

import 'package:dating/constants.dart';
import 'package:dating/grender.dart';
import 'package:dating/image.dart';
import 'package:dating/main.dart';
import 'package:dating/model/User.dart';
import 'package:dating/services/FirebaseHelper.dart';
import 'package:dating/services/helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

File? _image;

String? firstName,
    lastName,
    email,
    mobile,
    password,
    confirmPassword,
    age,
    residence,
    body,
    height,
    radius,
    gender,
    prefGender;

class SignUpScreen extends StatefulWidget {
  @override
  State createState() => _SignUpState();
}

class _SignUpState extends State<SignUpScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  TextEditingController _passwordController = TextEditingController();
  GlobalKey<FormState> _key = GlobalKey();

  Position? signUpLocation;
  AutovalidateMode _validate = AutovalidateMode.disabled;

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      retrieveLostData();
    }
    return Scaffold(
      backgroundColor: Color(0xffFAFAFA),
      appBar: AppBar(
        backgroundColor: Color(0xffFAFAFA),
        iconTheme: IconThemeData(color: Color(COLOR_PRIMARY)),
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(left: 16.0, right: 16, bottom: 16),
          child: Form(
            key: _key,
            autovalidateMode: _validate,
            child: formUI(),
          ),
        ),
      ),
    );
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse? response = await _imagePicker.retrieveLostData();
    if (response == null) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _image = File(response.file!.path);
      });
    }
  }

  _onCameraClick() {
    final action = CupertinoActionSheet(
      message: Text(
        'プロフィール写真の追加'.tr(),
        style: TextStyle(fontSize: 15.0),
      ),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text('ギャラリーから選択'.tr()),
          isDefaultAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image =
                await _imagePicker.pickImage(source: ImageSource.gallery);
            if (image != null)
              setState(() {
                _image = File(image.path);
              });
          },
        ),
        CupertinoActionSheetAction(
          child: Text('カメラで撮影'.tr()),
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image =
                await _imagePicker.pickImage(source: ImageSource.camera);
            if (image != null)
              setState(() {
                _image = File(image.path);
              });
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

  Widget formUI() {
    return Column(
      children: <Widget>[
        Align(
            alignment: Alignment.topLeft,
            child: Text(
              'アカウントを作成する'.tr(),
              style: TextStyle(
                  color: Color(COLOR_PRIMARY),
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0),
            )),
        Padding(
          padding:
              const EdgeInsets.only(left: 8.0, top: 32, right: 8, bottom: 8),
          child: Column(
            children: [
              Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    '正確な情報を全て入力してください。'.tr(),
                    style:
                        TextStyle(color: Color(COLOR_PRIMARY), fontSize: 15.0),
                  ))
            ],
          ),
        ),
        // Padding(
        //   padding:
        //       const EdgeInsets.only(left: 8.0, top: 32, right: 8, bottom: 8),
        //   child: Stack(
        //     alignment: Alignment.bottomCenter,
        //     children: <Widget>[
        //       CircleAvatar(
        //         radius: 65,
        //         backgroundColor: Colors.grey.shade400,
        //         child: ClipOval(
        //           child: SizedBox(
        //             width: 170,
        //             height: 170,
        //             child: _image == null
        //                 ? Image.asset(
        //                     'assets/images/placeholder.jpg'.tr(),
        //                     fit: BoxFit.cover,
        //                   )
        //                 : Image.file(
        //                     _image!,
        //                     fit: BoxFit.cover,
        //                   ),
        //           ),
        //         ),
        //       ),
        //       Positioned(
        //         left: 80,
        //         right: 0,
        //         child: FloatingActionButton(
        //             backgroundColor: Colors.purple,
        //             child: Icon(
        //               Icons.camera_alt,
        //               color: Color(0xffFAFAFA),
        //             ),
        //             mini: true,
        //             onPressed: _onCameraClick),
        //       )
        //     ],
        //   ),
        // ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              cursorColor: Color(COLOR_PRIMARY),
              textAlignVertical: TextAlignVertical.center,
              validator: validateName,
              onSaved: (String? val) {
                firstName = val;
              },
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                hintText: '氏名（フルネーム）'.tr(),
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
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              validator: validateName,
              textAlignVertical: TextAlignVertical.center,
              cursorColor: Color(COLOR_PRIMARY),
              onSaved: (String? val) {
                lastName = val;
              },
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                hintText: 'ニックネーム（他のユーザに表示されます）'.tr(),
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
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
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              keyboardType: TextInputType.emailAddress,
              textAlignVertical: TextAlignVertical.center,
              textInputAction: TextInputAction.next,
              cursorColor: Color(COLOR_PRIMARY),
              validator: validateEmail,
              onSaved: (String? val) {
                email = val;
              },
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
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

        /// user mobile text field, this is hidden in case of sign up with
        /// phone number
        /// ユーザーの携帯電話のテキストフィールド、これはでサインアップした場合に隠されます。
        /// 電話番号
        // ConstrainedBox(
        //   constraints: BoxConstraints(minWidth: double.infinity),
        //   child: Padding(
        //     padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
        //     child: TextFormField(
        //       keyboardType: TextInputType.phone,
        //       textAlignVertical: TextAlignVertical.center,
        //       textInputAction: TextInputAction.next,
        //       cursorColor: Color(COLOR_PRIMARY),
        //       validator: validateMobile,
        //       onSaved: (String? val) {
        //         mobile = val;
        //       },
        //       decoration: InputDecoration(
        //         contentPadding:
        //             EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        //         fillColor: Colors.white,
        //         hintText: 'Mobile'.tr(),
        //         focusedBorder: OutlineInputBorder(
        //             borderRadius: BorderRadius.circular(25.0),
        //             borderSide:
        //                 BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
        //         errorBorder: OutlineInputBorder(
        //           borderSide: BorderSide(color: Theme.of(context).errorColor),
        //           borderRadius: BorderRadius.circular(25.0),
        //         ),
        //         focusedErrorBorder: OutlineInputBorder(
        //           borderSide: BorderSide(color: Theme.of(context).errorColor),
        //           borderRadius: BorderRadius.circular(25.0),
        //         ),
        //         enabledBorder: OutlineInputBorder(
        //           borderSide: BorderSide(color: Colors.grey.shade200),
        //           borderRadius: BorderRadius.circular(25.0),
        //         ),
        //       ),
        //     ),
        //   ),
        // // ),
        // ConstrainedBox(
        //   constraints: BoxConstraints(minWidth: double.infinity),
        //   child: Padding(
        //     padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
        //     child: TextFormField(
        //       keyboardType: TextInputType.phone,
        //       textAlignVertical: TextAlignVertical.center,
        //       textInputAction: TextInputAction.next,
        //       cursorColor: Color(COLOR_PRIMARY),
        //       validator: validateMobile,
        //       onSaved: (String? val) {
        //         age = val;
        //       },
        //       decoration: InputDecoration(
        //         contentPadding:
        //             EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        //         fillColor: Colors.white,
        //         hintText: '年齢'.tr(),
        //         focusedBorder: OutlineInputBorder(
        //             borderRadius: BorderRadius.circular(25.0),
        //             borderSide:
        //                 BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
        //         errorBorder: OutlineInputBorder(
        //           borderSide: BorderSide(color: Theme.of(context).errorColor),
        //           borderRadius: BorderRadius.circular(25.0),
        //         ),
        //         focusedErrorBorder: OutlineInputBorder(
        //           borderSide: BorderSide(color: Theme.of(context).errorColor),
        //           borderRadius: BorderRadius.circular(25.0),
        //         ),
        //         enabledBorder: OutlineInputBorder(
        //           borderSide: BorderSide(color: Colors.grey.shade200),
        //           borderRadius: BorderRadius.circular(25.0),
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
        // ConstrainedBox(
        //   constraints: BoxConstraints(minWidth: double.infinity),
        //   child: Padding(
        //     padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
        //     child: TextFormField(
        //       cursorColor: Color(COLOR_PRIMARY),
        //       textAlignVertical: TextAlignVertical.center,
        //       validator: validateName,
        //       onSaved: (String? val) {
        //         residence = val;
        //       },
        //       textInputAction: TextInputAction.next,
        //       decoration: InputDecoration(
        //         contentPadding:
        //             EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        //         fillColor: Colors.white,
        //         hintText: '居住地'.tr(),
        //         focusedBorder: OutlineInputBorder(
        //             borderRadius: BorderRadius.circular(25.0),
        //             borderSide:
        //                 BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
        //         errorBorder: OutlineInputBorder(
        //           borderSide: BorderSide(color: Theme.of(context).errorColor),
        //           borderRadius: BorderRadius.circular(25.0),
        //         ),
        //         focusedErrorBorder: OutlineInputBorder(
        //           borderSide: BorderSide(color: Theme.of(context).errorColor),
        //           borderRadius: BorderRadius.circular(25.0),
        //         ),
        //         enabledBorder: OutlineInputBorder(
        //           borderSide: BorderSide(color: Colors.grey.shade200),
        //           borderRadius: BorderRadius.circular(25.0),
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
        // ConstrainedBox(
        //   constraints: BoxConstraints(minWidth: double.infinity),
        //   child: Padding(
        //     padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
        //     child: TextFormField(
        //       cursorColor: Color(COLOR_PRIMARY),
        //       textAlignVertical: TextAlignVertical.center,
        //       validator: validateName,
        //       onSaved: (String? val) {
        //         body = val;
        //       },
        //       textInputAction: TextInputAction.next,
        //       decoration: InputDecoration(
        //         contentPadding:
        //             EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        //         fillColor: Colors.white,
        //         hintText: '体型'.tr(),
        //         focusedBorder: OutlineInputBorder(
        //             borderRadius: BorderRadius.circular(25.0),
        //             borderSide:
        //                 BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
        //         errorBorder: OutlineInputBorder(
        //           borderSide: BorderSide(color: Theme.of(context).errorColor),
        //           borderRadius: BorderRadius.circular(25.0),
        //         ),
        //         focusedErrorBorder: OutlineInputBorder(
        //           borderSide: BorderSide(color: Theme.of(context).errorColor),
        //           borderRadius: BorderRadius.circular(25.0),
        //         ),
        //         enabledBorder: OutlineInputBorder(
        //           borderSide: BorderSide(color: Colors.grey.shade200),
        //           borderRadius: BorderRadius.circular(25.0),
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
        // ConstrainedBox(
        //   constraints: BoxConstraints(minWidth: double.infinity),
        //   child: Padding(
        //     padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
        //     child: TextFormField(
        //       cursorColor: Color(COLOR_PRIMARY),
        //       textAlignVertical: TextAlignVertical.center,
        //       validator: validateMobile,
        //       onSaved: (String? val) {
        //         height = val;
        //       },
        //       textInputAction: TextInputAction.next,
        //       decoration: InputDecoration(
        //         contentPadding:
        //             EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        //         fillColor: Colors.white,
        //         hintText: '身長'.tr(),
        //         focusedBorder: OutlineInputBorder(
        //             borderRadius: BorderRadius.circular(25.0),
        //             borderSide:
        //                 BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
        //         errorBorder: OutlineInputBorder(
        //           borderSide: BorderSide(color: Theme.of(context).errorColor),
        //           borderRadius: BorderRadius.circular(25.0),
        //         ),
        //         focusedErrorBorder: OutlineInputBorder(
        //           borderSide: BorderSide(color: Theme.of(context).errorColor),
        //           borderRadius: BorderRadius.circular(25.0),
        //         ),
        //         enabledBorder: OutlineInputBorder(
        //           borderSide: BorderSide(color: Colors.grey.shade200),
        //           borderRadius: BorderRadius.circular(25.0),
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              obscureText: true,
              textAlignVertical: TextAlignVertical.center,
              textInputAction: TextInputAction.next,
              controller: _passwordController,
              validator: validatePassword,
              onSaved: (String? val) {
                password = val;
              },
              style: TextStyle(fontSize: 18.0),
              cursorColor: Color(COLOR_PRIMARY),
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
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
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
              textAlignVertical: TextAlignVertical.center,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _signUp(),
              obscureText: true,
              validator: (val) =>
                  validateConfirmPassword(_passwordController.text, val),
              onSaved: (String? val) {
                confirmPassword = val;
              },
              style: TextStyle(fontSize: 18.0),
              cursorColor: Color(COLOR_PRIMARY),
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                fillColor: Colors.white,
                hintText: 'パスワードの確認'.tr(),
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
        Padding(
          padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 40.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: double.infinity),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Color(COLOR_PRIMARY),
                textStyle: TextStyle(color: Colors.white),
                padding: EdgeInsets.only(top: 12, bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  side: BorderSide(
                    color: Color(COLOR_PRIMARY),
                  ),
                ),
              ),
              child: Text(
                'アカウントを作る！'.tr(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xffFAFAFA),
                ),
              ),
              onPressed: () => _signUp(),
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
        // InkWell(
        //   onTap: () {
        //     push(context, PhoneNumberInputScreen(login: false));
        //   },
        //   child: Text(
        //     'Sign up with phone number'.tr(),
        //     style: TextStyle(
        //         color: Colors.lightBlue,
        //         fontWeight: FontWeight.bold,
        //         fontSize: 15,
        //         letterSpacing: 1),
        //   ),
        // )
      ],
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _image = null;
    super.dispose();
  }

  _signUp() async {
    if (_key.currentState?.validate() ?? false) {
      // await showProgress(context, '少々お待ちください...'.tr(), false);
      // sleep(Duration(seconds: 10));
      // Navigator.pop(context);
      _key.currentState!.save();
      await _signUpWithEmailAndPassword();
    } else {
      setState(() {
        _validate = AutovalidateMode.onUserInteraction;
      });
    }
  }

  _signUpWithEmailAndPassword() async {
    await showProgress(context, 'アカウントを作成中です...'.tr(), false);
    signUpLocation = await getCurrentLocation();
    if (signUpLocation != null) {
      dynamic result = await FireStoreUtils.firebaseSignUpWithEmailAndPassword(
          email!.trim(),
          password!.trim(),
          _image,
          firstName!,
          lastName!,
          signUpLocation!,
          age,
          residence,
          body,
          height);
      await hideProgress();
      if (result != null && result is UserInformation) {
        // 一旦サインインします
        MyAppState.currentUser = result;
        // pushAndRemoveUntil(context, HomeScreen(user: result), false);
        pushAndRemoveUntil(context, EmailCheckScreen(user: result), false);
      } else if (result != null && result is String) {
        showAlertDialog(context, 'Failed'.tr(), result);
      } else {
        showAlertDialog(context, 'Failed'.tr(), 'Couldn\'t sign up'.tr());
      }
    } else {
      await hideProgress();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('位置情報は、あなたが住んでいる地域の人々とマッチングするために必要です。'.tr()),
        duration: Duration(seconds: 5),
      ));
    }
  }
}

//メール確認画面
class EmailCheckScreen extends StatefulWidget {
  final UserInformation user;

  const EmailCheckScreen({Key? key, required this.user}) : super(key: key);
  @override
  _EmailCheckScreenState createState() => _EmailCheckScreenState();
}

class _EmailCheckScreenState extends State<EmailCheckScreen> {
  late UserInformation user;
  void initState() {
    FirebaseAuth.instance.currentUser!.sendEmailVerification();
    user = widget.user;
    super.initState();
  }

  String _sentEmailText = '$email\nに確認メールを送信しました。';
  String _infoText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("メールアドレスの確認",
            style: TextStyle(
                color: Color(COLOR_PRIMARY), fontWeight: FontWeight.w700)),
        backgroundColor: Color(0xffFAFAFA),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_sentEmailText),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(
                right: 40.0,
                left: 40.0,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: double.infinity),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color(COLOR_PRIMARY),
                    padding: EdgeInsets.only(top: 12, bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      side: BorderSide(
                        color: Color(COLOR_PRIMARY),
                      ),
                    ),
                  ),
                  child: Text(
                    'メール確認完了'.tr(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xffFAFAFA),
                    ),
                  ),
                  onPressed: () async {
                    try {
                      UserCredential userCredential = await FirebaseAuth
                          .instance
                          .signInWithEmailAndPassword(
                        email: email!,
                        password: password!,
                      );
                      //中身確認
                      print(userCredential.user?.emailVerified);
                      if (userCredential.user!.emailVerified) {
                        pushAndRemoveUntil(
                            context, imageSceen(user: user), false);
                      } else {
                        setState(() {
                          _infoText =
                              "まだメール確認が完了していません。\n確認メール内のリンクをクリックしてください。";
                        });
                      }
                    } catch (e) {
                      print('NG');
                    }
                  },
                ),
              ),
            ),
            SizedBox(
              height: 25,
            ),
            // 確認メールの再送信ボタン
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 30.0),
              child: ButtonTheme(
                minWidth: 200.0,
                // height: 100.0,
                child: ElevatedButton(
                  // ボタンの形状や背景色など
                  style: ElevatedButton.styleFrom(
                    primary: Colors.grey, // background-color
                    onPrimary: Colors.white, //text-color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  // ボタン内の文字や書式
                  child: Text(
                    '確認メールを再送信',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  onPressed: () async {
                    FirebaseAuth.instance.currentUser!.sendEmailVerification();
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 5.0),
              child: Text(
                _infoText,
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
