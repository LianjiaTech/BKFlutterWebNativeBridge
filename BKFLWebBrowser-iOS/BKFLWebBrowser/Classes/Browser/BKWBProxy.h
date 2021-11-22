//
//  LJWBProxy.h
//  LJWebBrowser
//
//  Created by 李翔宇 on 2020/2/17.
//

#import <Foundation/Foundation.h>
#import "BKWebBrowserStateProtocol.h"

@class BKWebBrowser;

NS_ASSUME_NONNULL_BEGIN

@interface BKWBProxy : NSProxy<BKWebBrowserStateProtocol>

- (id)initWithBrowser:(BKWebBrowser *)browser;

@end

NS_ASSUME_NONNULL_END
