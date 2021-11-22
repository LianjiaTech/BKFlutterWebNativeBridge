// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:js/js.dart' as js;
import 'package:js/js_util.dart' as js_util;
import 'package:flutter/services.dart' as ORIGIN;
import 'dart:convert' as convert;
import 'consts.dart';

typedef void ChannelCallHandlerWrapper(
    String method, dynamic args, String type, String callbackName);
//typedef void ChannelCallHandlerWrapper(String method, dynamic args, String type, Function callback);

class MethodChannel {
  static const String _prefix = '[Lianjia][Web][MethodChannel]';

  final String name;
  String _channelName;
  var _channel;

  MethodChannel({this.name});

  /*
  * 获取渠道名称(发送)
  * */
  String get channelName {
    if (_channelName != null) {
      return _channelName;
    }

    if (this.name != null) {
      _channelName = createChannelName(LIANJIA_METHOD_CHANNEL, this.name);
    } else {
      _channelName = LIANJIA_METHOD_CHANNEL;
    }
    return _channelName;
  }

  dynamic get channel {
    if (_channel != null) {
      return _channel;
    }

    bool hasChannel = js_util.hasProperty(window, channelName);
    if (hasChannel) {
      print('[$_prefix][$name] 找到channel: $channelName');
    } else {
      print('[$_prefix][$name] 未找到channel: $channelName');
      dynamic channel = js_util.newObject();
      js_util.setProperty(window, channelName, channel);
    }

    _channel = js_util.getProperty(window, channelName);
    return _channel;
  }

  //使用Promise实现异步通信，Promise构造器绑定在channel上
  Future<T> invokeMethod<T>(String method, [dynamic args]) async {
    bool hasHandler =
        js_util.hasProperty(channel, LIANJIA_CHANNEL_NATIVE_HANDLER);
    if (hasHandler) {
      print('[$_prefix][$name] 找到handler');
    } else {
      print('[$_prefix][$name] 未找到handler');
      return null;
    }

    dynamic _args = args;
    String type = 'undefined';
    if (args is Map || args is List) {
      _args = convert.json.encode(args);
      type = 'object';
    } else if (args is num) {
      type = 'number';
    } else if (args is bool) {
      type = 'boolean';
    } else if (args is String) {
      type = 'string';
    } else {
      _args = args.toString();
    }

    print('[$_prefix][$name] _args: $_args');
    print('[$_prefix][$name] type: $type');

    dynamic promise = js_util.callMethod(
        channel, LIANJIA_CHANNEL_NATIVE_HANDLER, [method, _args, type]);
    print('[$_prefix][$name] promise: $promise');

    if (promise == null) {
      print('[$_prefix][$name] promise is null');
      return null;
    }

    Future<T> future = js_util.promiseToFuture<T>(promise);
    print('[$_prefix][$name] future: $future');

    dynamic ret = await future;

    Map retMap = convert.jsonDecode(ret as String);

    String retType = retMap['type'];
    dynamic obj = retMap['obj'];

    if(retType == 'map' || retType == 'list') {
      dynamic jsonObj = convert.jsonDecode(obj);
      return jsonObj;
    } else {
      return obj;
    }
  }

  Future<List<T>> invokeListMethod<T>(String method, [dynamic args]) async {
    final List<dynamic> result =
        await invokeMethod<List<dynamic>>(method, args);
    return result?.cast<T>();
  }

  Future<Map<K, V>> invokeMapMethod<K, V>(String method, [dynamic args]) async {
    final Map<dynamic, dynamic> result =
        await invokeMethod<Map<dynamic, dynamic>>(method, args);
    return result?.cast<K, V>();
  }

  void setMethodCallHandler(Future<dynamic> Function(ORIGIN.MethodCall call) handler) {
    if (handler == null) {
      print('[$_prefix][$name] 移除callHandler');
      js_util.setProperty(channel, LIANJIA_CHANNEL_FLUTTER_HANDLER, null);
      return;
    }

    bool hasHandler =
        js_util.hasProperty(channel, LIANJIA_CHANNEL_FLUTTER_HANDLER);
    if (hasHandler) {
      print('[$_prefix][$name] 替换callHandler');
    } else {
      print('[$_prefix][$name] 创建callHandler');
    }

    //在通道中设置入口函数
    ChannelCallHandlerWrapper handlerWrapper =
        (String method, dynamic args, String type, String callbackName) {
      print('[$_prefix][$name] 调用handler');
      print('[$_prefix][$name] method: $method');
      print('[$_prefix][$name] args: $args');
      print('[$_prefix][$name] type: $type');
      print('[$_prefix][$name] callbackName: $callbackName');

      dynamic object;

      if (args is String) {
        if (type == 'object') {
          object = convert.json.decode(args);
        } else if (type == 'image') {
          Uint8List bytes = convert.base64Decode(args);
          object = Image.memory(bytes);
        } else if (type == 'data') {
          object = convert.base64Decode(args);
        } else {
          object = args;
        }
      } else {
        object = args;
      }

      ORIGIN.MethodCall call = ORIGIN.MethodCall(method, object);
      handler(call).then((dynamic result) {
        print('[$_prefix][$name] 回调callback');
        js_util.callMethod(channel, callbackName, [result]);
      });
    };
    js_util.setProperty(channel, LIANJIA_CHANNEL_FLUTTER_HANDLER,
        js.allowInterop(handlerWrapper));

    //激活通道
    js_util.callMethod(window, 'lianjia_method_channel_register_by_flutter',
        [channelName, LIANJIA_CHANNEL_FLUTTER_HANDLER]);
  }
}
