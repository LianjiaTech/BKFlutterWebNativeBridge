//
//  LJWBCache.h
//  LJWebBrowser
//
//  Created by 李翔宇 on 2020/5/21.
//

/**
 LJWBCache是Web容器的缓存类
 用于支持IO等性能操作结果临时保存，实现内存加载
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BKWBCache : NSCache

+ (BKWBCache *)defaultCache;

@end

NS_ASSUME_NONNULL_END
