//
//  LJWBConfigurationManager.m
//  LJWebBrowser
//
//  Created by 李翔宇 on 2020/2/13.
//

#import "BKWBConfigurationManager.h"

@interface BKWBConfigurationManager ()

@property (nonatomic, strong) WKWebViewConfiguration *configuration;
@property (nonatomic, strong) WKProcessPool *processPool;
@property (nonatomic, strong) WKPreferences *preferences;
@property (nonatomic, strong) WKUserContentController *userContentController;

//配置列表
@property (nonatomic, strong) NSHashTable<WKWebViewConfiguration *> *configurationsM;
//脚本列表
@property (nonatomic, strong) NSHashTable<WKUserScript *> *scriptsM;

@end

@implementation BKWBConfigurationManager

- (instancetype)init {
    self = [super init];
    if(self) {
        _configuration = [[WKWebViewConfiguration alloc] init];
        _processPool = _configuration.processPool;
        _preferences = _configuration.preferences;
        _userContentController = _configuration.userContentController;
        
        _configurationsM = [NSHashTable weakObjectsHashTable];
        _scriptsM = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

- (NSArray<WKWebViewConfiguration *> *)configurations {
    return _configurationsM.allObjects;
}

- (void)registerConfiguration:(WKWebViewConfiguration *)configuration {
    if(!configuration) {
        return;
    }
    
    if(configuration == _configuration) {
        return;
    }
    
    if([_configurationsM containsObject:configuration]) {
        return;
    }
    
    [_configurationsM addObject:configuration];
    
    [self.scripts enumerateObjectsUsingBlock:^(WKUserScript * _Nonnull script, NSUInteger idx, BOOL * _Nonnull stop) {
        [configuration.userContentController addUserScript:script];
    }];
}

- (void)removeConfiguration:(WKWebViewConfiguration *)configuration {
    if(!configuration) {
        return;
    }
    
    if(configuration == _configuration) {
        return;
    }
    
    if(![_configurationsM containsObject:configuration]) {
        return;
    }
    
    [_configurationsM removeObject:configuration];
}

- (NSArray<WKUserScript *> *)scripts {
    return _scriptsM.allObjects;
}

- (void)registerScript:(WKUserScript *)script {
    if(!script) {
        return;
    }
    
    if([_scriptsM containsObject:script]) {
        return;
    }
    
    [_scriptsM addObject:script];
    
    [self.configurations enumerateObjectsUsingBlock:^(WKWebViewConfiguration * _Nonnull configuration, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray<WKUserScript *> *scripts = configuration.userContentController.userScripts;
        if([scripts containsObject:script]) {
            return;
        }
        
        [configuration.userContentController addUserScript:script];
    }];
    
    [_configuration.userContentController addUserScript:script];
}

- (void)removeScript:(WKUserScript *)script {
    if(!script) {
        return;
    }
    
    if(![_scriptsM containsObject:script]) {
        return;
    }
    
    [_scriptsM removeObject:script];
}

- (void)addScript:(WKUserScript *)script intoConfiguration:(WKWebViewConfiguration *)configuration {
    NSArray<WKUserScript *> *scripts = configuration.userContentController.userScripts;
    if([scripts containsObject:script]) {
        return;
    }
    
    [configuration.userContentController addUserScript:script];
}

- (void)removeScript:(WKUserScript *)script fromConfiguration:(WKWebViewConfiguration *)configuration {
    NSArray<WKUserScript *> *scripts = configuration.userContentController.userScripts;
    if(![scripts containsObject:script]) {
        return;
    }
    
    [configuration.userContentController removeAllUserScripts];
    
    NSMutableArray<WKUserScript *> *scriptsM = [scripts copy];
    [scriptsM removeObject:script];
    [scriptsM enumerateObjectsUsingBlock:^(WKUserScript * _Nonnull script, NSUInteger idx, BOOL * _Nonnull stop) {
        [configuration.userContentController addUserScript:script];
    }];
}

@end
