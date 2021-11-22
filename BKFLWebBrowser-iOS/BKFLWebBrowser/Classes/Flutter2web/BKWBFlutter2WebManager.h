//
//  LJWBFlutter2WebManager.h
//  AFNetworking
//
//  Created by Solo on 2020/8/18.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BKWBFlutter2WebManager : NSObject

+ (BKWBFlutter2WebManager *)sharedInstance;

- (WKWebView *)createWebViewPackageHost:(NSString *)host url:(NSString *)urlPath;

@end

NS_ASSUME_NONNULL_END
