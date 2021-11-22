//
//  BKWBBridge.h
//  BKWebBrowser
//
//  Created by 李翔宇 on 2020/5/21.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import <WebViewJavascriptBridge/WKWebViewJavascriptBridge.h>
#import "BKWBBridgeTypes.h"
#import "BKWBBridgeConstants.h"

NS_ASSUME_NONNULL_BEGIN

@interface BKWBBridge : NSObject

- (instancetype)initWithWebView:(WKWebView *)webView
                     andMethods:(NSDictionary<NSString *, LJWBBridgeHandler> *)methods;

@property (nonatomic, weak, readonly) WKWebView *webView;

/// 桥接处理器集合 {identifier:handler}
/// 默认继承自LJWBBridgeManager.methods
@property (nonatomic, copy, readonly) NSDictionary<NSString *, LJWBBridgeHandler> *methods;

/// WKWebViewJavascriptBridge对象
@property (nonatomic, strong, readonly) WKWebViewJavascriptBridge *jsBridge;

/// 注册桥接。WebKit和jsBridge同时注册
/// @param handler 回调
/// @param identifier 标识符
- (void)registerHandler:(LJWBBridgeHandler)handler onIdentifier:(NSString *)identifier;

/// 移除桥接。WebKit和jsBridge同时移除
/// @param identifier 标识符
- (void)removeHandlerByIdentifier:(NSString *)identifier;

/// 调用桥接。由容器调用H5，WebKit和jsBridge同时调用
/// @param handlerName 处理器名称
- (void)callHandler:(NSString *)handlerName;

/// 调用桥接。由容器调用H5，WebKit和jsBridge同时调用
/// @param handlerName 处理器名称
/// @param data 数据
- (void)callHandler:(NSString *)handlerName data:(id)data;

/// 调用桥接。由容器调用H5，WebKit和jsBridge同时调用
/// @param handlerName 处理器名称
/// @param data 数据
/// @param callback 回调
- (void)callHandler:(NSString *)handlerName
               data:(id)data
   responseCallback:(WVJBResponseCallback)callback;

@end

NS_ASSUME_NONNULL_END
