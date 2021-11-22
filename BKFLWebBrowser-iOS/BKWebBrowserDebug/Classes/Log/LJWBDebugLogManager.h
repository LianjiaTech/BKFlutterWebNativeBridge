//
//  LJWBDebugLogManager.h
//  LJWebBrowser
//
//  Created by 李翔宇 on 2020/8/5.
//

#import "LJWBModule.h"
#import <ljtools/ljtol_singleton.h>

NS_ASSUME_NONNULL_BEGIN

@interface LJWBDebugLogManager : LJWBModule

/// 绝对单例
LJTOL_SINGLETON_INTERFACE(LJWBDebugLogManager, defaultManager)

/// {WebView(identifier): logs}
@property(nonatomic, copy) NSDictionary<NSString *, NSMutableArray<NSString *> *> *webViewLogs;

- (NSMutableArray<NSString *> *)logsInWebView:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
