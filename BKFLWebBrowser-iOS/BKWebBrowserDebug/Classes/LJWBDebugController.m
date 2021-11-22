//
//  LJWBDebugController.m
//  LJWebBrowser
//
//  Created by 李翔宇 on 2020/8/5.
//

#import "LJWBDebugController.h"
#import <LJBaseDebugger/LJDebugEnumMacros.h>
#import "LJWBDebugBrowsersController.h"
#import "LJWBTestController.h"

@interface LJWBDebugController ()

@property (nonatomic, copy) NSArray<LJDebugItem *> *items;

@end

@interface LJWBDebugController ()

@end

@implementation LJWBDebugController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"调试";
    
    _items = @[LJDEBUG_ITEM_CONTROLLER(@"Browser列表",
                                       @"",
                                       LJWBDebugBrowsersController),
               LJDEBUG_ITEM_CONTROLLER(@"测试",
                                       @"",
                                       LJWBTestController)];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LJDebugArrowCell *cell = [tableView dequeueReusableCellWithIdentifier:LJDebugArrowCellIdentifier];
    cell.textLabel.text = _items[indexPath.row].name;
    cell.detailTextLabel.text = _items[indexPath.row].desc;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Class cls = _items[indexPath.row].cluss;
    UIViewController *controller = [[cls alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Load

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [UIApplication ljdebug_registerPath:@"/browser" forController:[self class]];
    });
}

@end
