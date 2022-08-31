/*
 * Copyright (c) 2020 tokku5552
 *
 * This software is released under the MIT License.
 * https://opensource.org/licenses/mit-license.php
 *
 */
import 'package:dating/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overboard/flutter_overboard.dart';

class TutorialScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OverBoard(
        buttonColor: Color(COLOR_PRIMARY),
        pages: pages,
        showBullets: true,
        skipCallback: () {
          // when user select SKIP
          Navigator.pop(context);
        },
        finishCallback: () {
          // when user select NEXT
          Navigator.pop(context);
        },
      ),
    );
  }

  final pages = [
    PageModel.withChild(
        child: Padding(
            padding: EdgeInsets.only(bottom: 25.0),
            child: Text(
              "スワイプ画面について",
              style: TextStyle(
                color: Color(COLOR_PRIMARY),
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            )),
        doAnimateChild: true,
        color: null),
    PageModel.withChild(
        child: Padding(
            padding: EdgeInsets.only(bottom: 25.0),
            child: Image.asset(
              'assets/images/Tutorial.png',
            )),
        color: const Color(0xffFAFAFA),
        doAnimateChild: true),
    PageModel.withChild(
        child: Padding(
            padding: EdgeInsets.only(bottom: 25.0),
            child: Text(
              "さぁ、始めましょう！",
              style: TextStyle(
                color: Color(COLOR_PRIMARY),
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            )),
        color: const Color(0xffFAFAFA),
        doAnimateChild: true),
  ];
}
