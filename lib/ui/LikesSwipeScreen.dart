import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating/constants.dart';
import 'package:dating/model/HomeConversationModel.dart';
import 'package:dating/model/User.dart';
import 'package:dating/services/FirebaseHelper.dart';
import 'package:dating/services/helper.dart';
import 'package:dating/ui/chat/ChatScreen.dart';
import 'package:dating/ui/home/HomeScreen.dart';
import 'package:dating/ui/userDetailsScreen/UserDetailsScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../CustomFlutterTinderCard.dart';
import '../maScreen.dart';

//!チャット画面前のマッチングした人表示する画面

class LikesSwipeScreen extends StatefulWidget {
  final UserInformation user;

  const LikesSwipeScreen({Key? key, required this.user}) : super(key: key);

  @override
  State createState() {
    return _ConversationsState();
  }
}

class _ConversationsState extends State<LikesSwipeScreen> {
  late UserInformation user;
  final fireStoreUtils = FireStoreUtils();
  late Future<List<UserInformation>> _matchesFuture;
  late Future<List<UserInformation>> _likesFuture;
  late Stream<List<HomeConversationModel>> _conversationsStream;
  CardController controller = CardController();
  FireStoreUtils _fireStoreUtils = FireStoreUtils();
  late HomeConversationModel homeConversationModel;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    fireStoreUtils.getBlocks().listen((shouldRefresh) {
      if (shouldRefresh) {
        setState(() {});
      }
    });
    _likesFuture = fireStoreUtils.getlikeUserObject(user.userID);
    _matchesFuture = fireStoreUtils.getMatchedUserObject(user.userID);
    _conversationsStream = fireStoreUtils.getConversations(user.userID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFAFAFA),
      appBar: AppBar(
        title: Text('相手からのいいね',
            style: TextStyle(
                fontSize: 15,
                color: Color(COLOR_PRIMARY),
                fontWeight: FontWeight.w700)),
        backgroundColor: Color(0xffFAFAFA),
        elevation: 0,
      ),
      body: Container(
        child: ListView(
          children: <Widget>[
            //!ライクしてきた人を表示
            SizedBox(
              height: 690,
              child: FutureBuilder<List<UserInformation>>(
                future: _likesFuture,
                initialData: [],
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return Container(
                      child: Center(
                        child: CircularProgressIndicator.adaptive(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Color(COLOR_ACCENT)),
                        ),
                      ),
                    );
                  if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
                    //!マッチングしてない時に上に表示される
                    return Center(
                      child: Text(
                        'いいねがきたら表示されます'.tr(),
                        style: TextStyle(fontSize: 15),
                      ),
                    );
                  } else {
                    //!ライクした人がおる時に表示される
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (BuildContext context, int index) {
                        UserInformation likesuser = snapshot.data![index];
                        return fireStoreUtils
                                    .validateIfUserBlocked(likesuser.userID) ||
                                fireStoreUtils.getMatcheliks(likesuser.userID)
                            ? Container(
                                width: 0,
                                height: 0,
                              )
                            : Padding(
                                padding: const EdgeInsets.only(
                                    top: 5, bottom: 5, left: 20, right: 20),
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: InkWell(
                                      onLongPress: () =>
                                          _onMatchLongPress(likesuser),
                                      onTap: () async {
                                        _launchDetailsScreen(likesuser);
                                      },
                                      child: Row(
                                        children: <Widget>[
                                          displayCircleImage(
                                              likesuser.profilePictureURL,
                                              80,
                                              false),
                                          Container(
                                            width: 100,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0, left: 8, right: 8),
                                              child: Text(
                                                '${likesuser.lastName}, ${likesuser.age}',
                                                style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight:
                                                        FontWeight.w500),
                                                textAlign: TextAlign.center,
                                                maxLines: 1,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 8.0, left: 80, right: 8),
                                            child: Icon(
                                              Icons.arrow_forward_ios_outlined,
                                              size: 35.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationRow(HomeConversationModel homeConversationModel) {
    String user1Image = '';
    String user2Image = '';
    if (homeConversationModel.members.length >= 2) {
      user1Image = homeConversationModel.members.first.profilePictureURL;
      user2Image = homeConversationModel.members.elementAt(1).profilePictureURL;
    }
    return homeConversationModel.isGroupChat
        ? Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 12.8),
            child: InkWell(
              onTap: () {
                push(context,
                    ChatScreen(homeConversationModel: homeConversationModel));
              },
              child: Row(
                children: <Widget>[
                  Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      displayCircleImage(user1Image, 44, false),
                      Positioned(
                          left: -16,
                          bottom: -12.8,
                          child: displayCircleImage(user2Image, 44, true))
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 8, right: 8, left: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '${homeConversationModel.conversationModel!.name}',
                            style: TextStyle(
                              fontSize: 17,
                              color: Color(COLOR_PRIMARY),
                              fontFamily: Platform.isIOS ? 'sanFran' : 'Roboto',
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              '${homeConversationModel.conversationModel!.lastMessage} • ${formatTimestamp(homeConversationModel.conversationModel!.lastMessageDate.seconds)}',
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: 14, color: Color(0xffACACAC)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        : InkWell(
            onTap: () {
              push(context,
                  ChatScreen(homeConversationModel: homeConversationModel));
            },
            child: Row(
              children: <Widget>[
                Stack(
                  alignment: Alignment.bottomRight,
                  children: <Widget>[
                    displayCircleImage(
                        homeConversationModel.members.first.profilePictureURL,
                        60,
                        false),
                    Positioned(
                        right: 2.4,
                        bottom: 2.4,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                              color: homeConversationModel.members.first.active
                                  ? Colors.green
                                  : Colors.grey,
                              borderRadius: BorderRadius.circular(100),
                              border:
                                  Border.all(color: Colors.white, width: 1.6)),
                        ))
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, right: 8, left: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '${homeConversationModel.members.first.fullName()}',
                          style: TextStyle(
                              fontSize: 17,
                              color: Color(COLOR_PRIMARY),
                              fontFamily:
                                  Platform.isIOS ? 'sanFran' : 'Roboto'),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            '${homeConversationModel.conversationModel?.lastMessage} • ${formatTimestamp(homeConversationModel.conversationModel?.lastMessageDate.seconds ?? 0)}',
                            maxLines: 1,
                            style: TextStyle(
                                fontSize: 14, color: Color(0xffACACAC)),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
  }

  _showAlertDialog(BuildContext context, String title, String message) {
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> _launchDetailsScreen(UserInformation likesuser) async {
    CardSwipeOrientation? result = await Navigator.of(context).push(
      //!swipeせず画像をタッチするとUserDetailsScreenに飛ぶ。相手の情報が載っている画面
      MaterialPageRoute(
        builder: (context) => UserDetailsScreen(
          user: likesuser,
          isMatch: false,
        ),
      ),
    );
    //!DetailsScreenでスワイプした時に表示される
    if (result != null) {
      if (result == CardSwipeOrientation.LEFT) {
        await _fireStoreUtils.onSwipeLeft(likesuser);
        bool isSuccessful = await _fireStoreUtils.blockUser(likesuser, 'block');
        if (isSuccessful) {
          Navigator.pop(context);
          push(context, HomeScreen(user: user));
        }
      } else {
        await _fireStoreUtils.onSwipeRight(likesuser);
        push(context, MaScreen(likesuser: likesuser));
      }
    }
  }

  _onMatchLongPress(UserInformation likesuser) {
    final action = CupertinoActionSheet(
      message: Text(
        likesuser.fullName(),
        style: TextStyle(fontSize: 15.0),
      ),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text('View Profile'.tr()),
          isDefaultAction: true,
          onPressed: () async {
            Navigator.pop(context);
            push(
                context,
                UserDetailsScreen(
                  user: likesuser,
                  isMatch: true,
                ));
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text(
          'Cancel'.tr(),
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }
}
