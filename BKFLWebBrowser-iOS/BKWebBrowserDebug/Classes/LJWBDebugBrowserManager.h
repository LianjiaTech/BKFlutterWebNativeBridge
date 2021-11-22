//
//  LJWBDebugBrowserManager.h
//  LJWebBrowser
//
//  Created by 李翔宇 on 2020/8/10.
//

#import <Foundation/Foundation.h>
#import <ljtools/ljtol_singleton.h>
#import <LJFLWebBrowser/LJWebBrowser.h>

NS_ASSUME_NONNULL_BEGIN

@interface LJWBDebugBrowserManager : NSObject

LJTOL_SINGLETON_INTERFACE(LJWBDebugBrowserManager, defaultManager)

@property (nonatomic, copy, readonly) NSArray<LJWebBrowser *> *browsers;

@end

NS_ASSUME_NONNULL_END
