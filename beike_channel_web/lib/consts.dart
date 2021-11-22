const String CHANNEL_DEFAULT_NAME = 'defaultChannel';

// 通道使用的key
const String CHANNEL_KEY_METHOD = 'method';
const String CHANNEL_KEY_ARGS = 'args';

// 真实的通道类型
// Flutter2Web的核心思路是：Dart->JS->Web容器
// 所以通道实际上是JS与Web容器间的通道，实现完全基于Web技术

const String LIANJIA_MESSAGE_CHANNEL = 'lianjia_message_channel';

const String LIANJIA_METHOD_CHANNEL = 'lianjia_method_channel';
const String LIANJIA_CHANNEL_FLUTTER_HANDLER = 'FlutterHandler';
const String LIANJIA_CHANNEL_NATIVE_HANDLER = "NativeHandler";

// 创建通道名称
// 通道名称是Dart(JS)和Web容器互相识别的标识，两端必须一致
String createChannelName(String type, String name) {
  return '${type}_$name';
}

// 创建函数名称
// 函数名称是Dart(JS)和Web容器互相识别的标识，两端必须一致
String packChannelMethod(String channel, String method) {
  return '$channel.$method';
}
