//
//  BKWBFlutterConstants.h
//  BKWebBrowser
//
//  Created by 李翔宇 on 2020/6/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const LJWB_FLUTTER_CHANNEL_TYPE_METHOD_CHANNEL;
extern NSString * const LJWB_FLUTTER_CHANNEL_TYPE_MESSAGE_CHANNEL;
extern NSString * const LJWB_FLUTTER_CHANNEL_TYPE_EVENT_CHANNEL;

extern NSString * const LJWB_FLUTTER_CHANNEL_FLUTTER_HANDLER;
extern NSString * const LJWB_FLUTTER_CHANNEL_NATIVE_HANDLER;

static inline NSString *ljwbflutter_createChannelName(NSString *type, NSString *name) {
    return [NSString stringWithFormat:@"%@_%@", type, name];
}

static inline NSString *ljwbflutter_packMethod(NSString *channel, NSString *method) {
    return [NSString stringWithFormat:@"%@.%@", channel, method];
}

static inline NSString *ljwbflutter_unpackMethod(NSString *channel_method) {
    NSArray<NSString *> *comps = [channel_method componentsSeparatedByString:@"."];
    return comps.lastObject;
}

/// 判断flutter是否在项目中
static inline BOOL ljwbflutter_isFlutterExist() {
    Class FlutterMethodChannelClass = NSClassFromString(@"FlutterMethodChannel");
    if(!FlutterMethodChannelClass) {
        return NO;
    }
    return YES;
}

NS_ASSUME_NONNULL_END
