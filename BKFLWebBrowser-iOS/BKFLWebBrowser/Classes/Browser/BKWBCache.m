//
//  LJWBCache.m
//  LJWebBrowser
//
//  Created by 李翔宇 on 2020/5/21.
//

#import "BKWBCache.h"

static BKWBCache *defaultCache = nil;

@implementation BKWBCache

+ (BKWBCache *)defaultCache {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultCache = [[BKWBCache alloc] init];
    });
    
    return defaultCache;
}
@end
