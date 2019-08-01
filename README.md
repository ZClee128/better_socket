# better_socket

A new flutter plugin project.

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.

# ios使用
```OC
import 'package:flutter/material.dart';
import 'package:better_socket/better_socket.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _msg = "";
  @override
  void initState() {
    super.initState();
    // 初始化socket
    BetterSocket.connentSocket("ws://123.207.167.163:9010/ajaxchattest")
        .then((val) {
      //   print(val);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: <Widget>[
            RaisedButton(
              child: Text('发送消息'),
              onPressed: () {
              // 发送消息
                BetterSocket.sendMsg("hello").then((msg) {
                  setState(() {
                    _msg = msg;
                  });
                });
              },
            ),
            Text(_msg)
          ],
        ),
      ),
    );
  }
}
```
＃ Todo
安卓还没有接入
