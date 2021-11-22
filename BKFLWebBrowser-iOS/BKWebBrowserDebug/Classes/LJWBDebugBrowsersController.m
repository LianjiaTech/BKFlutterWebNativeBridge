//
//  LJWBDebugBrowsersController.m
//  LJWebBrowser
//
//  Created by 李翔宇 on 2020/8/10.
//

#import "LJWBDebugBrowsersController.h"
#import "LJWBDebugBrowserManager.h"
#import "LJWBDebugBrowserController.h"

@interface LJWBDebugBrowsersController ()

@property (nonatomic, copy) NSArray<LJWebBrowser *> *browsers;

@end

@implementation LJWBDebugBrowsersController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"浏览器列表";
    _browsers = LJWBDebugBrowserManager.defaultManager.browsers;
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _browsers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LJDebugArrowCell *cell = [tableView dequeueReusableCellWithIdentifier:LJDebugArrowCellIdentifier];
    cell.textLabel.text = _browsers[indexPath.row].identifier;
    return cell;
}

@end
