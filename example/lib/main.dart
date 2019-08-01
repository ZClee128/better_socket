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
    BetterSocket.connentSocket("ws://123.207.167.163:9010/ajaxchattest")
        .then((val) {
      //   print(val);
      //   BetterSocket.sendMsg("hello");
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

  @override
  void dispose() {
    BetterSocket.close();
    super.dispose();
  }
}
