//
//  LJWBConfigurationManager.h
//  LJWebBrowser
//
//  Created by 李翔宇 on 2020/2/13.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BKWBConfigurationManager : NSObject

/// browser中webViews的共用configuration
@property (nonatomic, strong, readonly) WKWebViewConfiguration *configuration;

/// browser中webViews的共用processPool
@property (nonatomic, strong, readonly) WKProcessPool *processPool;

/// browser中webViews的共用preferences
@property (nonatomic, strong, readonly) WKPreferences *preferences;

/// browser中webViews的共用userContentController
@property (nonatomic, strong, readonly) WKUserContentController *userContentController;

/// 配置列表
@property(nonatomic, copy, readonly) NSArray<WKWebViewConfiguration *> *configurations;

/// 注册配置
- (void)registerConfiguration:(WKWebViewConfiguration *)configuration;

/// 移除配置
- (void)removeConfiguration:(WKWebViewConfiguration *)configuration;

/// 脚本列表
@property(nonatomic, copy, readonly) NSArray<WKUserScript *> *scripts;

/// 注册脚本
- (void)registerScript:(WKUserScript *)script;

/// 移除脚本
- (void)removeScript:(WKUserScript *)script;

- (void)addScript:(WKUserScript *)script intoConfiguration:(WKWebViewConfiguration *)configuration;

- (void)removeScript:(WKUserScript *)script fromConfiguration:(WKWebViewConfiguration *)configuration;

@end

NS_ASSUME_NONNULL_END
