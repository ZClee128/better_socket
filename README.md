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

# Use
```dart
import 'package:flutter/material.dart';
import 'package:better_socket/better_socket.dart';
import 'dart:convert';

class WebSocketRoute extends StatefulWidget {
  @override
  _WebSocketRouteState createState() => new _WebSocketRouteState();
}

class _WebSocketRouteState extends State<WebSocketRoute> {
  TextEditingController _controller = new TextEditingController();
  // IOWebSocketChannel channel;
  String _text = "";

  @override
  void initState() {
    //创建websocket连接
    var headers = {"origin": "ws://echo.websocket.org"};
    //trustAllHost 为true 是通过所有认证
    BetterSocket.connentSocket("ws://echo.websocket.org", httpHeaders: headers, trustAllHost: true);
    BetterSocket.addListener(onOpen: (httpStatus, httpStatusMessage) {
      print(
          "onOpen---httpStatus:$httpStatus  httpStatusMessage:$httpStatusMessage");
    }, onMessage: (message) {
      setState(() {
        _text = message;
      });
      print("onMessage---message:$message");
    }, onClose: (code, reason, remote) {
      print("onClose---code:$code  reason:$reason  remote:$remote");
    }, onError: (message) {
      print("onError---message:$message");
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("WebSocket(内容回显)"),
      ),
      body: new Padding(
        padding: const EdgeInsets.all(20.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Form(
              child: new TextFormField(
                controller: _controller,
                decoration: new InputDecoration(labelText: 'Send a message'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: new Text(_text),
            ),
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _sendMessage,
        tooltip: 'Send message',
        child: new Icon(Icons.send),
      ),
    );
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      <!-- 这个发送字符串 -->
      BetterSocket.sendMsg(_controller.text);
      <!-- 这个是发送byte[] -->
      BetterSocket.sendByteMsg(Utf8Encoder().convert('hello'));
    }
  }

  @override
  void dispose() {
    BetterSocket.close();
    super.dispose();
  }
}
```
