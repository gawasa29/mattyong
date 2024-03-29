import 'package:dating/constants.dart';
import 'package:dating/services/helper.dart';
import 'package:dating/ui/auth/AuthScreen.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingScreen extends StatefulWidget {
  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  PageController pageController = PageController();

  ///list of strings containing onBoarding titles
  ///onBoardingのタイトルを含む文字列のリスト
  final List<String> _titlesList = [
    'マッチョと出逢おう！'.tr(),
    'メッセージでやりとりをしましょう！'.tr(),
    '写真や動画も送ることができます！'.tr(),
  ];

  /// list of strings containing onBoarding subtitles, the small text under the
  /// title
  /// onBoardingの字幕を含む文字列のリスト、タイトルの下の小さなテキスト
  /// タイトル
  final List<String> _subtitlesList = [
    '自分の気になる人を右にスワイプして、マッチしましょう！'.tr(),
    'チャットでやりとりをして、仲良くなりましょう！'.tr(),
    '写真や動画などを送り合ってより仲良くなることができます！'.tr(),
  ];

  /// list containing image paths or IconData representing the image of each page
  /// 各ページの画像のパスまたは画像を表すIconDataを含むリスト
  final List<dynamic> _imageList = [
    'assets/images/mattyo2.png',
    Icons.chat_bubble_outline,
    Icons.photo_camera,
  ];

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(COLOR_PRIMARY),
      body: Stack(
        children: <Widget>[
          PageView.builder(
            itemBuilder: (context, index) => getPage(
                _imageList[index],
                _titlesList[index],
                _subtitlesList[index],
                context,
                index + 1 == _titlesList.length),
            controller: pageController,
            itemCount: _titlesList.length,
            onPageChanged: (int index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          Visibility(
            visible: _currentIndex + 1 == _titlesList.length,
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Directionality.of(context) == TextDirection.ltr
                      ? Alignment.bottomRight
                      : Alignment.bottomLeft,
                  child: OutlinedButton(
                    onPressed: () {
                      setFinishedOnBoarding();
                      pushReplacement(context, AuthScreen());
                    },
                    child: Text(
                      '次へ'.tr(),
                      style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white),
                        shape: StadiumBorder()),
                  ),
                )),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SmoothPageIndicator(
                controller: pageController,
                count: _titlesList.length,
                effect: ScrollingDotsEffect(
                    activeDotColor: Colors.white,
                    dotColor: Colors.grey.shade400,
                    dotWidth: 8,
                    dotHeight: 8,
                    fixedCenter: true),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget getPage(dynamic image, String title, String subTitle,
      BuildContext context, bool isLastPage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        image is String
            ? Image.asset(
                image,
                color: Colors.white,
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              )
            : Icon(
                image as IconData,
                color: Colors.white,
                size: 150,
              ),
        SizedBox(height: 40),
        Text(
          title.toUpperCase(),
          style: TextStyle(
              color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            subTitle,
            style: TextStyle(color: Colors.white, fontSize: 14.0),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Future<bool> setFinishedOnBoarding() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(FINISHED_ON_BOARDING, true);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
