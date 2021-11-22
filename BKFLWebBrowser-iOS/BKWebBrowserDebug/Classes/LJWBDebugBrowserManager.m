//
//  LJWBDebugBrowserManager.m
//  LJWebBrowser
//
//  Created by 李翔宇 on 2020/8/10.
//

#import "LJWBDebugBrowserManager.h"
#import <RSSwizzle/RSSwizzle.h>
#import <ljtools/ljtol_log.h>

@interface LJWBDebugBrowserManager ()

@property (nonatomic, strong) NSHashTable<LJWebBrowser *> *browsersM;

@end

@implementation LJWBDebugBrowserManager

LJTOL_SINGLETON_IMPLEMENTATION_INIT(LJWBDebugBrowserManager, defaultManager) {
    _browsersM = [NSHashTable weakObjectsHashTable];
}

#pragma mark - Public Method

- (NSArray<LJWebBrowser *> *)browsers {
    return _browsersM.allObjects;
}

#pragma mark - Load

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL originSEL = @selector(init);
        [RSSwizzle swizzleInstanceMethod:originSEL inClass:[self class] newImpFactory:^id(RSSwizzleInfo *swizzleInfo) {
            return ^id (LJWebBrowser *self) {
                LJLOG_DEBUG(@"%@", NSStringFromSelector(swizzleInfo.selector));
                
                typedef id (*swizzled_imp)(id, SEL);
                swizzled_imp imp = (swizzled_imp)[swizzleInfo getOriginalImplementation];
                LJWebBrowser *browser = imp(self, swizzleInfo.selector);
                
                [LJWBDebugBrowserManager.defaultManager.browsersM addObject:browser];
                
                return browser;
            };
        } mode:RSSwizzleModeOncePerClass key:"ljwbdebug_init"];
    });
}

@end
