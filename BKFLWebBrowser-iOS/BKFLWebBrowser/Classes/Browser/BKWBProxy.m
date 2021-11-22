//
//  LJWBProxy.m
//  LJBaseNetworkProber
//
//  Created by 李翔宇 on 2020/2/17.
//

#import "BKWBProxy.h"
#import <objc/runtime.h>
#import "BKWebBrowser.h"

@interface BKWBProxy()

@property(nonatomic, weak) BKWebBrowser *browser;

@end

@implementation BKWBProxy

- (void)dealloc {

}

- (id)initWithBrowser:(BKWebBrowser *)browser {
    _browser = browser;
    return self;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    for(id<BKWebBrowserStateProtocol> target in _browser.modules) {
        if([target respondsToSelector:invocation.selector]) {
            [invocation invokeWithTarget:target];
        }
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    Protocol *protocol = @protocol(BKWebBrowserStateProtocol);
    struct objc_method_description description = protocol_getMethodDescription(protocol, sel, NO, YES);
    return [NSMethodSignature signatureWithObjCTypes:description.types];
}

@end
