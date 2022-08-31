import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating/Picker/picker_list.dart';
import 'package:dating/model/User.dart';
import 'package:dating/services/helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class introAge extends StatefulWidget {
  late String initialValue;
  final UserInformation user;
  introAge({Key? key, required this.user}) : super(key: key);
  @override
  introduce createState() => introduce(initial: 'null');
}

class introduce extends State<introAge> {
  String m_inputValue = "";
  late UserInformation user;
  var selectedIndex = 0;
  String initial;
  introduce({required this.initial});
  //!現在ログインしているユーザのUIDを変数に代入
  String user_uid = FirebaseAuth.instance.currentUser!.uid;
  void initState() {
    user = widget.user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _introAge();
  }

  String _selectedAge = "年齢";
  String _initialAge = "選択";
  Widget _pickerAge(String str) {
    return Text(
      str,
      style: TextStyle(
        fontSize: 32,
        color: isDarkMode(context) ? Color(0xffFAFAFA) : Color(COLOR_PRIMARY),
      ),
    );
  }

  Widget _introAge() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: EdgeInsets.only(left: 31),
          child: Text("年齢", style: TextStyle(color: Color(COLOR_PRIMARY))),
        ),
        Container(
            child: Row(
          children: [
            Text('${user.age}', style: TextStyle(color: Color(COLOR_PRIMARY))),
            CupertinoButton(
              child: Text("選択"),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      height: MediaQuery.of(context).size.height / 2,
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              CupertinoButton(
                                child: Text("戻る"),
                                onPressed: () => Navigator.pop(context),
                              ),
                              CupertinoButton(
                                child: Text("決定"),
                                onPressed: () async {
                                  _initialAge = _selectedAge;
                                  user.age = _initialAge;
                                  await FirebaseFirestore.instance
                                      .collection(USERS)
                                      .doc(user_uid)
                                      .update(
                                    {
                                      "age": _initialAge,
                                    },
                                  );
                                  Navigator.pop(context);
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height / 3,
                            child: CupertinoPicker(
                              itemExtent: 40,
                              children: ageList.map(_pickerAge).toList(),
                              onSelectedItemChanged: _onSelectedItemChanged_age,
                            ),
                          )
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ))
      ],
    );
  }

  void _onSelectedItemChanged_age(int index) {
    setState(() {
      _selectedAge = ageList[index];
    });
  }
}
