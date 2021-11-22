//
//  LJWBFlutterManager.m
//  LJWebBrowser
//
//  Created by 李翔宇 on 2020/2/13.
//

#import "BKWBFlutterManager.h"
#import "BKWBCache.h"
#import "BKWBScript.h"
#import "BKWBBridgeManager.h"
#import "BKWBFlutterConstants.h"

@interface BKWBFlutterManager ()

@property(nonatomic, strong) NSMutableDictionary<NSString *, BKWBFlutterMethodChannel *> *methodChannelsM;
@property(nonatomic, strong) NSMutableDictionary<NSString *, BKWBFlutterMessageChannel *> *messageChannelsM;

@end

static BKWBFlutterManager *defaultManager = nil;

@implementation BKWBFlutterManager

+ (BKWBFlutterManager *)defaultManager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultManager = [[BKWBFlutterManager alloc] init];
        
        defaultManager.methodChannelsM = [NSMutableDictionary dictionary];
        defaultManager.messageChannelsM = [NSMutableDictionary dictionary];
    });
    
    return defaultManager;
}

#pragma mark - Method Channel

- (NSDictionary<NSString *, BKWBFlutterMethodChannel *> *)methodChannels {
    return [_methodChannelsM copy];
}

- (void)registerMethodChannel:(BKWBFlutterMethodChannel *)channel {
    _methodChannelsM[channel.name] = channel;
}

- (void)registerMethodChannelWithName:(NSString *)name {
    BKWBFlutterMethodChannel *channel = [[BKWBFlutterMethodChannel alloc] initWithName:name];
    [self registerMethodChannel:channel];
}

#pragma mark - Message Channel

- (NSDictionary<NSString *, BKWBFlutterMessageChannel *> *)messageChannels {
    return [_messageChannelsM copy];
}

- (void)registerMessageChannel:(BKWBFlutterMessageChannel *)channel {
    _messageChannelsM[channel.name] = channel;
}

- (void)registerMessageChannelWithName:(NSString *)name {
    BKWBFlutterMessageChannel *channel = [[BKWBFlutterMessageChannel alloc] initWithName:name];
    [self registerMessageChannel:channel];
}

#pragma mark - Private Method

//flutter环境变量
- (NSString *)_contextSource {
    return [BKWBScript sourceFromResource:@"flutter_context" inSubspec:@"Flutter"];
}

//channel脚本
- (NSString *)_baseChannelSource {
    return [BKWBScript sourceFromResource:@"flutter_channel_specific" inSubspec:@"Flutter"];
}

//channel脚本
- (NSString *)_methodChannelSource {
    return [BKWBScript sourceFromResource:@"flutter_method_channel_specific" inSubspec:@"Flutter"];
}

//channel脚本
- (NSString *)_messageChannelSource {
    return [BKWBScript sourceFromResource:@"flutter_message_channel_specific" inSubspec:@"Flutter"];
}

//dart2js fix脚本
- (NSString *)_dart2jsFixSource {
    return [BKWBScript sourceFromResource:@"dart2js_fix" inSubspec:@"Flutter"];
}

#pragma mark - WKWebBrowserModuleProtocol

- (void)ljwb_addedToBrowser:(BKWebBrowser *)browser {
    
    //在browser关联的webView中执行脚本
    [browser evaluateJavaScript:[self _contextSource] completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        if(error) {
            NSLog(@"Failed load js %@", [self _contextSource]);
        }
    }];
    
    [browser evaluateJavaScript:[self _baseChannelSource] completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        if(error) {
            NSLog(@"Failed load js %@", [self _baseChannelSource]);
        }
    }];
    
    [browser evaluateJavaScript:[self _methodChannelSource] completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        if(error) {
            NSLog(@"Failed load js %@", [self _methodChannelSource]);
        }
    }];

    //在browser关联的configuration中注册脚本
    WKUserScript *keyScript = [BKWBScript scriptFromSource:[self _contextSource]];
    [browser.configurationManager registerScript:keyScript];
    
    WKUserScript *baseChannelScript = [BKWBScript scriptFromSource:[self _baseChannelSource]];
    [browser.configurationManager registerScript:baseChannelScript];
    
    WKUserScript *methodChannelScript = [BKWBScript scriptFromSource:[self _methodChannelSource]];
    [browser.configurationManager registerScript:methodChannelScript];
    
    WKUserScript *messageChannelScript = [BKWBScript scriptFromSource:[self _messageChannelSource]];
    [browser.configurationManager registerScript:messageChannelScript];
    
    //同步channel
    [_methodChannelsM enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull name, BKWBFlutterMethodChannel * _Nonnull channel, BOOL * _Nonnull stop) {
        if(![channel respondsToSelector:@selector(ljwb_addedToBrowser:)]) {
            return;
        }
        
        [channel ljwb_addedToBrowser:browser];
    }];
    
//    [_messageChannelsM enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull name, LJWBFlutterMessageChannel * _Nonnull channel, BOOL * _Nonnull stop) {
//        if(![channel respondsToSelector:@selector(ljwb_addedToBrowser:)]) {
//            return;
//        }
//        
//        [channel ljwb_addedToBrowser:browser];
//    }];
}

- (void)ljwb_addedModule:(id<WKWebBrowserModuleProtocol>)module toBrowser:(BKWebBrowser *)browser {

    //同步channel
    [_methodChannelsM enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull name, BKWBFlutterMethodChannel * _Nonnull channel, BOOL * _Nonnull stop) {
        if(![channel respondsToSelector:@selector(ljwb_addedModule:toBrowser:)]) {
            return;
        }
        
        [channel ljwb_addedModule:module toBrowser:browser];
    }];
    
    [_messageChannelsM enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull name, BKWBFlutterMessageChannel * _Nonnull channel, BOOL * _Nonnull stop) {
        if(![channel respondsToSelector:@selector(ljwb_addedToBrowser:)]) {
            return;
        }
        
        [channel ljwb_addedModule:module toBrowser:browser];
    }];
}


@end
