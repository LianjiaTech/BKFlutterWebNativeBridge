//
//  LJWBModule.h
//  LJWebBrowser
//
//  Created by 李翔宇 on 2020/2/13.
//

#import <Foundation/Foundation.h>
#import "BKWebBrowser.h"

NS_ASSUME_NONNULL_BEGIN

@interface BKWBModule : NSObject<WKWebBrowserModuleProtocol, BKWebBrowserStateProtocol>

@property (atomic, assign, getter=isActived, readonly) BOOL active;
@property (nonatomic, strong, readonly) NSArray<BKWebBrowser *> *browsers;

@end

NS_ASSUME_NONNULL_END
