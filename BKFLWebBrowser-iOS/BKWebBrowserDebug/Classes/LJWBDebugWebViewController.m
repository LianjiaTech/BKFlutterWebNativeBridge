//
//  LJWBDebugWebViewController.m
//  LJWebBrowser
//
//  Created by 李翔宇 on 2020/8/10.
//

#import "LJWBDebugWebViewController.h"
#import <LJBaseDebugger/LJDebugEnumMacros.h>
#import <LJFLWebBrowser/WKWebView+LJWebBrowser.h>
#import "LJWBDebugLogsController.h"

typedef NS_ENUM(NSInteger, LJWBDebugWebViewRow) {
    LJWBDebugWebViewRowIdentifier,
    LJWBDebugWebViewRowBridge,
    LJWBDebugWebViewRowLogs,

    LJWBDebugWebViewRowTotal
};

@interface LJWBDebugWebViewController ()

@property (nonatomic, copy) NSArray<LJDebugItem *> *items;

@end

@implementation LJWBDebugWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"WebView详情";
    _items = @[LJDEBUG_ITEM(@"标识符", _webView.ljwb_identifier),
               LJDEBUG_ITEM(@"Bridge",
                            @"桥接管理器"),
               LJDEBUG_ITEM(@"日志",
                            @"通过console打印的全部日志")];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case LJWBDebugWebViewRowIdentifier: {
            LJDebugCell *cell = [tableView dequeueReusableCellWithIdentifier:LJDebugCellIdentifier];
            cell.textLabel.text = _items[indexPath.row].name;
            cell.detailTextLabel.text = _items[indexPath.row].desc;
            return cell;
        }
        case LJWBDebugWebViewRowBridge: {
            LJDebugArrowCell *cell = [tableView dequeueReusableCellWithIdentifier:LJDebugArrowCellIdentifier];
            cell.textLabel.text = _items[indexPath.row].name;
            cell.detailTextLabel.text = _items[indexPath.row].desc;
            return cell;
        }
        case LJWBDebugWebViewRowLogs: {
            LJDebugArrowCell *cell = [tableView dequeueReusableCellWithIdentifier:LJDebugArrowCellIdentifier];
            cell.textLabel.text = _items[indexPath.row].name;
            cell.detailTextLabel.text = _items[indexPath.row].desc;
            return cell;
        }
        default: {
            return [super tableView:tableView cellForRowAtIndexPath:indexPath];
        }
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case LJWBDebugWebViewRowLogs: {
            LJWBDebugLogsController *controller = [[LJWBDebugLogsController alloc] init];
            controller.webView = _webView;
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }

        default:
            break;
    }
}

@end
