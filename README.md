# BKFlutterWebNativeBridge

BKFlutterWebNativeBridge建立了flutter web页面和native的通道，在贝壳找房[Flutter for Web容灾降级](https://mp.weixin.qq.com/s/zIeU0z-4P5Pd9THVybnDFQ)项目中得到了运用。


<img src="https://mmbiz.qpic.cn/mmbiz_png/Rcon9f6LyEuwzxib2ibnJ1VmpCymJUQc8GlIlo22ZJxe6QLTMzQxZHLGHcXbKJqH09efN0ABKzUGnKXdQfrMvkCg/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1" width="80%">

如上图，BKFlutterWebNativeBridge运用了Flutter、iOS、Android三端的AOP技术，将FlutterChannels中的方法进行hook，然后通过JS桥接技术将web和native的调用打通。

本项目包括以下几部分
- 通道的dart代码，lianjia_channel_web。
- 通道的native代码，BKFLWebBrowser。
- 示例代码，DEMO。

# 如何使用
我们以DEMO代码为例
## 1. 本项目中会使用到Beike_AspectD,具体集成方式请参考Beike_AspectD的README。
## 2. 在Flutter项目中添加以下依赖:

```dart
 beike_aspectd:
    path: ../beike_aspectd

  lianjia_device_info_plugin:
      path: ../lianjia_channel_web/lianjia_device_info_plugin

  flutter_navigator_plugin:
      path: ../lianjia_channel_web/flutter_navigator_plugin

  lianjia_channel_web:
      path: ../lianjia_channel_web
```

## 3. 在main.dart中添加依赖
DEMO中main-local.dart是项目flutter native的入口，main-web.dart是项目flutter web的入口。在main-local.dart和main-web.dart中添加如下依赖

```dart
import 'package:flutter_navigator_plugin/flutter_navigator_plugin.dart';
import 'package:lianjia_device_info_plugin/lianjia_device_info_plugin.dart';
```
在main-web.dart中添加如下依赖

```dart
import 'package:lianjia_channel_web/hook/hook.dart';
```
## 4. Dart初始化
在main-web.dart中进行初始化
```dart
LianjiaDeviceInfoPlugin.initPlugin();
```
## 5. Web包编译及部署
通过build web指令将flutter项目编译成web包并将编译产物部署到服务端。
```shell
flutter build web --target=lib/main-web.dart 
```
## 6. iOS中加载Flutter Web产物
首先在iOS工程中pod中添加如下依赖
```dart
pod 'BKFLWebBrowser', :path => '../../BKFLWebBrowser-iOS', :subspecs => ['Flutter2Web']
```
然后通过如下方式创建webview并展示即可

```C
vc.webView = [[BKWBFlutter2WebManager sharedInstance] createWebViewPackageHost:@"http://yourhost" url:@"path/#/"];
```
#支持版本
BKFlutterWebNativeBridge支持Flutter 1.22.4和2.2.2

# TODO
目前仅支持MethodChannel，其他channel还未支持。
