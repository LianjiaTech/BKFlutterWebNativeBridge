//
//  LJWBModule.m
//  LJWebBrowser
//
//  Created by 李翔宇 on 2020/2/13.
//

#import "BKWBModule.h"

@interface BKWBModule ()

@property (nonatomic, strong) NSHashTable<BKWebBrowser *> *browsersM;
@property (atomic, assign, getter=isActived) BOOL active;

@end

@implementation BKWBModule

- (instancetype)init {
    self = [super init];
    if(self) {
        _browsersM = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

- (NSArray<BKWebBrowser *> *)browsers {
    return _browsersM.allObjects;
}

#pragma mark - WKWebBrowserModuleProtocol

- (void)ljwb_addedToBrowser:(BKWebBrowser *)browser {
    if(![browser isKindOfClass:[BKWebBrowser class]]) {
        return;
    }
    
    if([_browsersM containsObject:browser]) {
        return;
    }
    
    [_browsersM addObject:browser];
    
    if(self.isActived) {
        return;
    }
    
    self.active = _browsersM.count;
}

- (void)ljwb_removedFromBrowser:(BKWebBrowser *)browser {
    if(![browser isKindOfClass:[BKWebBrowser class]]) {
        return;
    }
    
    if(![_browsersM containsObject:browser]) {
        return;
    }
    
    [_browsersM removeObject:browser];
    
    if(!self.isActived) {
        return;
    }
    
    self.active = _browsersM.count;
}

- (void)ljwb_addedModule:(id<WKWebBrowserModuleProtocol>)module toBrowser:(BKWebBrowser *)browser {
    //
}

- (void)ljwb_removedModule:(id<WKWebBrowserModuleProtocol>)module fromBrowser:(BKWebBrowser *)browser {
    //
}

@end
