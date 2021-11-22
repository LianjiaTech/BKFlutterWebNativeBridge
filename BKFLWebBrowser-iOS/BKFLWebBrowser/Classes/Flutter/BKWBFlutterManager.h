//
//  LJWBFlutterManager.h
//  LJWebBrowser
//
//  Created by 李翔宇 on 2020/2/13.
//

/**
 LJWBFlutterManager是Flutter容器的管理器对象，主要用于向Flutter(JS)提供相关的Context以及Channel
 创建Channel时，原则上需要LJWBBridgeManager和LJWBPromiseManager提前注入Browser
 但是时序要求总是不合理的，所以LJWBFlutterManager实现延迟创建和加载
 */
#import "BKWBModule.h"
#import "BKWBFlutterMessageChannel.h"
#import "BKWBFlutterMethodChannel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol LJWBFlutterManagerDelegate;

@interface BKWBFlutterManager : BKWBModule

/// 绝对单例
+ (BKWBFlutterManager *)defaultManager;

/// 是否确定为flutter
@property (atomic, assign, getter=isConfirmed, readonly) BOOL confirm;

/// 函数通道
@property (nonatomic, copy, readonly) NSDictionary<NSString *, BKWBFlutterMethodChannel *> *methodChannels;

/// 消息通道
@property (nonatomic, copy, readonly) NSDictionary<NSString *, BKWBFlutterMessageChannel *> *messageChannels;

/// 注册函数通道
/// @param channel 函数通道
- (void)registerMethodChannel:(BKWBFlutterMethodChannel *)channel;

/// 注册函数通道。自动创建函数通道
/// @param name 函数通道名称
- (void)registerMethodChannelWithName:(NSString *)name;

/// 注册消息通道
/// @param channel 消息通道
- (void)registerMessageChannel:(BKWBFlutterMessageChannel *)channel;

/// 注册消息通道。自动创建消息通道
/// @param name 消息通道名称
- (void)registerMessageChannelWithName:(NSString *)name;

@end

#define BKWBFLUTTER BKWBFlutterManager.defaultManager

NS_ASSUME_NONNULL_END
