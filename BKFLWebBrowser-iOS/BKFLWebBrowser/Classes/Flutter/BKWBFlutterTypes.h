//
//  BKWBFlutterTypes.h
//  BKWebBrowser
//
//  Created by 李翔宇 on 2020/6/11.
//

#import <Foundation/Foundation.h>
#import <WebKit/WKWebView.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^LJWBFlutterCallback)(id _Nullable result);


typedef void (^LJWBFlutterMethodHandler)(id _Nullable args,
                                         LJWBFlutterCallback callback,
                                         WKWebView *webView);
//typedef void (^LJWBFlutterMethodHandler)();

typedef void (^LJWBFlutterMessageHandler)(id _Nullable message,
                                          LJWBFlutterCallback callback,
                                          WKWebView *webView);

NS_ASSUME_NONNULL_END
