import 'package:dating/constants.dart';
import 'package:dating/services/helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFAFAFA),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     String url = 'tel:12345678';
      //     launch(url);
      //   },
      //   backgroundColor: Color(COLOR_ACCENT),
      //   child: Icon(
      //     Icons.call,
      //     color: isDarkMode(context) ? Colors.black : Colors.white,
      //   ),
      // ),
      appBar: AppBar(
        backgroundColor: Color(0xffFAFAFA),
        iconTheme: IconThemeData(color: Color(COLOR_PRIMARY)),
        elevation: 0.0,
        title: Text('お問い合わせ',
            style: TextStyle(
                fontSize: 15,
                color: Color(COLOR_PRIMARY),
                fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: Column(children: <Widget>[
        Material(
            elevation: 2,
            color: Colors.white,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 16.0, left: 16, top: 16),
                    child: Text(
                      '株式会社チューリング'.tr(),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        right: 16.0, left: 16, top: 16, bottom: 16),
                    child: Text('大阪府磯上町5丁目18番2号'),
                  ),
                  ListTile(
                    onTap: () async {
                      var url = 'sagawa@turings.jp';
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        showAlertDialog(context, 'Couldn\'t send email'.tr(),
                            'There is no mailing app installed'.tr());
                      }
                    },
                    title: Text(
                      'メールでのお問い合わせ'.tr(),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding:
                          EdgeInsets.only(right: 16.0, top: 16, bottom: 16),
                      child: Text('sagawa@turings.jp'),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.black54,
                    ),
                  )
                ]))
      ]),
    );
  }
}
