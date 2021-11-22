//
//  LJWBDebugModuleController.m
//  LJWebBrowser
//
//  Created by 李翔宇 on 2020/8/10.
//

#import "LJWBDebugModuleController.h"
#import <LJBaseDebugger/LJDebugEnumMacros.h>
#import "LJWBDebugWebViewsController.h"

typedef NS_ENUM(NSInteger, LJWBDebugModuleRow) {
    LJWBDebugModuleRowAdded,
    LJWBDebugModuleRowRemoved,
    
    LJWBDebugModuleRowTotal
};

@interface LJWBDebugModuleController ()

@property (nonatomic, copy) NSArray<LJDebugItem *> *items;

@end

@implementation LJWBDebugModuleController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSStringFromClass([_module class]);
    _items = @[
        LJDEBUG_ENUM_ITEM(LJWBDebugModuleRowAdded,
                          @"注册",
                          @"在浏览器中注册模块"),
        LJDEBUG_ENUM_ITEM(LJWBDebugModuleRowAdded,
                          @"移除",
                          @"在浏览器中移除模块")
    ];
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
    switch (indexPath.row) {
        case LJWBDebugModuleRowAdded: {
            [_browser registerModule:_module];
            break;
        }
            
        case LJWBDebugModuleRowRemoved: {
            [_browser cancelModule:_module];
            break;
        }
            
        default:
            break;
    }
}

@end
