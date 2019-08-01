import 'dart:async';

import 'package:flutter/services.dart';

class BetterSocket {
  static const MethodChannel _channel =
      const MethodChannel('better_socket');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<bool> connentSocket(String path) async {
    final bool ok = await _channel.invokeMethod('connentSocket',<String, String>{'path': path});
    return ok;
  }

  static Future<String> sendMsg(String msg) async {
    final String str = await _channel.invokeMethod('sendMsg',<String,String>{'msg': msg});
    return str;
  }

  static Future<bool> close() async {
    final bool ok = await _channel.invokeMethod('close');
    return ok;
  }
}
