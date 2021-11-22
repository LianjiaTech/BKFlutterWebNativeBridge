//
//  LJWBDebugBrowserController.m
//  LJWebBrowser
//
//  Created by 李翔宇 on 2020/8/10.
//

#import "LJWBDebugBrowserController.h"
#import <LJBaseDebugger/LJDebugEnumMacros.h>
#import "LJWBDebugWebViewsController.h"
#import "LJWBDebugModulesController.h"

typedef NS_ENUM(NSInteger, LJWBDebugBrowserRow) {
    LJWBDebugBrowserRowIdentifier,
    LJWBDebugBrowserRowWebViews,
    LJWBDebugBrowserRowModules,

    LJWBDebugBrowserRowTotal
};

@interface LJWBDebugBrowserController ()

@property (nonatomic, copy) NSArray<LJDebugItem *> *items;

@end

@implementation LJWBDebugBrowserController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"浏览器详情";
    _items = @[LJDEBUG_ITEM(@"标识符", _browser.identifier),
               LJDEBUG_ITEM(@"全部视图", @"当前浏览器创建的全部WebView"),
               LJDEBUG_ITEM(@"全部模块", @"当前浏览器关联的全部Module")];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case LJWBDebugBrowserRowIdentifier: {
            LJDebugCell *cell = [tableView dequeueReusableCellWithIdentifier:LJDebugCellIdentifier];
            cell.textLabel.text = _items[indexPath.row].name;
            cell.detailTextLabel.text = _items[indexPath.row].desc;
            return cell;
        }
        case LJWBDebugBrowserRowWebViews: {
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
        case LJWBDebugBrowserRowWebViews: {
            LJWBDebugWebViewsController *controller = [[LJWBDebugWebViewsController alloc] init];
            controller.browser = _browser;
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
            
        case LJWBDebugBrowserRowModules: {
            LJWBDebugModulesController *controller = [[LJWBDebugModulesController alloc] init];
            controller.browser = _browser;
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
            
        default:
            break;
    }
}

@end
