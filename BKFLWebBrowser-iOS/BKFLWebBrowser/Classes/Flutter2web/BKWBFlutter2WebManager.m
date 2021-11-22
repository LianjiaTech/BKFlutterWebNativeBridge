//
//  LJWBFlutter2WebManager.m
//  AFNetworking
//
//  Created by Solo on 2020/8/18.
//

#import "BKWBFlutter2WebManager.h"

#import <BKFLWebBrowser/BKWebBrowser.h>
#import <BKFLWebBrowser/BKWBBridgeManager.h>
#import <BKFLWebBrowser/BKWBFlutterManager.h>
#import <BKFLWebBrowser/BKWBWebController.h>

NSString *const BKFlutter2WebRouterKeyDelegate = @"delegate";
NSString *const BKFlutter2WebRouterKeyAnimated = @"animated";

NSString *const BKFlutter2WebRouterKeyNavBarHidden = @"navBarHidden";
NSString *const BKFlutter2WebRouterKeyBottomBarHidden = @"bottomBarHidden";
NSString *const BKFlutter2WebRouterKeyID = @"uniqueId";
NSString *const BKFlutter2WebRouterKeyPresentStype = @"present_style";
NSString *const BKFlutter2WebRouterKeyParams = @"params";

static BKWBFlutter2WebManager *sharedInstance = nil;

@interface BKWBFlutter2WebManager()

@end

@implementation BKWBFlutter2WebManager

+ (BKWBFlutter2WebManager *)sharedInstance {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BKWBFlutter2WebManager alloc] init];
    });
    
    return sharedInstance;
}

- (WKWebView *)createWebViewPackageHost:(NSString *)host url:(NSString *)urlPath {
 
    BKWebBrowser *browser = BKWEBBROWSER(BKWBBRIDGE, BKWBFLUTTER);
    
    WKWebViewConfiguration *configuration = BKWebBrowser.defaultBrowser.configurationManager.configuration;

    WKWebView  *webView = [browser createWebViewWithConfiguration:configuration];

   dispatch_async(dispatch_get_main_queue(), ^{
       
       NSString *urlString = [NSString stringWithFormat:@"%@/%@", host, urlPath?:@"#"];
       NSURL *url = [NSURL URLWithString:urlString];
       NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
       request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
       [webView loadRequest:request];
       
   });
    
    return webView;
}

@end
