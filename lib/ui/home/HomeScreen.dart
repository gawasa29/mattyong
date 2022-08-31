import 'package:dating/constants.dart';
import 'package:dating/main.dart';
import 'package:dating/model/User.dart';
import 'package:dating/services/FirebaseHelper.dart';
import 'package:dating/services/helper.dart';
import 'package:dating/ui/SwipeScreen/SwipeScreen.dart';
import 'package:dating/ui/conversationsScreen/ConversationsScreen.dart';
import 'package:dating/ui/profile/ProfileScreen.dart';
import 'package:dating/ui/TutorialScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../LikesSwipeScreen.dart';

enum DrawerSelection { Conversations, Contacts, Search, Profile }

class HomeScreen extends StatefulWidget {
  final UserInformation user;

  HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  _HomeState createState() {
    return _HomeState();
  }
}

class _HomeState extends State<HomeScreen> {
  late UserInformation user;
  String _appBarTitle = 'Swipe'.tr();
  late Widget _currentWidget;

  @override
  void initState() {
    super.initState();
    if (MyAppState.currentUser!.isVip) {
      checkSubscription();
    }
    user = widget.user;
    _currentWidget = SwipeScreen();
    FireStoreUtils.firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

//!数字で画面きりかえの仕組み
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 0) {
        _appBarTitle = 'Swipe'.tr();
        _currentWidget = SwipeScreen();
      } else if (_selectedIndex == 1) {
        _appBarTitle = 'LikesSwipe'.tr();
        _currentWidget = LikesSwipeScreen(user: user);
      } else if (_selectedIndex == 2) {
        _appBarTitle = 'Conversations'.tr();
        _currentWidget = ConversationsScreen(user: user);
      } else if (_selectedIndex == 3) {
        _appBarTitle = 'Profile'.tr();
        _currentWidget = ProfileScreen(user: user);
      } else {
        print("お前誰やねん");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance!
        .addPostFrameCallback((_) => _showTutorial(context));
    return ChangeNotifierProvider.value(
      value: user,
      child: Consumer<UserInformation>(
        builder: (context, user, _) {
          return Scaffold(
            backgroundColor: Color(0xffFAFAFA),
            body: SafeArea(child: _currentWidget),
            bottomNavigationBar: BottomNavigationBar(
              elevation: 0.0,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_search),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.forum),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: '',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Color(COLOR_PRIMARY),
              unselectedItemColor: Colors.grey[400],
              selectedIconTheme: IconThemeData(size: 40),
              unselectedIconTheme: IconThemeData(size: 30),
              onTap: _onItemTapped,
            ),
          );
        },
      ),
    );
  }

  void checkSubscription() async {
    await showProgress(context, 'Loading...', false);
    await FireStoreUtils.isSubscriptionActive();
    await hideProgress();
  }

  void _showTutorial(BuildContext context) async {
    final pref = await SharedPreferences.getInstance();

    if (pref.getBool('isAlreadyFirstLaunch') != true) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TutorialScreen(),
          fullscreenDialog: true,
        ),
      );
      pref.setBool('isAlreadyFirstLaunch', true);
    }
  }
}
