//
//  LJWBDebugWebViewController.h
//  LJWebBrowser
//
//  Created by 李翔宇 on 2020/8/10.
//

#import "LJDebugController.h"
#import <WebKit/WKWebView.h>

NS_ASSUME_NONNULL_BEGIN

@interface LJWBDebugWebViewController : LJDebugController

@property (nonatomic, strong) WKWebView *webView;

@end

NS_ASSUME_NONNULL_END
