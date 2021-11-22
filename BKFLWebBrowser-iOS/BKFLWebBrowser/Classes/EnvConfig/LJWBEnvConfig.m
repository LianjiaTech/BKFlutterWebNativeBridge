//
//  LJWBEnvConfig.m
//  LJWebBrowser
//
//  Created by bigGuang on 2019/8/12.
//

#import "LJWBEnvConfig.h"

#if PACKAGE_TYPE_PRODUCTION

BOOL LJWebBrowserIsDebug = NO;

#elif PACKAGE_TYPE_ENTERPRISE || PACKAGE_TYPE_ADHOC || PACKAGE_TYPE_DEVELOPER || DEBUG

BOOL LJWebBrowserIsDebug = NO;

#else

BOOL LJWebBrowserIsDebug = NO;

#endif

