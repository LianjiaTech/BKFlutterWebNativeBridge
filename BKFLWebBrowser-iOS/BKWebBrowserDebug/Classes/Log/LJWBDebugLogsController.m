//
//  LJWBDebugLogsController.m
//  LJWebBrowser
//
//  Created by 李翔宇 on 2020/8/5.
//

#import "LJWBDebugLogsController.h"
#import <LJFLWebBrowser/WKWebView+LJWebBrowser.h>
#import "LJWBDebugLogManager.h"

@interface LJWBDebugLogsController ()

@property (nonatomic, strong) NSMutableArray<NSString *> *logsM;

@end

@implementation LJWBDebugLogsController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"日志";
    _logsM = [LJWBDebugLogManager.defaultManager logsInWebView:_webView.ljwb_identifier];
}

#pragma mark - UITableviewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _logsM.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LJDebugCell *cell = [tableView dequeueReusableCellWithIdentifier:LJDebugCellIdentifier];
    cell.textLabel.text = _logsM[indexPath.row];
    return cell;
}

@end
