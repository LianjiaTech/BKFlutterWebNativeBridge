//
//  LJWBDebugWebViewsController.m
//  LJWebBrowser
//
//  Created by 李翔宇 on 2020/8/10.
//

#import "LJWBDebugWebViewsController.h"
#import <LJWebBrowser/WKWebView+LJWebBrowser.h>
#import "LJWBDebugWebViewController.h"

@interface LJWBDebugWebViewsController ()

@property (nonatomic, copy) NSArray<WKWebView *> *webViews;

@end

@implementation LJWBDebugWebViewsController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"WebView列表";
    _webViews = _browser.webViews;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _webViews.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LJDebugArrowCell *cell = [tableView dequeueReusableCellWithIdentifier:LJDebugArrowCellIdentifier];
    cell.textLabel.text = _webViews[indexPath.row].ljwb_identifier;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LJWBDebugWebViewController *controller = [[LJWBDebugWebViewController alloc] init];
    controller.webView = _webViews[indexPath.row];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
