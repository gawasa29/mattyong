import 'ConversationModel.dart';
import 'User.dart';

class HomeConversationModel {
  bool isGroupChat;

  List<UserInformation> members;

  ConversationModel? conversationModel;

  HomeConversationModel(
      {this.isGroupChat = false,
      this.members = const [],
      this.conversationModel});
}
