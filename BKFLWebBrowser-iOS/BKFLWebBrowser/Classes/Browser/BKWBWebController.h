//
//  LJWBWebController.h
//  LJWebBrowser
//
//  Created by 李翔宇 on 2020/5/21.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

typedef NS_ENUM(NSInteger, LJWBWebControllerMode) {
    LJWBWebControllerModeOrigin,
    LJWBWebControllerModeContainer,
};

NS_ASSUME_NONNULL_BEGIN

@interface BKWBWebController : UIViewController

- (instancetype)initWithMode:(LJWBWebControllerMode)mode;

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, assign) LJWBWebControllerMode mode;

@end

NS_ASSUME_NONNULL_END
