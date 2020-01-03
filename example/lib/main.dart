import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:better_socket/better_socket.dart';
// import 'dart:convert' show utf8;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await BetterSocket.platformVersion;

      //设置监听
      BetterSocket.addListener(onOpen: (httpStatus, httpStatusMessage) {
        print("onOpen---httpStatus:$httpStatus  httpStatusMessage:$httpStatusMessage");
        
        
        // BetterSocket.sendMsg('hello');
      }, onMessage: (message) {
        print("onMessage---message:$message");
      }, onClose: (code, reason, remote) {
        print("onClose---code:$code  reason:$reason  remote:$remote");
      }, onError: (message) {
        print("onError---message:$message");
      });
      var headers = {"origin": "ws://echo.websocket.org"};

      BetterSocket.connentSocket("ws://echo.websocket.org", httpHeaders: headers);
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: FlatButton(
            onPressed: (){
              BetterSocket.sendByteMsg(Utf8Encoder().convert('hello'));
            },
            child: Text('Running on: $_platformVersion\n'),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    BetterSocket.close();
    super.dispose();
  }
}
