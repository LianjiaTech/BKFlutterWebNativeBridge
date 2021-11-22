//
//  WKWebView+LJWBBridge.m
//  LJWebBrowser
//
//  Created by 李翔宇 on 2020/5/21.
//

#import "WKWebView+BKWBBridge.h"
#import <objc/runtime.h>
#import "BKWBBridgeManager.h"

static NSString * const LJWebBrowserWebViewBridge = @"Bridge";

@implementation WKWebView (BKWBBridge)

- (BKWBBridge *)ljwb_bridge {
    BKWBBridge *bridge = objc_getAssociatedObject(self, (__bridge const void * _Nonnull)(LJWebBrowserWebViewBridge));
    return bridge;
}

- (void)ljwb_initBridge:(BKWBBridge *)bridge {
    
    objc_setAssociatedObject(self, (__bridge const void * _Nonnull)(LJWebBrowserWebViewBridge), bridge, OBJC_ASSOCIATION_RETAIN);
}

@end
