//
//  WebViewController.h
//  Runner
//
//  Created by Solo on 2021/8/30.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WebViewController : UIViewController

@property (nonatomic, strong) WKWebView *webView;

@end

NS_ASSUME_NONNULL_END
