import 'package:beike_aspectd/aspectd.dart';
import 'package:flutter/services.dart' as ser;
import '../method_channel.dart' as ljChannel;

Expando<ljChannel.MethodChannel> methodChannelExpando =
    new Expando<ljChannel.MethodChannel>();

ljChannel.MethodChannel attachedChannel(ser.MethodChannel channel) {
  ljChannel.MethodChannel attachChannel = methodChannelExpando[channel];

  if (attachChannel != null) {
    return attachChannel;
  }

  ljChannel.MethodChannel newChannel =
      ljChannel.MethodChannel(name: channel.name);

  methodChannelExpando[channel] = newChannel;

  print(methodChannelExpando[channel]);

  return newChannel;
}

@Aspect()
@pragma("vm:entry-point")
class HookMethodChannel extends ser.MethodChannel {
  HookMethodChannel(String name) : super(name);

  @Inject("package:flutter/src/services/platform_channel.dart", "MethodChannel",
      "-invokeMapMethod",
      lineNum: 358)
  @pragma("vm:entry-point")
  dynamic injectInvokeMapMethod(PointCut pointCut) async {
    String method; //Aspectd Ignore
    dynamic arguments; //Aspectd Ignore

    if (this.name.contains('/') == false) {
      if (method == null) {
        return null;
      }

      ljChannel.MethodChannel channel = attachedChannel(this);

      return channel.invokeMethod(method, arguments);
    }

    return;
  }

  @Inject("package:flutter/src/services/platform_channel.dart", "MethodChannel",
      "-invokeListMethod",
      lineNum: 344)
  @pragma("vm:entry-point")
  dynamic injectInvokeListMethod(PointCut pointCut) async {
    String method; //Aspectd Ignore
    dynamic arguments; //Aspectd Ignore

    if (this.name.contains('/') == false) {
      if (method == null) {
        return null;
      }

      ljChannel.MethodChannel channel = attachedChannel(this);

      return channel.invokeMethod(method, arguments);
    }

    return;
  }

//  @Inject("package:flutter/src/services/platform_channel.dart", "MethodChannel",
//      "-invokeMethod",
//      lineNum: 334)
//  @pragma("vm:entry-point")
//  dynamic injectInvokeMethod() {
//    String method; //Aspectd Ignore
//    dynamic arguments; //Aspectd Ignore
//
//    if (this.name.contains('/') == false) {
//      if (method == null) {
//        return null;
//      }
//
//      ljChannel.MethodChannel channel = attachedChannel(this);
//
//      return channel.invokeMethod(method, arguments);
//    }
//  }
//
  @Inject("package:flutter/src/services/platform_channel.dart", "MethodChannel",
      "-_invokeMethod",
      lineNum: 147)
  @pragma("vm:entry-point")
  dynamic _injectInvokeMethod() async {
    String method; //Aspectd Ignore
    dynamic arguments; //Aspectd Ignore

    if (this.name.contains('/') == false) {
      if (method == null) {
        return null;
      }

      ljChannel.MethodChannel channel = attachedChannel(this);
      return await channel.invokeMethod(method, arguments);
    }
  }

 @Inject("package:flutter/src/services/platform_channel.dart", "MethodChannel",
     "-setMethodCallHandler",
     lineNum: 377)
 @pragma("vm:entry-point")
 void setMethodCallHandlerMethod() {

   Future<dynamic> Function(ser.MethodCall call) handler; //Aspectd Ignore

   if (this.name.contains('/') == false) {

     ljChannel.MethodChannel channel = attachedChannel(this);
     channel.setMethodCallHandler(handler);

     return;
   }
 }
}
