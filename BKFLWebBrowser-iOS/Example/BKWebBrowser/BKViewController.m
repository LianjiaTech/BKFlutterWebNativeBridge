//
//  BKViewController.m
//  BKWebBrowser
//
//  Created by 李翔宇 on 02/26/2020.
//  Copyright (c) 2020 李翔宇. All rights reserved.
//

#define LJLOG_LEVEL 0

#import "BKViewController.h"
#import <WebKit/WebKit.h>
#import <Masonry/Masonry.h>
#import <BKFLWebBrowser/BKWBBridgeManager.h>
#import <BKFLWebBrowser/BKWBFlutterManager.h>

@interface BKViewController ()
@end


@implementation BKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
            
    BKWebBrowser *browser = BKWEBBROWSER(BKWBBRIDGE, BKWBFLUTTER);
    WKWebView *webView = [browser createWebView];
    [self.view addSubview:webView];
    
    [webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_topLayoutGuide);
        make.leading.trailing.bottom.mas_equalTo(0.);
    }];
    
    NSURL *url = [NSURL URLWithString:@"http://localhost/2/#/"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    [webView loadRequest:request];
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)urlsItemAction {
    
}

@end
