import 'dart:async';

import 'package:flutter/services.dart';

class BetterSocket {
  static const MethodChannel _channel = const MethodChannel('better_socket');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<bool> connentSocket(String path) async {
    //TODO 这块写得有问题。连接socket是异步的。同步等待结果不合理
    final bool ok = await _channel.invokeMethod('connentSocket', <String, String>{'path': path});
    return ok;
  }

  static Future<void> sendMsg(String msg) async {
    await _channel.invokeMethod('sendMsg', <String, String>{'msg': msg});
  }

  static void addListener(
      {Function onOpen, Function onMessage, Function onError, Function onClose}) {
    EventChannel eventChannel = EventChannel("better_socket/event");
    eventChannel.receiveBroadcastStream().listen((data) {
      print(data);
      var event = data["event"];
      if ("onOpen" == event) {
        if (onOpen != null) {
          var httpStatus = data["httpStatus"];
          var httpStatusMessage = data["httpStatusMessage"];
          onOpen(httpStatus, httpStatusMessage);
        }
      } else if ("onClose" == event) {
        if (onClose != null) {
          var code = data["code"];
          var reason = data["reason"];
          var remote = data["remote"];
          onClose(code, reason, remote);
        }
      } else if ("onMessage" == event) {
        if (onMessage != null) {
          var message = data["message"];
          onMessage(message);
        }
      } else if ("onError" == event) {
        if (onError != null) {
          var message = data["message"];
          onError(message);
        }
      }
    });
  }
}
