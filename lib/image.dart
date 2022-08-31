import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dating/constants.dart';
import 'package:dating/grender.dart';
import 'package:dating/main.dart';
import 'package:dating/model/MessageData.dart';
import 'package:dating/model/User.dart';
import 'package:dating/services/FirebaseHelper.dart';
import 'package:dating/services/helper.dart';
import 'package:dating/ui/TermsofuseScreen.dart';
import 'package:dating/ui/fullScreenImageViewer/FullScreenImageViewer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

class imageSceen extends StatefulWidget {
  final UserInformation user;

  imageSceen({Key? key, required this.user}) : super(key: key);

  @override
  _imageSceenState createState() => _imageSceenState();
}

class _imageSceenState extends State<imageSceen> {
  final ImagePicker _imagePicker = ImagePicker();
  late UserInformation user;
  FireStoreUtils _fireStoreUtils = FireStoreUtils();
  var images = [];
  PageController controller = PageController();

  @override
  void initState() {
    user = widget.user;
    images.clear();
    images.addAll(user.photos);
    if (images.isNotEmpty) {
      if (images[images.length - 1] != null) {
        images.add(null);
      }
    } else {
      images.add(null);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFAFAFA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        //ちょい透かし
        backgroundColor: Colors.white.withOpacity(0.0),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 16.0, right: 16, bottom: 16),
                    child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          '自分の顔写真を入れてください'.tr(),
                          style: TextStyle(
                              color: Color(COLOR_PRIMARY),
                              fontWeight: FontWeight.bold,
                              fontSize: 23.0),
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16.0, top: 16, right: 8, bottom: 8),
                    child: Column(
                      children: [
                        Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              '男性の場合は筋肉と顔が見える写真を設定してください。'.tr(),
                              style: TextStyle(
                                  color: Color(COLOR_PRIMARY), fontSize: 14.0),
                            ))
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0, left: 32, right: 32),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: <Widget>[
                    Center(
                        child: displayCircleImage(
                            user.profilePictureURL, 170, false)),
                    Positioned(
                      left: 100,
                      right: 0,
                      child: FloatingActionButton(
                          heroTag: 'pickImage',
                          backgroundColor: Color(COLOR_ACCENT),
                          child: Icon(
                            Icons.camera_alt,
                            color: Color(0xffFAFAFA),
                          ),
                          mini: true,
                          onPressed: _onCameraClick),
                    )
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(right: 40.0, left: 40.0, top: 40.0),
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
                    onPressed: () async {
                      UserInformation? updateUser =
                          await FireStoreUtils.updateCurrentUser(user);
                      hideProgress();
                      if (updateUser != null) {
                        pushReplacement(context, genderscreen(user: user));
                        this.user = updateUser;
                        MyAppState.currentUser = user;
                      }
                    },
                    child: Text('次へ'.tr(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xffFAFAFA),
                        )),
                  ),
                ),
              ),
            ]),
      ),
    );
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
          onPressed: () async {
            Navigator.pop(context);
            XFile? image =
                await _imagePicker.pickImage(source: ImageSource.gallery);
            if (image != null) {
              await _imagePicked(File(image.path));
            }
            setState(() {});
          },
        ),
        CupertinoActionSheetAction(
          child: Text('カメラで撮影'.tr()),
          onPressed: () async {
            Navigator.pop(context);
            XFile? image =
                await _imagePicker.pickImage(source: ImageSource.camera);
            if (image != null) {
              await _imagePicked(File(image.path));
            }
            setState(() {});
          },
        ),
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

  Future<void> _imagePicked(File image) async {
    // showProgress(context, 'Uploading image...'.tr(), false);
    showProgress(context, ' 少々お持ちください...'.tr(), false);
    user.profilePictureURL =
        await FireStoreUtils.uploadUserImageToFireStorage(image, user.userID);
    await FireStoreUtils.updateCurrentUser(user);
    MyAppState.currentUser = user;
    hideProgress();
  }

  _viewOrDeleteImage(String url) {
    final action = CupertinoActionSheet(
      actions: <Widget>[
        CupertinoActionSheetAction(
          onPressed: () async {
            Navigator.pop(context);
            images.removeLast();
            images.remove(url);
            await _fireStoreUtils.deleteImage(url);
            user.photos = images;
            UserInformation? newUser =
                await FireStoreUtils.updateCurrentUser(user);
            MyAppState.currentUser = newUser;
            if (newUser != null) {
              user = newUser;
              images.add(null);
              setState(() {});
            }
          },
          child: Text('写真を削除する'.tr()),
          isDestructiveAction: true,
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            push(context, FullScreenImageViewer(imageUrl: url));
          },
          isDefaultAction: true,
          child: Text('写真を見る'.tr()),
        ),
        CupertinoActionSheetAction(
          onPressed: () async {
            Navigator.pop(context);
            user.profilePictureURL = url;
            dynamic result = await FireStoreUtils.updateCurrentUser(user);
            if (result != null) {
              user = result;
            }
            setState(() {});
          },
          isDefaultAction: true,
          child: Text('プロフィール画像の選択 '.tr()),
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

  _pickImage() {
    final action = CupertinoActionSheet(
      message: Text(
        '写真を追加'.tr(),
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
            if (image != null) {
              Url imageUrl = await _fireStoreUtils.uploadChatImageToFireStorage(
                  File(image.path), context);
              images.removeLast();
              images.add(imageUrl.url);
              user.photos = images;
              UserInformation? newUser =
                  await FireStoreUtils.updateCurrentUser(user);
              if (newUser != null) {
                MyAppState.currentUser = newUser;
                user = newUser;
              }
              images.add(null);
              setState(() {});
            }
          },
        ),
        CupertinoActionSheetAction(
          child: Text('カメラで撮影'.tr()),
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image =
                await _imagePicker.pickImage(source: ImageSource.camera);
            if (image != null) {
              Url imageUrl = await _fireStoreUtils.uploadChatImageToFireStorage(
                  File(image.path), context);
              images.removeLast();
              images.add(imageUrl.url);
              user.photos = images;
              UserInformation? newUser =
                  await FireStoreUtils.updateCurrentUser(user);
              if (newUser != null) {
                MyAppState.currentUser = newUser;
                user = newUser;
              }
              images.add(null);
              setState(() {});
            }
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

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
