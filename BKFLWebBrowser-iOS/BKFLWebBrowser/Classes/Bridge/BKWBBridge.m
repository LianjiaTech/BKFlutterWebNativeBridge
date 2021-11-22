//
//  LJWBBridge.m
//  LJWebBrowser
//
//  Created by 李翔宇 on 2020/5/21.
//

#import "BKWBBridge.h"

@interface BKWBBridge ()<WKScriptMessageHandler>

@property (nonatomic, weak) WKWebView *webView;
@property (nonatomic, strong) NSMutableDictionary<NSString *, LJWBBridgeHandler> *methodsM;
@property (nonatomic, strong) WKWebViewJavascriptBridge *jsBridge;

@end

@implementation BKWBBridge

- (instancetype)initWithWebView:(WKWebView *)webView
                     andMethods:(NSDictionary<NSString *, LJWBBridgeHandler> *)methods {
    self = [super init];
    if(self) {
        _webView = webView;
        
        if(methods) {
            _methodsM = [methods mutableCopy];
        } else {
            _methodsM = [NSMutableDictionary dictionary];
        }
        
        //WKWebViewJavascriptBridge内部逻辑
        //1)弱引用持有webView
        //2)将webView.navigationDelegate设置为jsBridge
        id<WKNavigationDelegate> _delegate = webView.navigationDelegate;
        _jsBridge = [WKWebViewJavascriptBridge bridgeForWebView:webView];
        [_jsBridge setWebViewDelegate:_delegate];
        
        [methods enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull identifier, LJWBBridgeHandler  _Nonnull handler, BOOL * _Nonnull stop) {
            [self _registerHandler:handler onIdentifier:identifier];
        }];
    }
    return self;
}

- (void)registerHandler:(LJWBBridgeHandler)handler onIdentifier:(NSString *)identifier {
    if(!handler) {
        return;
    }
    
    if(!identifier.length) {
        return;
    }
    
    _methodsM[identifier] = handler;
    
    [self _registerHandler:handler onIdentifier:identifier];
}

- (void)removeHandlerByIdentifier:(NSString *)identifier {
    if(!identifier.length) {
        return;
    }
    
    _methodsM[identifier] = nil;
    
    [self _removeHandlerByIdentifier:identifier];
}

- (void)callHandler:(NSString *)handlerName {
    [_jsBridge callHandler:handlerName];
}

- (void)callHandler:(NSString *)handlerName data:(id)data {
    [_jsBridge callHandler:handlerName data:data];
}

- (void)callHandler:(NSString *)handlerName
               data:(id)data
   responseCallback:(WVJBResponseCallback)callback {
    [_jsBridge callHandler:handlerName data:data responseCallback:callback];
}

#pragma mark - WKScriptMessageHandler

/*! @abstract Invoked when a script message is received from a webpage.
 @param userContentController The user content controller invoking the
 delegate method.
 @param message The script message received.
 */
- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
    
    id args = message.body;
    NSString *callbackName = LJWBBridgeCallbackName(message.name);

    if([message.body isKindOfClass:[NSDictionary class]]) {
        //如果消息体是字典，那么查找args和callback
        
        NSDictionary *body = message.body;
        
        if(body[LJWBBridgeHybridArgsKey]) {
            args = body[LJWBBridgeHybridArgsKey];
        }
        
        if(body[LJWBBridgeHybridCallbackKey]) {
            callbackName = body[LJWBBridgeHybridCallbackKey];
        }
    } else if([message.body isKindOfClass:[NSArray class]]) {
        //如果消息体是数组，那么查找args和callback
        
        NSMutableArray *bodyM = [message.body mutableCopy];
        do {
            if(!bodyM.count) {
                break;
            }
            
            if([bodyM.lastObject hasSuffix:LJWBBridgeCallbackSuffix]) {
                callbackName = bodyM.lastObject;
                
                [bodyM removeObject:callbackName];
                args = [bodyM copy];
            }
        } while(0);
    } else if([message.body isKindOfClass:[NSString class]]) {
        do {
            NSData *data = [(NSString *)message.body dataUsingEncoding:NSUTF8StringEncoding];
            if(!data) {
                break;
            }
            
            NSError *error = nil;
            id json = [NSJSONSerialization JSONObjectWithData:data
                                                      options:NSJSONReadingFragmentsAllowed
                                                        error:&error];
            if(!json) {
                if(error) {
                    NSLog(@"%@", error);
                }
                break;
            }
            
            if(![json isKindOfClass:[NSDictionary class]]) {
                break;
            }
            
            NSDictionary *body = json;
            
            if(body[LJWBBridgeHybridArgsKey]) {
                args = body[LJWBBridgeHybridArgsKey];
            }
            
            if(body[LJWBBridgeHybridCallbackKey]) {
                callbackName = body[LJWBBridgeHybridCallbackKey];
            }
        } while(0);
    } else {
        //TODO:
    }
    
    LJWBBridgeCallback callback = [self _callbackWithName:callbackName];
    LJWBBridgeHandler handler = [self _handlerWithName:message.name];
    handler(args, callback, _webView);
}

#pragma mark - Private Method

//创建回调
- (LJWBBridgeCallback)_callbackWithName:(NSString *)callbackName {
    return ^(id response) {
        NSString *result = nil;
        if([response isKindOfClass:[NSString class]]) {
            result = response;
        } else {
            do {
                NSError *error = nil;
                NSData *data = [NSJSONSerialization dataWithJSONObject:response
                                                               options:NSJSONWritingFragmentsAllowed
                                                                 error:&error];
                if(!data.length) {
                    if(error) {
                        NSLog(@"%@", error);
                    }
                    break;
                }
                
                NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if(!json.length) {
                    NSLog(@"序列化错误");
                    break;
                }
                
                result = json;
            } while(0);
        }
        
        NSString *script = [NSString stringWithFormat:@"%@(%@)", callbackName, result];
        [self.webView evaluateJavaScript:script completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            if(error) {
                NSLog(@"%@", error);
            }
            
            if(result) {
                NSLog(@"%@", result);
            }
        }];
    };
}

//查找处理器
- (LJWBBridgeHandler)_handlerWithName:(NSString *)name {
    //查找硬匹配
    LJWBBridgeHandler handler = _methodsM[name];
    if(handler) {
        return handler;
    }
    
    //查找半匹配
    [_methodsM enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull identifier, LJWBBridgeHandler _Nonnull handler, BOOL * _Nonnull stop) {
        //判断是否通配符后缀
        if(![identifier hasSuffix:LJWBBridgeWildcardIdentifier]) {
            return;
        }
        
        //判断是否匹配前缀
        NSString *prefix = [identifier stringByReplacingOccurrencesOfString:LJWBBridgeWildcardIdentifier withString:@""];
        if(![name hasPrefix:prefix]) {
            return;
        }
        
        //找到有效handler
        handler = _methodsM[identifier];
        *stop = YES;
    }];
    
    if(handler) {
        return handler;
    }
    
    //查找硬通配
    handler = _methodsM[LJWBBridgeWildcardIdentifier];
    if(handler) {
        return handler;
    }
    
    //错误
    return ^(id data, LJWBBridgeCallback callback, WKWebView *webView) {
        NSLog(@"未能识别桥接方法：%@", name);
    };
}

- (void)_registerHandler:(LJWBBridgeHandler)handler onIdentifier:(NSString *)identifier {
    WKUserContentController *controller = _webView.configuration.userContentController;
    [controller removeScriptMessageHandlerForName:identifier];
    [controller addScriptMessageHandler:self name:identifier];
    
    [_jsBridge registerHandler:identifier
                       handler:^(id args, WVJBResponseCallback callback) {
        handler(args, ^(id response) {
            !callback ? : callback(response);
        }, self.webView);
    }];
}

- (void)_removeHandlerByIdentifier:(NSString *)identifier {
    WKUserContentController *controller = _webView.configuration.userContentController;
    [controller removeScriptMessageHandlerForName:identifier];
    
    [_jsBridge removeHandler:identifier];
}

@end
