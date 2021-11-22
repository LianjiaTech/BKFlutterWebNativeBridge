//
//  BKWBBridgeTypes.h
//  LJWebBrowser
//
//  Created by 李翔宇 on 2020/5/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^LJWBBridgeCallback)(id response);

//支持以下类型实现
typedef void (^LJWBBridgeHandler)(id args, LJWBBridgeCallback callback, WKWebView *webView);
//typedef void (^LJWBBridgeHandler)();


NS_ASSUME_NONNULL_END
