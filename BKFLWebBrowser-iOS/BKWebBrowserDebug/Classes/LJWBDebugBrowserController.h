//
//  LJWBDebugBrowserController.h
//  LJWebBrowser
//
//  Created by 李翔宇 on 2020/8/10.
//

#import "LJDebugController.h"
#import <LJFLWebBrowser/LJWebBrowser.h>

NS_ASSUME_NONNULL_BEGIN

@interface LJWBDebugBrowserController : LJDebugController

@property (nonatomic, strong) LJWebBrowser *browser;

@end

NS_ASSUME_NONNULL_END
