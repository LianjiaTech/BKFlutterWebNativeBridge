//
//  LJWBFlutterMessageChannel.h
//  LJWebBrowser
//
//  Created by 李翔宇 on 2020/6/11.
//

#import <Foundation/Foundation.h>
//#import <Flutter/FlutterChannels.h>
#import "FlutterChannels.h"
#import "BKWBFlutterTypes.h"
#import "BKWebBrowser.h"

NS_ASSUME_NONNULL_BEGIN

@interface BKWBFlutterMessageChannel : NSObject<WKWebBrowserModuleProtocol>

- (instancetype)initWithName:(NSString *)name;

/// 通道名称
@property (nonatomic, copy, readonly) NSString *name;

/// 处理器集合
@property (nonatomic, copy, readonly) NSArray<LJWBFlutterMessageHandler> *handlers;

/// 注册消息回调
/// @param handler 回调
- (void)registerHandler:(LJWBFlutterMessageHandler)handler;

/// 移除消息回调
/// @param handler 回调
- (void)cancelHandler:(LJWBFlutterMessageHandler)handler;

#pragma mark - 桥接

/// 向Flutter发送消息
/// @param message 消息
- (void)sendMessage:(id _Nullable)message;

/// 向Flutter发送消息
/// @param message 消息
/// @param callback 回调
- (void)sendMessage:(id _Nullable)message reply:(FlutterReply _Nullable)callback;

/// 注册Flutter消息回调
/// @param handler 回调
- (void)setMessageHandler:(FlutterMessageHandler _Nullable)handler;

@end

NS_ASSUME_NONNULL_END
