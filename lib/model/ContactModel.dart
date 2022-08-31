import 'User.dart';

class ContactModel {
  ContactType type;

  UserInformation user;

  ContactModel({this.type = ContactType.UNKNOWN, user})
      : this.user = user ?? UserInformation();
}

enum ContactType { FRIEND, PENDING, BLOCKED, UNKNOWN, ACCEPT }
