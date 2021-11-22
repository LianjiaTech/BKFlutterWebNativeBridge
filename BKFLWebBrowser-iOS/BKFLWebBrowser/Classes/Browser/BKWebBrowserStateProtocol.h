//
//  LJWebBrowserStateProtocol.h
//  LJWebBrowser
//
//  Created by 李翔宇 on 2020/5/20.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BKWebBrowserStateProtocol <WKNavigationDelegate, WKUIDelegate>

@optional

/// 将要创建webView
/// @param configuration WKWebViewConfiguration对象
- (void)ljwb_webViewWillCreateWithConfiguration:(WKWebViewConfiguration *)configuration;

/// 已经创建webView
/// @param webView WKWebView对象
/// @param configuration WKWebViewConfiguration对象
- (void)ljwb_webView:(WKWebView *)webView didCreatedWithConfiguration:(WKWebViewConfiguration *)configuration;

/// 将要设置Navigation Delegate
/// @param webView WKWebView对象
/// @param delegate id<WKNavigationDelegate>对象
- (void)ljwb_webView:(WKWebView *)webView willSetNavigationDelegate:(id<WKNavigationDelegate>)delegate;

/// 已经设置Navigation Delegate
/// @param webView WKWebView对象
/// @param delegate id<WKNavigationDelegate>对象
- (void)ljwb_webView:(WKWebView *)webView didSetNavigationDelegate:(id<WKNavigationDelegate>)delegate;

/// 将要设置UI Delegate
/// @param webView WKWebView对象
/// @param delegate id<WKUIDelegate>对象
- (void)ljwb_webView:(WKWebView *)webView willSetUIDelegate:(id<WKUIDelegate>)delegate;

/// 已经设置UI Delegate
/// @param webView WKWebView对象
/// @param delegate id<WKUIDelegate>对象
- (void)ljwb_webView:(WKWebView *)webView didSetUIDelegate:(id<WKUIDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
