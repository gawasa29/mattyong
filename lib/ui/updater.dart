import 'dart:io';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:url_launcher/url_launcher.dart';

/// 強制アップデートダイアログを被せる為のStatefulWidget
class Updater extends StatefulWidget {
  Updater({Key? key, required this.appStoreUrl, required this.playStoreUrl})
      : super(key: key);
  final String appStoreUrl;
  final String playStoreUrl;
  @override
  State<Updater> createState() => _UpdaterState(
      appStoreUrl: this.appStoreUrl, playStoreUrl: this.playStoreUrl);
}

class _UpdaterState extends State<Updater> {
  _UpdaterState({required this.appStoreUrl, required this.playStoreUrl});
  final String appStoreUrl;
  final String playStoreUrl;

  @override
  void initState() {
    _shouldUpdate().then((needUpdate) => _showUpdateDialog(needUpdate));
    super.initState();
  }

  @override
  //!最新バージョンはここ通る
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1,
    );
  }

  /// 更新版案内ダイアログを表示
  void _showUpdateDialog(bool needUpdate) {
    if (!needUpdate) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final title = "アップデートのお知らせ";
        final message = "各種パフォーマンスの改善および新機能を追加しました。最新バージョンへのアップデートをお願いします。";
        final btnLabel = "アップデート";
        // iOS, Androidによって表示するダイアログを切り替える
        return Platform.isIOS
            ? new CupertinoAlertDialog(
                title: Text(title),
                content: Text(message),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                      btnLabel,
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: () => _launchURL(appStoreUrl),
                  ),
                ],
              )
            : new WillPopScope(
                child: new AlertDialog(
                  title: Text(title),
                  content: Text(message),
                  actions: <Widget>[
                    TextButton(
                      child: Text(
                        btnLabel,
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () => _launchURL(playStoreUrl),
                    ),
                  ],
                ),
                onWillPop: () async => false,
              );
      },
    );
  }

  /// App Store or Gogle Play Storeのリンクを立ち上げる
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<bool> _shouldUpdate() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final appVersionStr = packageInfo.version;
    // 現在のアプリのバージョンを取得
    final appVersion = Version.parse(appVersionStr);

    // remoteConfigの初期化
    final RemoteConfig remoteConfig = await RemoteConfig.instance;

    // RemoteConfigから値を取ってこれなかった場合のフォールバック
    final defaultValues = <String, dynamic>{
      'android_required_semver': appVersionStr,
      'ios_required_semver': appVersionStr
    };
    await remoteConfig.setDefaults(defaultValues);
    await remoteConfig.fetchAndActivate();

    final remoteConfigAppVersionKey =
        Platform.isIOS ? 'ios_required_semver' : 'android_required_semver';
    final requiredVersion =
        Version.parse(remoteConfig.getString(remoteConfigAppVersionKey));
    return appVersion.compareTo(requiredVersion).isNegative;
  }
}
