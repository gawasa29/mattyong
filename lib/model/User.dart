import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

//!ユーザーの情報入れる
class UserInformation with ChangeNotifier {
  String email;
  //!変数的には苗字やけど氏名の役割（変数全部変えるのんめんどくさかったからそのままにした）
  String firstName;
  //!変数的には名前やけどニックネームの役割（変数全部変えるのんめんどくさかったからそのままにした）
  String lastName;

  UserSettings settings;

  String phoneNumber;

  bool active;

  Timestamp lastOnlineTimestamp;

  String userID;

  String profilePictureURL;

  String appIdentifier = 'マッチョングアプリ ${Platform.operatingSystem}';

  String fcmToken;

  bool isVip;

  //tinder related fields
  UserLocation location;

  UserLocation signUpLocation;

  bool showMe;

  String bio;

  String school;

  String age;

  String residence;

  String body;

  String height;

  List<dynamic> photos;

  //internal use only, don't save to db
  String milesAway = 'km以内';

  bool selected = false;

  UserInformation({
    this.email = '',
    this.userID = '',
    this.profilePictureURL = '',
    this.firstName = '',
    this.phoneNumber = '',
    this.lastName = '',
    this.active = false,
    lastOnlineTimestamp,
    settings,
    this.fcmToken = '',
    this.isVip = false,

    //tinder related fields
    //tinder関連分野
    this.showMe = true,
    UserLocation? location,
    UserLocation? signUpLocation,
    this.school = '',
    this.age = '',
    this.bio = '',
    this.residence = '',
    this.body = '',
    this.height = '',
    this.photos = const [],
  })  : this.lastOnlineTimestamp = lastOnlineTimestamp ?? Timestamp.now(),
        this.settings = settings ?? UserSettings(),
        this.location = location ?? UserLocation(),
        this.signUpLocation = signUpLocation ?? UserLocation();

  String fullName() {
    return '$firstName $lastName';
  }

  factory UserInformation.fromJson(Map<String, dynamic> parsedJson) {
    return UserInformation(
      email: parsedJson['email'] ?? '',
      firstName: parsedJson['firstName'] ?? '',
      lastName: parsedJson['lastName'] ?? '',
      active: parsedJson['active'] ?? false,
      lastOnlineTimestamp: parsedJson['lastOnlineTimestamp'],
      settings: parsedJson.containsKey('settings')
          ? UserSettings.fromJson(parsedJson['settings'])
          : UserSettings(),
      phoneNumber: parsedJson['phoneNumber'] ?? '',
      userID: parsedJson['id'] ?? parsedJson['userID'] ?? '',
      profilePictureURL: parsedJson['profilePictureURL'] ?? '',
      fcmToken: parsedJson['fcmToken'] ?? '',
      isVip: parsedJson['isVip'] ?? false,
      //dating app related fields
      //デートアプリ関連分野
      showMe: parsedJson['showMe'] ?? parsedJson['showMeOnTinder'] ?? true,
      location: parsedJson.containsKey('location')
          ? UserLocation.fromJson(parsedJson['location'])
          : UserLocation(),
      signUpLocation: parsedJson.containsKey('signUpLocation')
          ? UserLocation.fromJson(parsedJson['signUpLocation'])
          : UserLocation(),
      school: parsedJson['school'] ?? 'N/A',
      age: parsedJson['age'] ?? '',
      bio: parsedJson['bio'] ?? 'N/A',
      photos: parsedJson['photos'] ?? [].cast<String>(),
      residence: parsedJson['residence'] ?? '',
      body: parsedJson['body'] ?? '',
      height: parsedJson['height'] ?? '',
    );
  }

  factory UserInformation.fromPayload(Map<String, dynamic> parsedJson) {
    return UserInformation(
      email: parsedJson['email'] ?? '',
      firstName: parsedJson['firstName'] ?? '',
      lastName: parsedJson['lastName'] ?? '',
      active: parsedJson['active'] ?? false,
      lastOnlineTimestamp: Timestamp.fromMillisecondsSinceEpoch(
          parsedJson['lastOnlineTimestamp']),
      settings: parsedJson.containsKey('settings')
          ? UserSettings.fromJson(parsedJson['settings'])
          : UserSettings(),
      phoneNumber: parsedJson['phoneNumber'] ?? '',
      userID: parsedJson['id'] ?? parsedJson['userID'] ?? '',
      profilePictureURL: parsedJson['profilePictureURL'] ?? '',
      fcmToken: parsedJson['fcmToken'] ?? '',
      location: parsedJson.containsKey('location')
          ? UserLocation.fromJson(parsedJson['location'])
          : UserLocation(),
      signUpLocation: parsedJson.containsKey('signUpLocation')
          ? UserLocation.fromJson(parsedJson['signUpLocation'])
          : UserLocation(),
      school: parsedJson['school'] ?? 'N/A',
      age: parsedJson['age'] ?? '',
      bio: parsedJson['bio'] ?? 'N/A',
      isVip: parsedJson['isVip'] ?? false,
      showMe: parsedJson['showMe'] ?? parsedJson['showMeOnTinder'] ?? true,
      photos: parsedJson['photos'] ?? [].cast<String>(),
      residence: parsedJson['residence'] ?? '',
      body: parsedJson['residence'] ?? '',
      height: parsedJson['residence'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    photos.toList().removeWhere((element) => element == null);
    return {
      'email': this.email,
      'firstName': this.firstName,
      'lastName': this.lastName,
      'settings': this.settings.toJson(),
      'phoneNumber': this.phoneNumber,
      'id': this.userID,
      'active': this.active,
      'lastOnlineTimestamp': this.lastOnlineTimestamp,
      'profilePictureURL': this.profilePictureURL,
      'appIdentifier': this.appIdentifier,
      'fcmToken': this.fcmToken,
      'isVip': this.isVip,

      //tinder related fields
      'showMe': this.settings.showMe,
      'location': this.location.toJson(),
      'signUpLocation': this.signUpLocation.toJson(),
      'bio': this.bio,
      'school': this.school,
      'age': this.age,
      'photos': this.photos,
      'residence': this.residence,
      'body': this.body,
      'height': this.height,
    };
  }

  Map<String, dynamic> toPayload() {
    photos.toList().removeWhere((element) => element == null);
    return {
      'email': this.email,
      'firstName': this.firstName,
      'lastName': this.lastName,
      'settings': this.settings.toJson(),
      'phoneNumber': this.phoneNumber,
      'id': this.userID,
      'active': this.active,
      'lastOnlineTimestamp': this.lastOnlineTimestamp.millisecondsSinceEpoch,
      'profilePictureURL': this.profilePictureURL,
      'appIdentifier': this.appIdentifier,
      'fcmToken': this.fcmToken,
      'location': this.location.toJson(),
      'signUpLocation': this.signUpLocation.toJson(),
      'showMe': this.settings.showMe,
      'bio': this.bio,
      'school': this.school,
      'age': this.age,
      'isVip': this.isVip,
      'photos': this.photos,
      'residence': this.residence,
      'body': this.body,
      'height': this.height,
    };
  }
}

class UserSettings {
  bool pushNewMessages;

  bool pushNewMatchesEnabled;

  bool pushSuperLikesEnabled;

  bool pushTopPicksEnabled;

  String genderPreference; // should be either 'Male' or 'Female' // or 'All'

  String gender; // should be either 'Male' or 'Female'

  String distanceRadius;

  bool showMe;

  UserSettings({
    this.pushNewMessages = true,
    this.pushNewMatchesEnabled = true,
    this.pushSuperLikesEnabled = true,
    this.pushTopPicksEnabled = true,
    this.genderPreference = 'All',
    this.gender = 'Male',
    this.distanceRadius = '32',
    this.showMe = true,
  });

  factory UserSettings.fromJson(Map<dynamic, dynamic> parsedJson) {
    return UserSettings(
      pushNewMessages: parsedJson['pushNewMessages'] ?? true,
      pushNewMatchesEnabled: parsedJson['pushNewMatchesEnabled'] ?? true,
      pushSuperLikesEnabled: parsedJson['pushSuperLikesEnabled'] ?? true,
      pushTopPicksEnabled: parsedJson['pushTopPicksEnabled'] ?? true,
      genderPreference: parsedJson['genderPreference'] ?? 'All',
      gender: parsedJson['gender'] ?? 'Male',
      distanceRadius: parsedJson['distanceRadius'] ?? '32',
      showMe: parsedJson['showMe'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pushNewMessages': this.pushNewMessages,
      'pushNewMatchesEnabled': this.pushNewMatchesEnabled,
      'pushSuperLikesEnabled': this.pushSuperLikesEnabled,
      'pushTopPicksEnabled': this.pushTopPicksEnabled,
      'genderPreference': this.genderPreference,
      'gender': this.gender,
      'distanceRadius': this.distanceRadius,
      'showMe': this.showMe
    };
  }
}

class UserLocation {
  double latitude;

  double longitude;

  UserLocation({this.latitude = 00.1, this.longitude = 00.1});

  factory UserLocation.fromJson(Map<dynamic, dynamic>? parsedJson) {
    return UserLocation(
      latitude: parsedJson?['latitude'] ?? 00.1,
      longitude: parsedJson?['longitude'] ?? 00.1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': this.latitude,
      'longitude': this.longitude,
    };
  }
}
