//
//  LJWBFlutterMessageChannel.m
//  LJWebBrowser
//
//  Created by 李翔宇 on 2020/6/11.
//

#import "BKWBFlutterMessageChannel.h"
#import "BKWBCache.h"
#import "BKWBScript.h"
#import "BKWBBridgeConstants.h"
#import "BKWBBridgeManager.h"
#import "BKWBFlutterConstants.h"
#import "BKWBFlutterManager.h"
#import "BKWBFlutterChannelData.h"

@interface BKWBFlutterMessageChannel ()

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSMutableArray<LJWBFlutterMethodHandler> *handlersM;

/// 支持直接将JS调用转发到Native通道
@property(nonatomic, strong) FlutterMessageHandler native_handler;

/// 通道真实名称
@property(nonatomic, copy) NSString *channelName;

@end

@implementation BKWBFlutterMessageChannel

- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    if(self) {
        _name = name;
        _handlersM = [NSMutableArray array];
        
        _channelName = ljwbflutter_createChannelName(LJWB_FLUTTER_CHANNEL_TYPE_MESSAGE_CHANNEL, name);
        
        [self _enumBrowser:^(BKWebBrowser *browser) {
            [self _createChannelInBrowser:browser];
            [self _injectMethodIntoBrowser:browser];
        } andBridgeManager:^(BKWBBridgeManager *manager) {
            [self _configMethodHandlerIntoBridgeManager:manager];
        }];
    }
    return self;
}

- (NSArray<LJWBFlutterMethodHandler> *)handlers {
    return [_handlersM copy];
}

- (void)registerHandler:(LJWBFlutterMethodHandler)handler {
    if(!handler) {
        return;
    }
    
    if([_handlersM containsObject:handler]) {
        return;
    }
    
    [_handlersM addObject:handler];
}

- (void)cancelHandler:(LJWBFlutterMessageHandler)handler {
    if(!handler) {
        return;
    }
    
    [_handlersM removeObject:handler];
}

#pragma mark - 桥接

- (void)sendMessage:(id _Nullable)message {
    [self sendMessage:message reply:^(id _Nullable reply) {
        NSLog(@"%@", reply);
    }];
}

- (void)sendMessage:(id _Nullable)message reply:(FlutterReply _Nullable)callback {
    [self _enumBrowser:^(BKWebBrowser *browser) {
        //无操作
    } andBridgeManager:^(BKWBBridgeManager *manager) {
        NSString *channelMethod = ljwbflutter_packMethod(self.channelName, LJWB_FLUTTER_CHANNEL_FLUTTER_HANDLER);
        
        BKWBFlutterChannelData *channelData = [[BKWBFlutterChannelData alloc] init];
        channelData.args = message;
        
        [manager callHandler:channelMethod
                        data:channelData.data
            responseCallback:^(id data) {
            !callback ? : callback(data);
        }];
    }];
}

- (void)setMessageHandler:(FlutterMessageHandler _Nullable)handler {
    _native_handler = handler;
}

#pragma mark - Private Method

//在指定browser中创建通道
- (void)_createChannelInBrowser:(BKWebBrowser *)browser {
    NSString *source = [NSString stringWithFormat:@"lianjia_channel_register('%@');", _channelName];
    
    //在browser关联的webView中执行脚本
    [browser evaluateJavaScript:source completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        if(error) { NSLog(@"%@", error); }
    }];
    
    //在browser关联的configuration中注册脚本
    WKUserScript *script = [BKWBScript scriptFromSource:source];
    [browser.configurationManager registerScript:script];
}

//在指定browser中添加指定method
- (void)_injectMethodIntoBrowser:(BKWebBrowser *)browser {
    NSString *source = [NSString stringWithFormat:@"lianjia_message_channel_register_native('%@', '%@');", _channelName, LJWB_FLUTTER_CHANNEL_NATIVE_HANDLER];
    
    //在browser关联的webView中执行脚本
    [browser evaluateJavaScript:source completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        if(error) { NSLog(@"%@", error); }
    }];
    
    //在browser关联的configuration中注册脚本
    WKUserScript *script = [BKWBScript scriptFromSource:source];
    [browser.configurationManager registerScript:script];
}

//在指定bridge manager中添加全部handler
- (void)_configMethodHandlerIntoBridgeManager:(BKWBBridgeManager *)manager {
    NSString *channelMethod = ljwbflutter_packMethod(_channelName, LJWB_FLUTTER_CHANNEL_NATIVE_HANDLER);
    [manager registerHandler:^(id _Nonnull data, LJWBBridgeCallback _Nonnull callback, WKWebView *webView) {
        if(![data isKindOfClass:[NSDictionary class]]) {
            NSLog(@"未能识别的通道数据：%@", data);
            return;
        }
        
        BKWBFlutterChannelData *channelData = [BKWBFlutterChannelData dataWithData:data];
        
        if(self.handlersM.count) {
            [self.handlersM enumerateObjectsUsingBlock:^(LJWBFlutterMethodHandler _Nonnull handler, NSUInteger idx, BOOL * _Nonnull stop) {
                handler(channelData.args, ^(id _Nullable result) {
                    !callback ? : callback(result);
                }, webView);
            }];
            return;
        }
        
        if(self.native_handler) {
            self.native_handler(channelData.args, ^(id _Nullable result) {
                !callback ? : callback(result);
            });
            return;
        }
        
        NSLog(@"未能处理的通道方法：%@.%@", self.channelName, channelData.method);
    } onIdentifier:channelMethod];
}

- (void)_enumBrowser:(void(^)(BKWebBrowser *browser))browserBlock
    andBridgeManager:(void(^)(BKWBBridgeManager *manager))managerBlock {
    [BKWBFlutterManager.defaultManager.browsers enumerateObjectsUsingBlock:^(BKWebBrowser * _Nonnull browser, NSUInteger idx, BOOL * _Nonnull stop) {
        !browserBlock ? : browserBlock(browser);
        
        [browser.modules enumerateObjectsUsingBlock:^(BKWBBridgeManager * _Nonnull manager, NSUInteger idx, BOOL * _Nonnull stop) {
            if(![manager isKindOfClass:[BKWBBridgeManager class]]) {
                return;
            }
            
            !managerBlock ? : managerBlock(manager);
        }];
    }];
}

#pragma mark - WKWebBrowserModuleProtocol

- (void)ljwb_addedToBrowser:(nonnull BKWebBrowser *)browser {
    //创建通道
    [self _createChannelInBrowser:browser];
    
    //注入全部函数
    [self _injectMethodIntoBrowser:browser];
    
    //配置全部桥接
    [browser.modules enumerateObjectsUsingBlock:^(BKWebBrowserModule module, NSUInteger idx, BOOL * _Nonnull stop) {
        if(![module isKindOfClass:[BKWBBridgeManager class]]) {
            return;
        }
        
        [self _configMethodHandlerIntoBridgeManager:(BKWBBridgeManager *)module];
    }];
}

- (void)ljwb_addedModule:(id<WKWebBrowserModuleProtocol>)module toBrowser:(BKWebBrowser *)browser {
    if(![module isKindOfClass:[BKWBBridgeManager class]]) {
        return;
    }
    
    //配置全部桥接
    [self _configMethodHandlerIntoBridgeManager:(BKWBBridgeManager *)module];
}

@end
