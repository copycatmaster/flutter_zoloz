import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_zoloz/flutter_zoloz.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    FlutterZoloz.init();
  }

  // Platform messages are asynchronous, so we initialize in an async method.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body:Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FlatButton(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      // side: BorderSide(
                      //   color: Colors.black12,
                      // ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onPressed: () {
                      FlutterZoloz.startAuthWithConfig({

                      }, (token, result, resultCode, resultMsg, callId) {
                            print("token!!" + token.toString());
                            print("result!!" + result.toString());
                            print("resultCode!!" + resultCode.toString());
                            print("resultMsg!!" + resultMsg.toString());
                            print("callId!!" + callId.toString());
                          });
                    },
                    child: Text("开始"),
                  )
                ])),
      ),
    );
  }
}
