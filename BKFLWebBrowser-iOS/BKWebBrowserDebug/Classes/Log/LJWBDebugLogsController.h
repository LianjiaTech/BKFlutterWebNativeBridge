//
//  LJWBDebugLogsController.h
//  LJWebBrowser
//
//  Created by 李翔宇 on 2020/8/5.
//

#import "LJDebugController.h"
#import <WebKit/WKWebView.h>

NS_ASSUME_NONNULL_BEGIN

@interface LJWBDebugLogsController : LJDebugController

@property (nonatomic, strong) WKWebView *webView;

@end

NS_ASSUME_NONNULL_END
