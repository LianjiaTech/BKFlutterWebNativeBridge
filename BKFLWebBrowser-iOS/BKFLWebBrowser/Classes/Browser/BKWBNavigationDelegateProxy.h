//
//  LJWBNavigationDelegateProxy.h
//  LJWebBrowser
//
//  Created by 李翔宇 on 2020/5/21.
//

/**
 WKNavigationDelegate协议转发类
 1) 向browser自动全量转发协议方法
 2) 向delegate自动全量转发协议方法
 */

#import <Foundation/Foundation.h>
#import <WebKit/WKNavigationDelegate.h>
#import "BKWebBrowserStateProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface BKWBNavigationDelegateProxy : NSProxy<WKNavigationDelegate>

- (id)initWithDelegate:(id<WKNavigationDelegate> _Nullable)delegate browser:(id<BKWebBrowserStateProtocol>)browser;

/// WKWebView的真·代理对象
@property (nonatomic, weak, nullable) id<WKNavigationDelegate> delegate;

/// WKWebView的伪·容器对象
@property (nonatomic, weak, readonly) id<BKWebBrowserStateProtocol> browser;

@end

NS_ASSUME_NONNULL_END
