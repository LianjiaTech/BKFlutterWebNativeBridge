//
//  LJWBDebugModulesController.m
//  LJWebBrowser
//
//  Created by 李翔宇 on 2020/8/10.
//

#import "LJWBDebugModulesController.h"
#import <LJBaseDebugger/LJDebugEnumMacros.h>
#import "LJWBDebugModuleController.h"

@interface LJWBDebugModulesController ()

@property (nonatomic, copy) NSArray<LJWebBrowserModule> *modules;

@end

@implementation LJWBDebugModulesController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Module列表";
    _modules = _browser.modules;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _modules.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LJDebugArrowCell *cell = [tableView dequeueReusableCellWithIdentifier:LJDebugArrowCellIdentifier];
    cell.textLabel.text = NSStringFromClass([_modules[indexPath.row] class]);
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    _modules = _browser.modules;
    [tableView reloadData];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LJWBDebugModuleController *controller = [[LJWBDebugModuleController alloc] init];
    controller.browser = _browser;
    controller.module = _modules[indexPath.row];
    [self.navigationController pushViewController:controller animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(3.0)) API_UNAVAILABLE(tvos) {
    return @"移除";
}

@end
