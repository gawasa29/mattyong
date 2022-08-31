import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dating/Picker/PickerAge.dart';
import 'package:dating/Picker/PickerBody.dart';
import 'package:dating/Picker/PickerFrom.dart';
import 'package:dating/Picker/PickerHeight.dart';
import 'package:dating/constants.dart';
import 'package:dating/main.dart';
import 'package:dating/model/MessageData.dart';
import 'package:dating/model/User.dart';
import 'package:dating/services/FirebaseHelper.dart';
import 'package:dating/services/helper.dart';
import 'package:dating/ui/fullScreenImageViewer/FullScreenImageViewer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../AllSettingScreen.dart';

class ProfileScreen extends StatefulWidget {
  final UserInformation user;

  ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  late UserInformation user;
  FireStoreUtils _fireStoreUtils = FireStoreUtils();
  List images = [];
  List _pages = [];
  List<Widget> _gridPages = [];
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
    _gridPages = _buildGridView();
    return Scaffold(
      backgroundColor: Color(0xffFAFAFA),
      appBar: AppBar(
        title: Text('マイページ',
            style: TextStyle(
                fontSize: 15,
                color: Color(COLOR_PRIMARY),
                fontWeight: FontWeight.w700)),
        automaticallyImplyLeading: false,
        //ちょい透かし
        backgroundColor: Colors.white.withOpacity(0.0),
        elevation: 0,
        actions: <Widget>[
          IconButton(
            color: Color(COLOR_PRIMARY),
            icon: Icon(Icons.settings),
            onPressed: () {
              push(context, AllSettingScreen(user: user));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 16.0, left: 32, right: 32),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: <Widget>[
                    Center(
                        child: displayCircleImage(
                            user.profilePictureURL, 130, false)),
                    Positioned(
                      left: 80,
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
                padding: const EdgeInsets.only(top: 16.0, right: 32, left: 32),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    user.lastName,
                    style: TextStyle(color: Color(COLOR_PRIMARY), fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0, left: 16, right: 16),
                child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'マイギャラリー'.tr(),
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(COLOR_PRIMARY)),
                      ),
                      if (_pages.length >= 2)
                        SmoothPageIndicator(
                          controller: controller,
                          count: _pages.length,
                          effect: ScrollingDotsEffect(
                            activeDotColor: Color(COLOR_ACCENT),
                            dotColor: Colors.grey,
                          ),
                        ),
                    ]),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16, bottom: 8),
                child: SizedBox(
                  height: user.photos.length > 3 ? 260 : 130,
                  width: double.infinity,
                  child: PageView(
                    children: _gridPages,
                    controller: controller,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0, left: 16, right: 16),
                child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'プロフィール'.tr(),
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(COLOR_PRIMARY)),
                      ),
                      if (_pages.length >= 2)
                        SmoothPageIndicator(
                          controller: controller,
                          count: _pages.length,
                          effect: ScrollingDotsEffect(
                            activeDotColor: Color(COLOR_ACCENT),
                            dotColor: Colors.grey,
                          ),
                        ),
                    ]),
              ),
              introAge(user: user),
              Divider(
                height: 0.1,
                thickness: 0.5,
                indent: 1,
                endIndent: 1,
              ),
              introFrom(user: user),
              Divider(
                height: 0.1,
                thickness: 0.5,
                indent: 1,
                endIndent: 1,
              ),
              introBody(user: user),
              Divider(
                height: 0.1,
                thickness: 0.5,
                indent: 1,
                endIndent: 1,
              ),
              introHeight(user: user),
              Divider(
                height: 0.1,
                thickness: 0.5,
                indent: 1,
                endIndent: 1,
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
          child: Text('写真を削除する'.tr()),
          isDestructiveAction: true,
          onPressed: () async {
            Navigator.pop(context);
            showProgress(context, '写真を削除中...'.tr(), false);
            if (user.profilePictureURL.isNotEmpty)
              await _fireStoreUtils.deleteImage(user.profilePictureURL);
            user.profilePictureURL = '';
            await FireStoreUtils.updateCurrentUser(user);
            MyAppState.currentUser = user;
            hideProgress();
            setState(() {});
          },
        ),
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

  Widget _imageBuilder(String? url) {
    bool isLastItem = url == null;

    return GestureDetector(
      onTap: () {
        isLastItem ? _pickImage() : _viewOrDeleteImage(url);
      },
      child: Card(
        shape: RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.circular(20),
        ),
        color: Color(COLOR_PRIMARY),
        child: isLastItem
            ? Icon(
                Icons.collections_outlined,
                size: 50,
                color: Color(0xffFAFAFA),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl:
                      user.profilePictureURL == DEFAULT_AVATAR_URL ? '' : url,
                  placeholder: (context, imageUrl) {
                    return Icon(
                      Icons.hourglass_empty,
                      size: 75,
                      color: Color(COLOR_PRIMARY),
                    );
                  },
                  errorWidget: (context, imageUrl, error) {
                    return Icon(
                      Icons.error_outline,
                      size: 75,
                      color: Color(COLOR_PRIMARY),
                    );
                  },
                ),
              ),
      ),
    );
  }

  List<Widget> _buildGridView() {
    _pages.clear();
    List<Widget> gridViewPages = [];
    var len = images.length;
    var size = 6;
    for (var i = 0; i < len; i += size) {
      var end = (i + size < len) ? i + size : len;
      _pages.add(images.sublist(i, end));
    }
    _pages.forEach((elements) {
      gridViewPages.add(GridView.builder(
          padding: EdgeInsets.only(right: 16, left: 16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10),
          itemBuilder: (context, index) => _imageBuilder(elements[index]),
          itemCount: elements.length,
          physics: BouncingScrollPhysics()));
    });
    return gridViewPages;
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
          child: Text('プロフィール画像の作成 '.tr()),
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
