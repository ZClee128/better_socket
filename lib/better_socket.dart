import 'dart:async';

import 'package:flutter/services.dart';

class BetterSocket {
  static const MethodChannel _channel =
      const MethodChannel('better_socket');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<void> connentSocket(String path) async {
    await _channel.invokeListMethod('connentSocket',<String, String>{'path': path});
  }
}
