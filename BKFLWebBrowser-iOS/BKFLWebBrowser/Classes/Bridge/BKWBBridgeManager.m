//
//  LJWBBridgeManager.m
//  LJWebBrowser
//
//  Created by 李翔宇 on 2020/2/13.
//

#import "BKWBBridgeManager.h"
#import "BKWBScript.h"
#import "WKWebView+BKWBBridge.h"

static BKWBBridgeManager *defaultManager = nil;

@interface BKWBBridgeManager ()

@property(nonatomic, strong) NSHashTable<BKWBBridge *> *bridgesM;
@property(nonatomic, strong) NSMutableDictionary<NSString *, LJWBBridgeHandler> *methodsM;

@end

@implementation BKWBBridgeManager

+ (BKWBBridgeManager *)defaultManager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultManager = [[BKWBBridgeManager alloc] init];
    });
    return  defaultManager;
}

- (instancetype)init {
    self = [super init];
    if(self) {
        _bridgesM = [NSHashTable weakObjectsHashTable];
        _methodsM = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSArray<BKWBBridge *> *)bridges {
    return _bridgesM.allObjects;
}

- (NSDictionary<NSString *, dispatch_block_t> *)methods {
    return [_methodsM copy];
}

- (void)registerHandler:(LJWBBridgeHandler)handler onIdentifier:(NSString *)identifier {
    if(!handler) {
        return;
    }
    
    if(!identifier.length) {
        return;
    }
    
    LJWBBridgeHandler cache = _methodsM[identifier];
    if(cache) {
        if(cache == handler) {
            return;
        }
    }
    
    _methodsM[identifier] = handler;
    
    [_bridgesM.allObjects enumerateObjectsUsingBlock:^(BKWBBridge * _Nonnull bridge, NSUInteger idx, BOOL * _Nonnull stop) {
        [bridge registerHandler:handler onIdentifier:identifier];
    }];
}

- (void)removeHandlerByIdentifier:(NSString *)identifier {
    [_methodsM removeObjectForKey:identifier];
    
    [_bridgesM.allObjects enumerateObjectsUsingBlock:^(BKWBBridge * _Nonnull bridge, NSUInteger idx, BOOL * _Nonnull stop) {
        [bridge removeHandlerByIdentifier:identifier];
    }];
}

- (void)callHandler:(NSString *)handlerName {
    [_bridgesM.allObjects enumerateObjectsUsingBlock:^(BKWBBridge * _Nonnull bridge, NSUInteger idx, BOOL * _Nonnull stop) {
        [bridge callHandler:handlerName];
    }];
}

- (void)callHandler:(NSString *)handlerName data:(id)data {
    [_bridgesM.allObjects enumerateObjectsUsingBlock:^(BKWBBridge * _Nonnull bridge, NSUInteger idx, BOOL * _Nonnull stop) {
        [bridge callHandler:handlerName data:data];
    }];
}

- (void)callHandler:(NSString *)handlerName
               data:(id)data
   responseCallback:(WVJBResponseCallback)callback {
    [_bridgesM.allObjects enumerateObjectsUsingBlock:^(BKWBBridge * _Nonnull bridge, NSUInteger idx, BOOL * _Nonnull stop) {
        [bridge callHandler:handlerName data:data responseCallback:callback];
    }];
}

- (NSString *)bridgeSource {
    
    return [BKWBScript sourceFromResource:@"bridge_wvjb" inSubspec:@"Bridge"];
}

#pragma mark - LJWebBrowserStateProtocol

- (void)ljwb_webView:(WKWebView *)webView didCreatedWithConfiguration:(WKWebViewConfiguration *)configuration {
    //⚠️注意！不能在此处重复注入bridgeSource，会导致实现覆盖，桥接丢失
    //在browser关联的webView中执行脚本
//    [webView evaluateJavaScript:self.bridgeSource completionHandler:^(id _Nullable data, NSError * _Nullable error) {
//        if(error) { LJLOG_WARN(@"%@", error); }
//    }];
    
    //创建webView的时候默认创建bridge
    BKWBBridge *bridge = [[BKWBBridge alloc] initWithWebView:webView andMethods:self.methods];
    [webView ljwb_initBridge:bridge];
    [_bridgesM addObject:bridge];
}

- (void)ljwb_webView:(WKWebView *)webView didSetNavigationDelegate:(nonnull id<WKNavigationDelegate>)delegate {
    if([delegate isKindOfClass:[WKWebViewJavascriptBridge class]]) {
        return;
    }
    
    WKWebViewJavascriptBridge *jsBridge = webView.ljwb_bridge.jsBridge;
    if(delegate == jsBridge) {
        return;
    }
    
    //保证NavigationDelegate链条完整性
    [jsBridge setWebViewDelegate:delegate];
    webView.navigationDelegate = jsBridge;
}

#pragma mark - WKWebBrowserModuleProtocol

- (void)ljwb_addedToBrowser:(BKWebBrowser *)browser {

    //在browser关联的webView中执行脚本
    [browser evaluateJavaScript:self.bridgeSource completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        if(error) { NSLog(@"%@", error); }
    }];
    
    //在browser关联的configuration中注册脚本
    WKUserScript *script = [BKWBScript scriptFromSource:self.bridgeSource];
    [browser.configurationManager registerScript:script];
}

@end
