//
//  LJWBLocalServerManager.h
//  LJWebBrowser
//
//  Created by ZhaoXM on 2020/8/11.
//

#import <Foundation/Foundation.h>
#import <ljtools/ljtol_singleton.h>


@interface LJWBLocalServerManager : NSObject

LJTOL_SINGLETON_INTERFACE(LJWBLocalServerManager, defaultManager)

- (NSString *)getLocalServerAddress;

@end

