//
//  LJWBDebugLogManager.m
//  LJWebBrowser
//
//  Created by 李翔宇 on 2020/8/5.
//

#import "LJWBDebugLogManager.h"
#import <RSSwizzle/RSSwizzle.h>
#import <ljtools/ljtol_macros.h>
#import <ljtools/ljtol_log.h>
#import <LJFLWebBrowser/LJWebBrowser.h>
#import <LJFLWebBrowser/LJWBScript.h>
#import <LJFLWebBrowser/WKWebView+LJWebBrowser.h>
#import <LJFLWebBrowser/LJWBCache.h>
#import <LJFLWebBrowser/LJWBBridgeManager.h>

static NSString * const LJWBDebugLogManagerSourceHook = @"LJWBDebugLogManagerSourceHook";

//Bridge中的Log统一标识
static NSString * const LJWBDebugBridgeLogIdentifier = @"ljwebbrowser_log";

@interface LJWBDebugLogManager ()

@property(nonatomic, copy) NSMutableDictionary<NSString *, NSMutableArray<NSString *> *> *webViewLogsM;

@end

@implementation LJWBDebugLogManager

LJTOL_SINGLETON_IMPLEMENTATION_INIT(LJWBDebugLogManager, defaultManager) {
    _webViewLogsM = [NSMutableDictionary dictionary];
}

- (NSDictionary<NSString *, NSMutableArray<NSString *> *> *)webViewLogs {
    return [_webViewLogsM copy];
}

- (NSMutableArray<NSString *> *)logsInWebView:(NSString *)identifier {
    NSMutableArray<NSString *> *_logsM = _webViewLogsM[identifier];
    if(!_logsM) {
        _logsM = [NSMutableArray array];
        _webViewLogsM[identifier] = _logsM;
    }
    return _logsM;
}

#pragma mark - LJWebBrowserModuleProtocol

- (void)ljwb_addedModule:(id<LJWebBrowserModuleProtocol>)module toBrowser:(LJWebBrowser *)browser {
    if(![module isKindOfClass:[LJWBBridgeManager class]]) {
        return;
    }
    
    //配置桥接
    LJWBBridgeManager *manager = (LJWBBridgeManager *)module;
    [manager registerHandler:^(id _Nonnull args, LJWBBridgeCallback  _Nonnull callback, WKWebView *webView) {
        if(![args isKindOfClass:[NSDictionary class]]) {
            return;
        }
        
        NSMutableArray<NSString *> *logsM = [self logsInWebView:webView.ljwb_identifier];
        [logsM addObject:args];
    } onIdentifier:LJWBDebugBridgeLogIdentifier];
    
    NSString *source = [self _hookSource];

    //在browser关联的webView中执行脚本
    [browser evaluateJavaScript:source completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        if(error) { LJLOG_WARN(@"%@", error); }
    }];
    
    //在browser关联的configuration中注册脚本
    WKUserScript *script = [LJWBScript scriptFromSource:source];
    [browser.configurationManager registerScript:script];
}

#pragma mark - Private Method

- (NSString *)_hookSource {
    NSString *source = [LJWBCache.defaultCache objectForKey:LJWBDebugLogManagerSourceHook];
    if(source) {
        return source;
    }
    
    NSString *identifier = @LJTOL_METAMACRO_STRINGIFY(LJWEBBROWSER_DEBUG_FRAMEWORK);
    identifier = [identifier stringByAppendingString:@".bundle"];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *bundlePath = [bundle.bundlePath stringByAppendingPathComponent:identifier];
    bundle = [NSBundle bundleWithPath:bundlePath];
    NSError *error = nil;
    NSString *path = [bundle pathForResource:@"hook" ofType:@"js"];
    source = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if(!source.length) {
        if(error) {
            LJLOG_WARN(@"%@", error);
        }
        return nil;
    }
    
    [LJWBCache.defaultCache setObject:source forKey:LJWBDebugLogManagerSourceHook];
    return source;
}

#pragma mark - Load

+ (void)hook_init {
    SEL originSEL = @selector(init);
    [RSSwizzle swizzleInstanceMethod:originSEL inClass:[LJWebBrowser class] newImpFactory:^id(RSSwizzleInfo *swizzleInfo) {
        return ^id (LJWebBrowser *self) {
            LJLOG_DEBUG(@"%@", NSStringFromSelector(swizzleInfo.selector));
            
            typedef id (*swizzled_imp)(id, SEL);
            swizzled_imp imp = (swizzled_imp)[swizzleInfo getOriginalImplementation];
            LJWebBrowser *browser = imp(self, swizzleInfo.selector);
            
            [browser registerModule:LJWBDebugLogManager.defaultManager];
            
            return browser;
        };
    } mode:RSSwizzleModeOncePerClass key:"ljwbdebug_init"];
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self hook_init];
    });
}

@end
