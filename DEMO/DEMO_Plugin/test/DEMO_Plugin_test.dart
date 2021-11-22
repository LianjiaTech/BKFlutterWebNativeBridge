import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:DEMO_Plugin/DEMO_Plugin.dart';

void main() {
  const MethodChannel channel = MethodChannel('DEMO_Plugin');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await DEMOPlugin.platformVersion, '42');
  });
}
