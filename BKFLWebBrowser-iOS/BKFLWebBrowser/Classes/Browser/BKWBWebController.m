//
//  LJWBWebController.m
//  LJWebBrowser
//
//  Created by 李翔宇 on 2020/5/21.
//

#import "BKWBWebController.h"
#import <Masonry/Masonry.h>
#import "BKWebBrowser.h"
#import <BKFLWebBrowser/BKWBBridgeManager.h>

@interface BKWBWebController ()

@end

@implementation BKWBWebController

- (instancetype)initWithMode:(LJWBWebControllerMode)mode {
    self = [super init];
    if(self) {
        _webView = [BKWebBrowser.defaultBrowser createWebView];
        _mode = mode;
    }
    return self;
}

- (void)loadView {
    if(_mode == LJWBWebControllerModeOrigin) {
        self.view = _webView;
    } else {
        [super loadView];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(_mode == LJWBWebControllerModeContainer) {
        [self.view addSubview:_webView];
        
        if (@available(iOS 11.0, *)) {
            
            NSLog(@"pppp: %@", NSStringFromUIEdgeInsets(self.view.safeAreaInsets));
            [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(self.view.safeAreaInsets);
            }];
                   
        } else {

             [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
                                   make.edges.mas_equalTo(0.);
                               }];
        }

    }
}

@end
