//
//  LJWBLocalServerEnvConfig.m
//  LJWebBrowser
//
//  Created by ZhaoXM on 2020/8/11.
//

#import "LJWBLocalServerEnvConfig.h"

#if PACKAGE_TYPE_PRODUCTION

BOOL LJWBLocalServerIsDebug = NO;

#elif PACKAGE_TYPE_ENTERPRISE || PACKAGE_TYPE_ADHOC || PACKAGE_TYPE_DEVELOPER || DEBUG

BOOL LJWBLocalServerIsDebug = YES;

#else

BOOL LJWBLocalServerIsDebug = NO;

#endif
