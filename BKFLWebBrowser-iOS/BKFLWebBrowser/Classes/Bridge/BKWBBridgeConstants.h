//
//  BKWBBridgeConstants.h
//  LJWebBrowser
//
//  Created by 李翔宇 on 2020/6/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//通用桥接名
extern NSString * const LJWBBridgeHybrid;

//如果没有传递回调函数，那么就使用WKScriptMessage.name+LJWBBridgeCallbackSuffix作为回调函数名称
extern NSString * const LJWBBridgeCallbackSuffix;
static inline NSString *LJWBBridgeCallbackName(NSString *method) {
    return [NSString stringWithFormat:@"window.%@.%@%@", LJWBBridgeHybrid, method, LJWBBridgeCallbackSuffix];
}

//参数
extern NSString * const LJWBBridgeHybridArgsKey;
//回调
extern NSString * const LJWBBridgeHybridCallbackKey;

//通配标识
extern NSString * const LJWBBridgeWildcardIdentifier;

NS_ASSUME_NONNULL_END
