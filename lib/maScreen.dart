import 'package:cached_network_image/cached_network_image.dart';
import 'package:dating/constants.dart';
import 'package:dating/main.dart';
import 'package:dating/model/ConversationModel.dart';
import 'package:dating/model/HomeConversationModel.dart';
import 'package:dating/model/User.dart';
import 'package:dating/services/FirebaseHelper.dart';
import 'package:dating/services/helper.dart';
import 'package:dating/ui/chat/ChatScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//!likeswipeScreenでマッチングした場合の画面（引数でlikesuserが必要なため）
class MaScreen extends StatefulWidget {
  final UserInformation likesuser;

  MaScreen({Key? key, required this.likesuser}) : super(key: key);

  @override
  _MaScreenState createState() => _MaScreenState();
}

class _MaScreenState extends State<MaScreen> {
  final FireStoreUtils _fireStoreUtils = FireStoreUtils();

  @override
  void dispose() {
    //!ステータスバーの非表示？
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return Material(
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          //!CachedNetworkImageプラグインの何か
          CachedNetworkImage(
            imageUrl: widget.likesuser.profilePictureURL,
            errorWidget: (context, url, error) => Image.network(
              //!constants.dartファイルの
              DEFAULT_AVATAR_URL,
              fit: BoxFit.cover,
            ),
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: Column(
              verticalDirection: VerticalDirection.up,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      SystemChrome.setEnabledSystemUIOverlays(
                          [SystemUiOverlay.bottom, SystemUiOverlay.top]);
                      Navigator.pop(context);
                    },
                    child: Text(
                      '戻る'.tr(),
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 24),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 24),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            side: BorderSide.none),
                        primary: Color(COLOR_PRIMARY),
                      ),
                      child: Text(
                        'メッセージを送る'.tr(),
                        style: TextStyle(fontSize: 17, color: Colors.white),
                      ),
                      onPressed: () async {
                        String channelID;
                        if (widget.likesuser.userID
                                .compareTo(MyAppState.currentUser!.userID) <
                            0) {
                          channelID = widget.likesuser.userID +
                              MyAppState.currentUser!.userID;
                        } else {
                          channelID = MyAppState.currentUser!.userID +
                              widget.likesuser.userID;
                        }
                        ConversationModel? conversationModel =
                            await _fireStoreUtils
                                .getChannelByIdOrNull(channelID);
                        //!チャットスクリーンに一方通行に飛ぶ
                        pushReplacement(
                          context,
                          ChatScreen(
                            homeConversationModel: HomeConversationModel(
                                isGroupChat: false,
                                members: [widget.likesuser],
                                conversationModel: conversationModel),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 60.0, horizontal: 16),
                  child: Text(
                    'マッチョング成立!'.tr(),
                    style: TextStyle(
                      letterSpacing: 4,
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
