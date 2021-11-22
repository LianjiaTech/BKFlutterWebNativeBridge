//
//  WKWebView+LJWBBridge.h
//  LJWebBrowser
//
//  Created by 李翔宇 on 2020/5/21.
//

#import <WebKit/WebKit.h>
#import "BKWBBridge.h"

NS_ASSUME_NONNULL_BEGIN

@interface WKWebView (BKWBBridge)

- (BKWBBridge *)ljwb_bridge;
- (void)ljwb_initBridge:(BKWBBridge *)bridge;

@end

NS_ASSUME_NONNULL_END
