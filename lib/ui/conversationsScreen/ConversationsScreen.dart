import 'dart:io';

import 'package:dating/constants.dart';
import 'package:dating/model/ConversationModel.dart';
import 'package:dating/model/HomeConversationModel.dart';
import 'package:dating/model/User.dart';
import 'package:dating/services/FirebaseHelper.dart';
import 'package:dating/services/helper.dart';
import 'package:dating/ui/chat/ChatScreen.dart';
import 'package:dating/ui/userDetailsScreen/UserDetailsScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../CustomFlutterTinderCard.dart';

//!チャット画面前のマッチングした人表示する画面

class ConversationsScreen extends StatefulWidget {
  final UserInformation user;

  const ConversationsScreen({Key? key, required this.user}) : super(key: key);

  @override
  State createState() {
    return _ConversationsState();
  }
}

class _ConversationsState extends State<ConversationsScreen> {
  late UserInformation user;
  final fireStoreUtils = FireStoreUtils();
  late Future<List<UserInformation>> _matchesFuture;
  late Future<List<UserInformation>> _likesFuture;
  late Stream<List<HomeConversationModel>> _conversationsStream;
  CardController controller = CardController();
  FireStoreUtils _fireStoreUtils = FireStoreUtils();

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
        title: Text('チャット',
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
            Padding(
              padding: const EdgeInsets.only(
                left: 10,
                bottom: 5,
              ),
              child: Text('マッチしたユーザー',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 100,
              child: FutureBuilder<List<UserInformation>>(
                future: _matchesFuture,
                initialData: [],
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting)
                    return Container(
                      child: Center(
                        child: CircularProgressIndicator.adaptive(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Color(COLOR_ACCENT)),
                        ),
                      ),
                    );
                  if (!snap.hasData || (snap.data?.isEmpty ?? true)) {
                    //!マッチングしてない時に上に表示される
                    return Center(
                      child: Text(
                        '新しくマッチングしましょう！'.tr(),
                        style: TextStyle(fontSize: 15),
                      ),
                    );
                  } else {
                    //!マッチングした人がおる時に上に表示される
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: snap.data!.length,
                      itemBuilder: (BuildContext context, int index) {
                        UserInformation friend = snap.data![index];
                        return fireStoreUtils
                                .validateIfUserBlocked(friend.userID)
                            ? Container(
                                width: 0,
                                height: 0,
                              )
                            : Padding(
                                padding: const EdgeInsets.only(
                                    top: 8.0, left: 4, right: 4),
                                child: InkWell(
                                  onLongPress: () => _onMatchLongPress(friend),
                                  onTap: () async {
                                    String channelID;
                                    if (friend.userID.compareTo(user.userID) <
                                        0) {
                                      channelID = friend.userID + user.userID;
                                    } else {
                                      channelID = user.userID + friend.userID;
                                    }
                                    ConversationModel? conversationModel =
                                        await fireStoreUtils
                                            .getChannelByIdOrNull(channelID);
                                    push(
                                        context,
                                        ChatScreen(
                                            homeConversationModel:
                                                HomeConversationModel(
                                                    isGroupChat: false,
                                                    members: [friend],
                                                    conversationModel:
                                                        conversationModel)));
                                  },
                                  child: Column(
                                    children: <Widget>[
                                      displayCircleImage(
                                          friend.profilePictureURL, 50, false),
                                      Expanded(
                                        child: Container(
                                          width: 75,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 8.0, left: 8, right: 8),
                                            child: Text(
                                              '${friend.lastName}',
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                      },
                    );
                  }
                },
              ),
            ),
            //!ライクしてきた人を表示
            // SizedBox(
            //   height: 100,
            //   child: FutureBuilder<List<UserInformation>>(
            //     future: _likesFuture,
            //     initialData: [],
            //     builder: (context, snapshot) {
            //       if (snapshot.connectionState == ConnectionState.waiting)
            //         return Container(
            //           child: Center(
            //             child: CircularProgressIndicator.adaptive(
            //               valueColor:
            //                   AlwaysStoppedAnimation<Color>(Color(COLOR_ACCENT)),
            //             ),
            //           ),
            //         );
            //       if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
            //         //!マッチングしてない時に上に表示される
            //         return Center(
            //           child: Text(
            //             'いいねきたら表示'.tr(),
            //             style: TextStyle(fontSize: 15),
            //           ),
            //         );
            //       } else {
            //         //!ライクした人がおる時に表示される
            //         return ListView.builder(
            //           scrollDirection: Axis.horizontal,
            //           itemCount: snapshot.data!.length,
            //           itemBuilder: (BuildContext context, int index) {
            //             UserInformation likesuser = snapshot.data![index];
            //             return fireStoreUtils
            //                     .validateIfUserBlocked(likesuser.userID)
            //                 ? Container(
            //                     width: 0,
            //                     height: 0,
            //                   )
            //                 : Padding(
            //                     padding: const EdgeInsets.only(
            //                         top: 8.0, left: 4, right: 4),
            //                     child: InkWell(
            //                       onLongPress: () => _onMatchLongPress(likesuser),
            //                       onTap: () async {
            //                         _launchDetailsScreen(likesuser);
            //                       },
            //                       child: Column(
            //                         children: <Widget>[
            //                           displayCircleImage(
            //                               likesuser.profilePictureURL, 50, false),
            //                           Expanded(
            //                             child: Container(
            //                               width: 75,
            //                               child: Padding(
            //                                 padding: const EdgeInsets.only(
            //                                     top: 8.0, left: 8, right: 8),
            //                                 child: Text(
            //                                   '${likesuser.fullName()}',
            //                                   textAlign: TextAlign.center,
            //                                   maxLines: 1,
            //                                 ),
            //                               ),
            //                             ),
            //                           ),
            //                         ],
            //                       ),
            //                     ),
            //                   );
            //           },
            //         );
            //       }
            //     },
            //   ),
            // ),
            StreamBuilder<List<HomeConversationModel>>(
              stream: _conversationsStream,
              initialData: [],
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    child: Center(
                      child: CircularProgressIndicator.adaptive(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(COLOR_ACCENT)),
                      ),
                    ),
                  );
                } else if (!snapshot.hasData ||
                    (snapshot.data?.isEmpty ?? true)) {
                  return Center(
                    child: Text(
                      'マッチした相手とトークを始めましょう！'.tr(),
                      style: TextStyle(fontSize: 15),
                    ),
                  );
                } else {
                  return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final homeConversationModel = snapshot.data![index];
                        if (homeConversationModel.isGroupChat) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                left: 16.0, right: 16, top: 8, bottom: 8),
                            child: _buildConversationRow(homeConversationModel),
                          );
                        } else {
                          return fireStoreUtils.validateIfUserBlocked(
                                  homeConversationModel.members.first.userID)
                              ? Container(
                                  width: 0,
                                  height: 0,
                                )
                              : Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16.0, right: 16, top: 8, bottom: 8),
                                  child: _buildConversationRow(
                                      homeConversationModel),
                                );
                        }
                      });
                }
              },
            )
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
                              color: Colors.black,
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
                          '${homeConversationModel.members.first.lastName}',
                          style: TextStyle(
                              fontSize: 17,
                              color: Colors.black,
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
      } else {
        await _fireStoreUtils.onSwipeRight(likesuser);
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
