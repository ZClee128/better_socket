import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';

class BetterSocket {
  static const MethodChannel _channel = const MethodChannel('better_socket');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static connentSocket(String path,
      {Map<String, String> httpHeaders,
      bool trustAllHost,
      String keyStorePath,
      String keyPassword,
      String storePassword,
      String keyStoreType}) {
    _channel.invokeMethod('connentSocket', {
      'path': path,
      "httpHeaders": httpHeaders,
      "keyStorePath": keyStorePath,
      "trustAllHost": trustAllHost,
      "keyPassword": keyPassword,
      "storePassword": storePassword,
      "keyStoreType": keyStoreType
    });
  }

  static sendMsg(String msg) {
    _channel.invokeMethod('sendMsg', <String, String>{'msg': msg});
  }

  static sendByteMsg(Uint8List msg) {
    _channel.invokeMethod('sendByteMsg', <String, Uint8List>{'msg': msg});
  }

  static close() {
    _channel.invokeMethod('close');
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
