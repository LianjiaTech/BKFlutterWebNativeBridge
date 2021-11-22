//
//  LJWebBrowser.h
//  LJWebBrowser
//
//  Created by 李翔宇 on 2020/5/20.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "BKWebBrowserStateProtocol.h"
#import "BKWBProxy.h"
#import "BKWBConfigurationManager.h"

NS_ASSUME_NONNULL_BEGIN

@protocol WKWebBrowserModuleProtocol;

typedef id<BKWebBrowserStateProtocol,
           WKWebBrowserModuleProtocol> BKWebBrowserModule;

@interface BKWebBrowser : NSObject

//支持单例
+ (BKWebBrowser *)defaultBrowser;

/// 标识符
@property (atomic, copy) NSString *identifier;

/// 功能模块列表
@property (nonatomic, copy, readonly) NSArray<BKWebBrowserModule> *modules;

/// 注册功能模块
/// @param module 功能模块
- (void)registerModule:(BKWebBrowserModule)module;

/// 移除功能模块
/// @param module 功能模块
- (void)cancelModule:(BKWebBrowserModule)module;

/// 代理对象，browser通过proxy将webView生命周期分发至各功能模块
/// webView生命周期当前拓展为LJWebBrowserStateProtocol
@property (nonatomic, strong, readonly) BKWBProxy *proxy;

/// browser承载的全部webView数组
@property (nonatomic, strong, readonly) NSArray<WKWebView *> *webViews;

/// 配置管理器，用于统一配置configuration
@property (nonatomic, strong, readonly) BKWBConfigurationManager *configurationManager;

/// 注册webView
/// @param webView webView对象
- (void)registerWebView:(WKWebView *)webView;

/// 移除webView
/// @param webView webView对象
- (void)removeWebView:(WKWebView *)webView;

/// 创建webView
/// 1)ljwb_webViewWillCreateWithConfiguration:
/// 2)initWithFrame:configuration:
/// 3)ljwb_webView:didCreatedWithConfiguration:
/// 4)setNavigationDelegate:
/// 5)setUIDelegate:
/// 6)registerWebView:
- (WKWebView *)createWebView;

/// 创建webView。同createWebView
- (WKWebView *)createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration;

#pragma mark -

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))completionHandler;

@end

@protocol WKWebBrowserModuleProtocol <NSObject>

@optional

/// module添加至modules[后]，回调module此方法
/// @param browser 浏览器
- (void)ljwb_addedToBrowser:(BKWebBrowser *)browser;

/// modules移除module[后]，回调module此方法
/// @param browser 浏览器
- (void)ljwb_removedFromBrowser:(BKWebBrowser *)browser;

/// module添加至modules[后]，回调modules中其他module此方法
/// @param module 被添加module
/// @param browser 浏览器
- (void)ljwb_addedModule:(id<WKWebBrowserModuleProtocol>)module toBrowser:(BKWebBrowser *)browser;

/// module添加至modules[后]，回调modules中其他module此方法
/// @param module 被移除module
/// @param browser 浏览器
- (void)ljwb_removedModule:(id<WKWebBrowserModuleProtocol>)module fromBrowser:(BKWebBrowser *)browser;

@end

#define BKWEBBROWSER(...) \
({\
    id browser = BKWebBrowser.defaultBrowser;\
    for(BKWebBrowserModule module in @[__VA_ARGS__]) {\
        [browser registerModule:module];\
    }\
    browser;\
})

NS_ASSUME_NONNULL_END
