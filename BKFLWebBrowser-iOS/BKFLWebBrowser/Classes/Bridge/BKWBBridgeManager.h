//
//  LJWBBridgeManager.h
//  LJWebBrowser
//
//  Created by 李翔宇 on 2020/2/13.
//

/**
 LJWBBridgeManager用于实现Web<->Native的通信通道
 */

#import <WebKit/WebKit.h>
#import <WebViewJavascriptBridge/WKWebViewJavascriptBridge.h>
#import "BKWBBridgeTypes.h"
#import "BKWBBridge.h"
#import "BKWebBrowser.h"
#import "BKWBModule.h"

NS_ASSUME_NONNULL_BEGIN

@interface BKWBBridgeManager : BKWBModule

+ (BKWBBridgeManager *)defaultManager;

@property(nonatomic, copy, readonly) NSArray<BKWBBridge *> *bridges;

//桥接方法。@{identifier: handler}
@property(nonatomic, strong, readonly) NSDictionary<NSString *, LJWBBridgeHandler> *methods;

/// 注册通用桥接回调
/// 在Manager中注册的<identifier:handler>默认添加至LJWBBridge对象
/// @param handler 回调
/// @param identifier 标识符
- (void)registerHandler:(LJWBBridgeHandler)handler onIdentifier:(NSString *)identifier;

/// 移除通用桥接回调
/// @param identifier 标识符
- (void)removeHandlerByIdentifier:(NSString *)identifier;

/// 调用通用桥接函数
/// @param handlerName 桥接函数名称
- (void)callHandler:(NSString *)handlerName;

/// 调用通用桥接函数
/// @param handlerName 桥接函数名称
/// @param data 参数
- (void)callHandler:(NSString *)handlerName data:(id)data;

/// 调用通用桥接函数
/// @param handlerName 桥接函数名称
/// @param data 参数
/// @param callback 回调
- (void)callHandler:(NSString *)handlerName
               data:(id)data
   responseCallback:(WVJBResponseCallback)callback;


/// 桥接脚本。用于客户端主动创建JS通道
/// [WebViewJavascriptBridge]: https://github.com/marcuswestin/WebViewJavascriptBridge
@property(nonatomic, strong, readonly) NSString *bridgeSource;

@end

#define BKWBBRIDGE BKWBBridgeManager.defaultManager

NS_ASSUME_NONNULL_END
