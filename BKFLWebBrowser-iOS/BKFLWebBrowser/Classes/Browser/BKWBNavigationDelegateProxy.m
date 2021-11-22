//
//  LJWBNavigationDelegateProxy.m
//  LJWebBrowser
//
//  Created by 李翔宇 on 2020/5/21.
//

#import "BKWBNavigationDelegateProxy.h"
#import "BKWebBrowser.h"

@interface BKWBNavigationDelegateProxy()
{
    __weak id _delegate;
}

@property (nonatomic, strong) id<BKWebBrowserStateProtocol> browser;

@end

@implementation BKWBNavigationDelegateProxy

- (void)dealloc {

}

- (id)initWithDelegate:(id<WKNavigationDelegate>)delegate browser:(id<BKWebBrowserStateProtocol>)browser {
    _delegate = delegate;
    _browser = browser;
    return self;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    if ([_delegate respondsToSelector:invocation.selector]) {
        [invocation invokeWithTarget:_delegate];
    } else {

    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    if ([_delegate respondsToSelector:sel]) {
        return [_delegate methodSignatureForSelector:sel];
    } else {
        return nil;
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    
    if(aSelector == @selector(webView:decidePolicyForNavigationAction:decisionHandler:)
       || aSelector == @selector(webView:decidePolicyForNavigationResponse:decisionHandler:)
       || aSelector == @selector(webView:didStartProvisionalNavigation:)
       || aSelector == @selector(webView:didReceiveServerRedirectForProvisionalNavigation:)
       || aSelector == @selector(webView:didFailProvisionalNavigation:withError:)
       || aSelector == @selector(webView:didCommitNavigation:)
       || aSelector == @selector(webView:didFinishNavigation:)
       || aSelector == @selector(webView:didFailNavigation:withError:)
       || aSelector == @selector(webViewWebContentProcessDidTerminate:)) {
        return YES;
    }

    if(@available(iOS 13.0, *)) {
        if(aSelector == @selector(webView:decidePolicyForNavigationAction:preferences:decisionHandler:)) {
            return NO;
        }
    }
    
#ifdef LJWEBBROWSER_EXAMPLE_PROJECT
    
    if(aSelector == @selector(webView:didReceiveAuthenticationChallenge:completionHandler:)) {
        return NO;
    }
    
#endif
    
    return [_delegate respondsToSelector:aSelector];
}

#pragma mark - WKNavigationDelegate

/*! @abstract Decides whether to allow or cancel a navigation.
 @param webView The web view invoking the delegate method.
 @param navigationAction Descriptive information about the action
 triggering the navigation request.
 @param decisionHandler The decision handler to call to allow or cancel the
 navigation. The argument is one of the constants of the enumerated type WKNavigationActionPolicy.
 @discussion If you do not implement this method, the web view will load the request or, if appropriate, forward it to another application.
 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {

    
    if([_delegate respondsToSelector:_cmd]) {
        [_delegate webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

/*! @abstract Decides whether to allow or cancel a navigation.
 @param webView The web view invoking the delegate method.
 @param navigationAction Descriptive information about the action
 triggering the navigation request.
 @param preferences The default set of webpage preferences. This may be
 changed by setting defaultWebpagePreferences on WKWebViewConfiguration.
 @param decisionHandler The policy decision handler to call to allow or cancel
 the navigation. The arguments are one of the constants of the enumerated type
 WKNavigationActionPolicy, as well as an instance of WKWebpagePreferences.
 @discussion If you implement this method,
 -webView:decidePolicyForNavigationAction:decisionHandler: will not be called.
 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction preferences:(WKWebpagePreferences *)preferences decisionHandler:(void (^)(WKNavigationActionPolicy, WKWebpagePreferences *))decisionHandler API_AVAILABLE(macos(10.15), ios(13.0)) {

    
    if([_delegate respondsToSelector:_cmd]) {
        [_delegate webView:webView decidePolicyForNavigationAction:navigationAction preferences:preferences decisionHandler:decisionHandler];
    } else if([_delegate respondsToSelector:@selector(webView:decidePolicyForNavigationAction:decisionHandler:)]) {
        [_delegate webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:^(WKNavigationActionPolicy policy) {
            decisionHandler(policy, preferences);
        }];
    } else {
        decisionHandler(WKNavigationActionPolicyAllow, preferences);
    }
}

/*! @abstract Decides whether to allow or cancel a navigation after its
 response is known.
 @param webView The web view invoking the delegate method.
 @param navigationResponse Descriptive information about the navigation
 response.
 @param decisionHandler The decision handler to call to allow or cancel the
 navigation. The argument is one of the constants of the enumerated type WKNavigationResponsePolicy.
 @discussion If you do not implement this method, the web view will allow the response, if the web view can show it.
 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {

    
    if([_delegate respondsToSelector:_cmd]) {
        [_delegate webView:webView decidePolicyForNavigationResponse:navigationResponse decisionHandler:decisionHandler];
    } else {
        decisionHandler(WKNavigationResponsePolicyAllow);
    }
}

/*! @abstract Invoked when a main frame navigation starts.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 */
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    
    if([_delegate respondsToSelector:_cmd]) {
        [_delegate webView:webView didStartProvisionalNavigation:navigation];
    }
}

/*! @abstract Invoked when a server redirect is received for the main
 frame.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 */
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    
    if([_delegate respondsToSelector:_cmd]) {
        [_delegate webView:webView didReceiveServerRedirectForProvisionalNavigation:navigation];
    }
}

/*! @abstract Invoked when an error occurs while starting to load data for
 the main frame.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 @param error The error that occurred.
 */
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    
    if([_delegate respondsToSelector:_cmd]) {
        [_delegate webView:webView didFailProvisionalNavigation:navigation withError:error];
    }
}

/*! @abstract Invoked when content starts arriving for the main frame.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 */
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    
    if([_delegate respondsToSelector:_cmd]) {
        [_delegate webView:webView didCommitNavigation:navigation];
    }
}

/*! @abstract Invoked when a main frame navigation completes.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 */
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    
    if([_delegate respondsToSelector:_cmd]) {
        [_delegate webView:webView didFinishNavigation:navigation];
    }
}

/*! @abstract Invoked when an error occurs during a committed main frame
 navigation.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 @param error The error that occurred.
 */
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    
    if([_delegate respondsToSelector:_cmd]) {
        [_delegate webView:webView didFailNavigation:navigation withError:error];
    }
}

/*! @abstract Invoked when the web view needs to respond to an authentication challenge.
 @param webView The web view that received the authentication challenge.
 @param challenge The authentication challenge.
 @param completionHandler The completion handler you must invoke to respond to the challenge. The
 disposition argument is one of the constants of the enumerated type
 NSURLSessionAuthChallengeDisposition. When disposition is NSURLSessionAuthChallengeUseCredential,
 the credential argument is the credential to use, or nil to indicate continuing without a
 credential.
 @discussion If you do not implement this method, the web view will respond to the authentication challenge with the NSURLSessionAuthChallengeRejectProtectionSpace disposition.
 */
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    
    if([_delegate respondsToSelector:_cmd]) {
        [_delegate webView:webView didReceiveAuthenticationChallenge:challenge completionHandler:completionHandler];
    } else {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}

/*! @abstract Invoked when the web view's web content process is terminated.
 @param webView The web view whose underlying web content process was terminated.
 */
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView API_AVAILABLE(macos(10.11), ios(9.0)) {
    
    if([_delegate respondsToSelector:_cmd]) {
        [_delegate webViewWebContentProcessDidTerminate:webView];
    }
}

@end
