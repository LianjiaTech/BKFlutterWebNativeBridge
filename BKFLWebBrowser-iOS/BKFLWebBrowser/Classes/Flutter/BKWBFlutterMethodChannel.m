//
//  LJWBFlutterMethodChannel.m
//  LJWebBrowser
//
//  Created by 李翔宇 on 2020/6/11.
//

#import "BKWBFlutterMethodChannel.h"
#import "BKWBCache.h"
#import "BKWBScript.h"
#import "BKWBBridgeConstants.h"
#import "BKWBBridgeManager.h"
#import "BKWBFlutterConstants.h"
#import "FlutterCodecs.h"
#import "BKWBFlutterManager.h"
#import "BKWBFlutterChannelData.h"

@interface BKWBFlutterMethodChannel ()

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSMutableDictionary<NSString *, LJWBFlutterMethodHandler> *methodsM;

/// 支持直接将JS调用转发到Native通道
@property(nonatomic, strong) FlutterMethodCallHandler native_handler;

/// 通道真实名称
@property(nonatomic, copy) NSString *channelName;

@end

@implementation BKWBFlutterMethodChannel

- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    if(self) {
        _name = name;
        _methodsM = [NSMutableDictionary dictionary];
        
        _channelName = ljwbflutter_createChannelName(LJWB_FLUTTER_CHANNEL_TYPE_METHOD_CHANNEL, name);
        
        [self _enumBrowser:^(BKWebBrowser *browser) {
            [self _createChannelInBrowser:browser];
            [self _injectMethodIntoBrowser:browser];
        } andBridgeManager:^(BKWBBridgeManager *manager) {
            [self _configMethodHandlerIntoBridgeManager:manager];
        }];
    }
    return self;
}

- (NSDictionary<NSString *, LJWBFlutterMethodHandler> *)methods {
    return [_methodsM copy];
}

- (void)registerHandler:(LJWBFlutterMethodHandler)handler forMethod:(NSString *)method {
    if(!handler) {
        return;
    }
    
    if(!method.length) {
        return;
    }
    
    LJWBFlutterMethodHandler cache = _methodsM[method];
    if(cache) {
        if(cache == handler) {
            return;
        }
    }
    
    _methodsM[method] = handler;
}

- (void)cancelHandlerByMethod:(NSString *)method {
    if(![method isKindOfClass:[NSString class]]
       || !method.length) {
        return;
    }
    
    [_methodsM removeObjectForKey:method];
}

#pragma mark - 桥接

- (void)invokeMethod:(NSString *)method arguments:(id _Nullable)arguments {
    [self invokeMethod:method arguments:arguments result:^(id _Nullable result) {
        NSLog(@"%@", result);
    }];
}

- (void)invokeMethod:(NSString *)method
           arguments:(id _Nullable)arguments
              result:(FlutterResult _Nullable)callback {
    if([_name isEqualToString:@"flutter_runner"]) {
        //        if([method isEqualToString:@"willDisappearPageContainer"]
        //           || [method isEqualToString:@"didDisappearPageContainer"]
        //           || [method isEqualToString:@"willDeallocPageContainer"]) {
        //            return;
        //        }
    }
    
    [self _enumBrowser:^(BKWebBrowser *browser) {
        //无操作
    } andBridgeManager:^(BKWBBridgeManager *manager) {
        NSString *channelMethod = ljwbflutter_packMethod(self.channelName, LJWB_FLUTTER_CHANNEL_FLUTTER_HANDLER);
        
        BKWBFlutterChannelData *channelData = [[BKWBFlutterChannelData alloc] init];
        channelData.method = method;
        channelData.args = arguments;
        
        [manager callHandler:channelMethod
                        data:channelData.data
            responseCallback:^(id data) {
            !callback ? : callback(data);
        }];
    }];
}

- (void)setMethodCallHandler:(FlutterMethodCallHandler)handler {
    _native_handler = handler;
}

#pragma mark - Private Method

//在指定browser中创建通道
- (void)_createChannelInBrowser:(BKWebBrowser *)browser {
    NSString *source = [NSString stringWithFormat:@"lianjia_method_channel_register('%@');", _channelName];
    
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
    NSString *source = [NSString stringWithFormat:@"lianjia_method_channel_register_by_native('%@', '%@');", _channelName, LJWB_FLUTTER_CHANNEL_NATIVE_HANDLER];
    NSLog(@"loading js source:%@", source);
    //在browser关联的webView中执行脚本
    [browser evaluateJavaScript:source completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        if(error) {
            NSLog(@"%@", error);
            NSLog(@"Failed to evaluate js: %@", source);
        } else {
            NSLog(@"Js evaluated success: %@", source);
        }
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
        
        LJWBFlutterMethodHandler handler = self.methods[channelData.method];
        if(handler) {
            handler(channelData.args, ^(id _Nullable result) {
                !callback ? : callback(result);
            }, webView);
            return;
        }
        
        if(self.native_handler) {
            FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:channelData.method
                                                                        arguments:channelData.args];
            self.native_handler(call, ^(id _Nullable result) {
                NSMutableDictionary *ret = [NSMutableDictionary dictionary];
                if ([result isKindOfClass:[NSString class]]) {
                    ret[@"type"] = @"string";
                    ret[@"obj"] = result;
                } else if([result isKindOfClass:[NSDictionary class]]) {
                    
                    NSData *dat = [NSJSONSerialization dataWithJSONObject:result options:0 error:nil];
                    ret[@"obj"] = [[NSString alloc] initWithData:dat encoding:NSUTF8StringEncoding];
                    
                    ret[@"type"] = @"map";
                }  else if([result isKindOfClass:[NSArray class]]) {
                    
                    NSData *dat = [NSJSONSerialization dataWithJSONObject:result options:0 error:nil];
                    ret[@"obj"] = [[NSString alloc] initWithData:dat encoding:NSUTF8StringEncoding];
                    
                    ret[@"type"] = @"list";
                } else {
                    
                    ret[@"type"] = @"unknown";
                    ret[@"obj"] = result;
                }
                
                NSData *dat = [NSJSONSerialization  dataWithJSONObject:ret options:0 error:nil];
                NSString *retString = [[NSString alloc] initWithData:dat encoding:NSUTF8StringEncoding];
                                
                !callback ? : callback(retString);
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
