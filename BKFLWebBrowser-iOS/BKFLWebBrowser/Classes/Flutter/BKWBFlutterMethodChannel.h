//
//  LJWBFlutterMethodChannel.h
//  LJWebBrowser
//
//  Created by 李翔宇 on 2020/6/11.
//

/**
 Flutter函数通道
 
 Flutter2Native通过dart2native转换为平台aot代码，通过MethodChannel与Native通信
 Flutter2Web通过dart2js转换为JS，此时Flutter<->Native过程转换为JS<->Native过程
 
 支持功能：
 
 1. 创建函数通道
     1) 通道名称隐式转换(用于避免JS上下文冲突)
     2) 创建promise通道
 
 2. 显示注册函数处理器
     1) 函数名称隐式转换(用于避免JS上下文冲突)
     2) 添加bridge名称和回调
 
 3. 隐式桥接Flutter2Native中已有实现
     1) hook FlutterMethodChannel的setMethodCallHandler函数
     2) 持有handler(joint)
     3) [显示注册函数处理器]
 
 */

#import <Foundation/Foundation.h>
//#import <Flutter/FlutterChannels.h>
#import "FlutterChannels.h"
#import "BKWBFlutterTypes.h"
#import "BKWebBrowser.h"

NS_ASSUME_NONNULL_BEGIN

@class BKWBFlutterManager;
@interface BKWBFlutterMethodChannel : NSObject<WKWebBrowserModuleProtocol>

- (instancetype)initWithName:(NSString *)name;

/// 通道名称
@property (nonatomic, copy, readonly) NSString *name;

/// 方法集合。@{methodName: handler}
@property (nonatomic, copy, readonly) NSDictionary<NSString *, LJWBFlutterMethodHandler> *methods;

/// 注册通道回调
/// @param handler 回调
/// @param method 函数名
- (void)registerHandler:(LJWBFlutterMethodHandler)handler forMethod:(NSString *)method;

/// 移除通道回调
/// @param method 函数名
- (void)cancelHandlerByMethod:(NSString *)method;

#pragma mark - 桥接

/// 调用Flutter函数
/// @param method 函数名称
/// @param arguments 参数
- (void)invokeMethod:(NSString *)method arguments:(id _Nullable)arguments;

/// 调用Flutter函数
/// @param method 函数名称
/// @param arguments 参数
/// @param callback 回调
- (void)invokeMethod:(NSString *)method
           arguments:(id _Nullable)arguments
              result:(FlutterResult _Nullable)callback;

/// 注册Flutter函数回调
/// @param handler 回调
- (void)setMethodCallHandler:(FlutterMethodCallHandler)handler;

@end

NS_ASSUME_NONNULL_END
