import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating/model/ConversationModel.dart';
import 'package:dating/model/HomeConversationModel.dart';
import 'package:dating/services/FirebaseHelper.dart';
import 'package:dating/services/helper.dart';
import 'package:dating/ui/auth/AuthScreen.dart';
import 'package:dating/ui/chat/ChatScreen.dart';
import 'package:dating/ui/home/HomeScreen.dart';
import 'package:dating/ui/onBoarding/OnBoardingScreen.dart';
import 'package:dating/ui/TutorialScreen.dart';
import 'package:dating/ui/updater.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart' as Constants;
import 'model/User.dart';

//#36393E  54,57,62,100
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  InAppPurchaseAndroidPlatformAddition.enablePendingPurchases();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('ar'), Locale('fr')],
      path: 'assets/translations',
      fallbackLocale: Locale('en'),
      useFallbackTranslations: true,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

//!なんかようわからんけどfirebase Cloud Messagingのやつ
class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  static UserInformation? currentUser;
  late StreamSubscription tokenStream;

  /// this key is used to navigate to the appropriate screen when the
  /// notification is clicked from the system tray
  /// このキーは、システムトレイから通知がクリックされたときに、適切な画面に移動するために使用されます。
  /// システムトレイから通知をクリックすると
  final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey(debugLabel: 'Main Navigator');

  // Set default `_initialized` and `_error` state to false
  // デフォルトの `_initialized` と `_error` の状態を false に設定します。
  bool _initialized = false;
  bool _error = false;

  // Define an async function to initialize FlutterFire
  // FlutterFireを初期化するための非同期関数の定義
  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      // Firebaseが初期化されるのを待ち、`_initialized`の状態をtrueにします。
      RemoteMessage? initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        _handleNotification(initialMessage.data, navigatorKey);
      }
      FirebaseMessaging.onMessageOpenedApp
          .listen((RemoteMessage? remoteMessage) {
        if (remoteMessage != null) {
          _handleNotification(remoteMessage.data, navigatorKey);
        }
      });
      if (!Platform.isIOS) {
        FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);
      }
      tokenStream =
          FireStoreUtils.firebaseMessaging.onTokenRefresh.listen((event) {
        if (currentUser != null) {
          print('token $event');
          currentUser!.fcmToken = event;
          FireStoreUtils.updateCurrentUser(currentUser!);
        }
      });
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      // Set `_error` state to true if Firebase initialization fails
      // Firebaseの初期化に失敗した場合は、`_error`をtrueに設定します。
      setState(() {
        _error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show error message if initialization failed
    // 初期化に失敗した場合、エラーメッセージを表示する
    if (_error) {
      return Container(
        color: Colors.white,
        child: Center(
            child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 25,
            ),
            SizedBox(height: 16),
            Text(
              'Failed to initialise firebase!'.tr(),
              style: TextStyle(color: Colors.red, fontSize: 25),
            ),
          ],
        )),
      );
    }
    // Show a loader until FlutterFire is initialized
    // FlutterFireが初期化されるまでローダを表示する
    if (!_initialized) {
      return Container(
        color: Colors.white,
        child: Center(
          child: CircularProgressIndicator.adaptive(),
        ),
      );
    }
    return MaterialApp(
      navigatorKey: navigatorKey,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      title: 'マッチョングアプリ'.tr(),
      theme: ThemeData(
          bottomSheetTheme: BottomSheetThemeData(
              backgroundColor: Colors.white.withOpacity(.9)),
          accentColor: Color(Constants.COLOR_PRIMARY),
          brightness: Brightness.light),
      debugShowCheckedModeBanner: false,
      color: Color(Constants.COLOR_PRIMARY),
      //ここでOnBoardingクラスを呼び出し
      home: Stack(children: <Widget>[
        OnBoarding(),
        //強制アップデートの仕組み
        Updater(
          appStoreUrl: 'https://testflight.apple.com/join/W8ULJfQh',
          playStoreUrl: 'PlayストアのURL',
        ),
      ]),
    );
  }

  @override
  void initState() {
    initializeFlutterFire();
    WidgetsBinding.instance?.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    tokenStream.cancel();
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (auth.FirebaseAuth.instance.currentUser != null && currentUser != null) {
      if (state == AppLifecycleState.paused) {
        //user offline
        tokenStream.pause();
        currentUser!.active = false;
        currentUser!.lastOnlineTimestamp = Timestamp.now();
        FireStoreUtils.updateCurrentUser(currentUser!);
      } else if (state == AppLifecycleState.resumed) {
        //user online
        tokenStream.resume();
        currentUser!.active = true;
        FireStoreUtils.updateCurrentUser(currentUser!);
      }
    }
  }
}

class OnBoarding extends StatefulWidget {
  @override
  State createState() {
    return OnBoardingState();
  }
}

//ユーザーの状態（アカウントがあるとか）を判断して飛ばすページ変えているクラス
class OnBoardingState extends State<OnBoarding> {
  Future hasFinishedOnBoarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool finishedOnBoarding =
        (prefs.getBool(Constants.FINISHED_ON_BOARDING) ?? false);

    if (finishedOnBoarding) {
      auth.User? firebaseUser = auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        UserInformation? user =
            await FireStoreUtils.getCurrentUser(firebaseUser.uid);
        //!ユーザーがヌルじゃなかったら(ログインしてたら)どの画面に飛ばすか
        if (user != null) {
          user.active = true;
          await FireStoreUtils.updateCurrentUser(user);
          MyAppState.currentUser = user;
          pushReplacement(context, HomeScreen(user: user));
        } else {
          pushReplacement(context, AuthScreen());
        }
      } else {
        pushReplacement(context, AuthScreen());
      }
    } else {
      pushReplacement(context, OnBoardingScreen());
    }
  }

  @override
  void initState() {
    super.initState();
    hasFinishedOnBoarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator.adaptive(
          valueColor: AlwaysStoppedAnimation(Color(Constants.COLOR_PRIMARY)),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}

class OnTutorial extends StatefulWidget {
  @override
  State createState() {
    return OnTutorialState();
  }
}

//ユーザーの状態（アカウントがあるとか）を判断して飛ばすページ変えているクラス
class OnTutorialState extends State<OnTutorial> {
  Future hasFinishedOnBoarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool finishedOnBoarding =
        (prefs.getBool(Constants.FINISHED_ON_BOARDING) ?? false);

    if (finishedOnBoarding) {
      auth.User? firebaseUser = auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        UserInformation? user =
            await FireStoreUtils.getCurrentUser(firebaseUser.uid);
        //!ユーザーがヌルじゃなかったら(ログインしてたら)どの画面に飛ばすか
        if (user != null) {
          user.active = true;
          await FireStoreUtils.updateCurrentUser(user);
          MyAppState.currentUser = user;
          pushReplacement(context, HomeScreen(user: user));
        } else {
          pushReplacement(context, TutorialScreen());
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    hasFinishedOnBoarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator.adaptive(
          valueColor: AlwaysStoppedAnimation(Color(Constants.COLOR_PRIMARY)),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}

/// this faction is called when the notification is clicked from system tray
/// when the app is in the background or completely killed
/// /// このファクションは、システムトレイから通知がクリックされたときに呼び出されます。
/// アプリがバックグラウンドにあるとき、または完全に終了したとき
void _handleNotification(
    Map<String, dynamic> message, GlobalKey<NavigatorState> navigatorKey) {
  /// right now we only handle click actions on chat messages only
  /// 現在は、チャットメッセージに対するクリックアクションのみを処理しています。
  try {
    if (message.containsKey('members') &&
        message.containsKey('isGroup') &&
        message.containsKey('conversationModel')) {
      List<UserInformation> members = List<UserInformation>.from(
          (jsonDecode(message['members']) as List<dynamic>)
              .map((e) => UserInformation.fromPayload(e))).toList();
      bool isGroup = jsonDecode(message['isGroup']);
      ConversationModel conversationModel = ConversationModel.fromPayload(
          jsonDecode(message['conversationModel']));
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            homeConversationModel: HomeConversationModel(
              members: members,
              isGroupChat: isGroup,
              conversationModel: conversationModel,
            ),
          ),
        ),
      );
    }
  } catch (e, s) {
    print('MyAppState._handleNotification $e $s');
  }
}

Future<dynamic> backgroundMessageHandler(RemoteMessage remoteMessage) async {
  await Firebase.initializeApp();
  Map<dynamic, dynamic> message = remoteMessage.data;
  if (message.containsKey('data')) {
    // Handle data message
    print('backgroundMessageHandler message.containsKey(data)');
    final dynamic data = message['data'];
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    // 通知メッセージの処理
    final dynamic notification = message['notification'];
    print('backgroundMessageHandler message.containsKey(notification)');
  }

  // Or do other work.
}
