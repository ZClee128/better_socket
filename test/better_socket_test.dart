import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:better_socket/better_socket.dart';

void main() {
  const MethodChannel channel = MethodChannel('better_socket');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await BetterSocket.platformVersion, '42');
  });
}
