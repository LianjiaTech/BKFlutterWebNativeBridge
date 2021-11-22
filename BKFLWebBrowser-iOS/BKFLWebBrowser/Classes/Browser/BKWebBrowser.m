//
//  LJWebBrowser.m
//  LJWebBrowser
//
//  Created by 李翔宇 on 2020/5/20.
//

#import "BKWebBrowser.h"
#import "BKWBNavigationDelegateProxy.h"
#import "BKWBUIDelegateProxy.h"

@interface BKWebBrowser ()

@property (nonatomic, strong) NSMutableArray<BKWebBrowserModule> *modulesM;

@property (nonatomic, strong) BKWBProxy *proxy;
@property (nonatomic, strong) NSHashTable<WKWebView *> *webViewsM;

@property (nonatomic, strong) BKWBConfigurationManager *configurationManager;

@end

static BKWebBrowser *defaultBrowser = nil;

@implementation BKWebBrowser

+ (BKWebBrowser *)defaultBrowser {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultBrowser = [[BKWebBrowser alloc] init];
    });
    
    return defaultBrowser;
}

- (instancetype)init {
    self = [super init];
    if(self) {
        _identifier = NSUUID.UUID.UUIDString;
        
        _modulesM = [NSMutableArray array];
        _proxy = [[BKWBProxy alloc] initWithBrowser:self];
        _webViewsM = [NSHashTable weakObjectsHashTable];
        
        _configurationManager = [[BKWBConfigurationManager alloc] init];
        
    }
    return self;
}

- (NSArray<BKWebBrowserModule> *)modules {
    return [_modulesM copy];
}

- (void)registerModule:(BKWebBrowserModule)module {
    if(!module) {
        return;
    }
    
    if([_modulesM containsObject:module]) {
        return;
    }
    
    if(![module conformsToProtocol:@protocol(WKWebBrowserModuleProtocol)]) {
        return;
    }
    
    [_modulesM addObject:module];
    
    if([module respondsToSelector:@selector(ljwb_addedToBrowser:)]) {
        [module ljwb_addedToBrowser:self];
    }
    
    [_modulesM enumerateObjectsUsingBlock:^(BKWebBrowserModule _Nonnull _module, NSUInteger idx, BOOL * _Nonnull stop) {
        if(_module == module) {
            return;
        }
        
        if(![_module respondsToSelector:@selector(ljwb_addedModule:toBrowser:)]) {
            return;
        }
        
        [_module ljwb_addedModule:module toBrowser:self];
    }];
}

- (void)cancelModule:(BKWebBrowserModule)module {
    if(!module) {
        return;
    }
    
    if(![_modulesM containsObject:module]) {
        return;
    }
    
    if(![module conformsToProtocol:@protocol(WKWebBrowserModuleProtocol)]) {
        return;
    }
    
    [_modulesM removeObject:module];
    
    if([module respondsToSelector:@selector(ljwb_removedFromBrowser:)]) {
        [module ljwb_removedFromBrowser:self];
    }
    
    [_modulesM enumerateObjectsUsingBlock:^(BKWebBrowserModule _Nonnull _module, NSUInteger idx, BOOL * _Nonnull stop) {
        if(_module == module) {
            return;
        }
        
        if(![_module respondsToSelector:@selector(ljwb_removedModule:fromBrowser:)]) {
            return;
        }
        
        [_module ljwb_removedModule:module fromBrowser:self];
    }];
}

- (NSArray<WKWebView *> *)webViews {
    return _webViewsM.allObjects;
}

- (void)registerWebView:(WKWebView *)webView {
    if(!webView) {
        return;
    }
    
    if([_webViewsM containsObject:webView]) {
        return;
    }
    
    [_webViewsM addObject:webView];
    
    [_configurationManager registerConfiguration:webView.configuration];
}

- (void)removeWebView:(WKWebView *)webView {
    if(!webView) {
        return;
    }
    
    if([_webViewsM containsObject:webView]) {
        return;
    }
    
    [_webViewsM removeObject:webView];
    
    [_configurationManager removeConfiguration:webView.configuration];
}

- (WKWebView *)createWebView {
//	config.userContentController = userContentController;
//	 config.preferences.javaScriptEnabled = YES;
//	 config.suppressesIncrementalRendering = YES; // 是否支持记忆读取
//	[config.preferences setValue:@YES forKey:@"allowFileAccessFromFileURLs"];//支持跨域
	//_configurationManager.configuration.preferences.javaScriptEnabled = YES;
	//[_configurationManager.configuration.preferences setValue:@YES forKey:@"allowFileAccessFromFileURLs"];
    WKWebView *webView = [self createWebViewWithConfiguration:_configurationManager.configuration];
    
    [_webViewsM addObject:webView];

    return webView;
}

- (WKWebView *)createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration {
    [_configurationManager registerConfiguration:configuration];
    
    [_proxy ljwb_webViewWillCreateWithConfiguration:configuration];
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero
                                            configuration:configuration];
    
    //LJWBNavigationDelegateProxy和LJWBUIDelegateProxy不会触发生命周期通知
    webView.navigationDelegate = [[BKWBNavigationDelegateProxy alloc] initWithDelegate:nil browser:self.proxy];
    webView.UIDelegate = [[BKWBUIDelegateProxy alloc] initWithDelegate:nil browser:self.proxy];
    
    [_proxy ljwb_webView:webView didCreatedWithConfiguration:configuration];
    
    [_webViewsM addObject:webView];
    return webView;
}

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))completionHandler {
    [self.webViews enumerateObjectsUsingBlock:^(WKWebView * _Nonnull webView, NSUInteger idx, BOOL * _Nonnull stop) {
        [webView evaluateJavaScript:javaScriptString completionHandler:completionHandler];
    }];
}

@end
