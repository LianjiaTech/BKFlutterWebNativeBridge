//
//  LJWBUIDelegateProxy.m
//  LJWebBrowser
//
//  Created by 李翔宇 on 2020/5/21.
//

#import "BKWBUIDelegateProxy.h"
#import "BKWebBrowser.h"

@interface BKWBUIDelegateProxy()
{
    __weak id _delegate;
}

@property (nonatomic, strong) id<BKWebBrowserStateProtocol> browser;

@end

@implementation BKWBUIDelegateProxy

- (void)dealloc {

}

- (id)initWithDelegate:(id<WKUIDelegate>)delegate browser:(id<BKWebBrowserStateProtocol>)browser {
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
    if(aSelector == @selector(webView:createWebViewWithConfiguration:forNavigationAction:windowFeatures:)
       || aSelector == @selector(webViewDidClose:)
       || aSelector == @selector(webView:runJavaScriptAlertPanelWithMessage:initiatedByFrame:completionHandler:)
       || aSelector == @selector(webView:runJavaScriptConfirmPanelWithMessage:initiatedByFrame:completionHandler:)
       || aSelector == @selector(webView:runJavaScriptTextInputPanelWithPrompt:defaultText:initiatedByFrame:completionHandler:)) {
        return YES;
    }
    
    if(@available(iOS 10.0, *)) {
        if(aSelector == @selector(webView:shouldPreviewElement:)
           || aSelector == @selector(webView:previewingViewControllerForElement:defaultActions:)
           || aSelector == @selector(webView:commitPreviewingViewController:)) {
            return YES;
        }
    }
    
    if(@available(iOS 13.0, *)) {
        if(aSelector == @selector(webView:contextMenuConfigurationForElement:completionHandler:)
           || aSelector == @selector(webView:contextMenuWillPresentForElement:)
           || aSelector == @selector(webView:contextMenuForElement:willCommitWithAnimator:)
           || aSelector == @selector(webView:contextMenuDidEndForElement:)) {
            return YES;
        }
    }
    
    return [_delegate respondsToSelector:aSelector];
}

#pragma mark - WKUIDelegate

/*! @abstract Creates a new web view.
 @param webView The web view invoking the delegate method.
 @param configuration The configuration to use when creating the new web
 view. This configuration is a copy of webView.configuration.
 @param navigationAction The navigation action causing the new web view to
 be created.
 @param windowFeatures Window features requested by the webpage.
 @result A new web view or nil.
 @discussion The web view returned must be created with the specified configuration. WebKit will load the request in the returned web view.

 If you do not implement this method, the web view will cancel the navigation.
 */
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {

    if([_delegate respondsToSelector:_cmd]) {
        return [_delegate webView:webView createWebViewWithConfiguration:configuration
            forNavigationAction:navigationAction
                 windowFeatures:windowFeatures];
    } else {
        return nil;
    }
}

/*! @abstract Notifies your app that the DOM window object's close() method completed successfully.
  @param webView The web view invoking the delegate method.
  @discussion Your app should remove the web view from the view hierarchy and update
  the UI as needed, such as by closing the containing browser tab or window.
  */
- (void)webViewDidClose:(WKWebView *)webView API_AVAILABLE(macos(10.11), ios(9.0)) {
    
    if([_delegate respondsToSelector:_cmd]) {
        [_delegate webViewDidClose:webView];
    }
}

/*! @abstract Displays a JavaScript alert panel.
 @param webView The web view invoking the delegate method.
 @param message The message to display.
 @param frame Information about the frame whose JavaScript initiated this
 call.
 @param completionHandler The completion handler to call after the alert
 panel has been dismissed.
 @discussion For user security, your app should call attention to the fact
 that a specific website controls the content in this panel. A simple forumla
 for identifying the controlling website is frame.request.URL.host.
 The panel should have a single OK button.

 If you do not implement this method, the web view will behave as if the user selected the OK button.
 */
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    if([_delegate respondsToSelector:_cmd]) {
        [_delegate webView:webView runJavaScriptAlertPanelWithMessage:message initiatedByFrame:frame completionHandler:completionHandler];
    } else {
        //TODO: 弹个窗
        
        completionHandler();
    }
}

/*! @abstract Displays a JavaScript confirm panel.
 @param webView The web view invoking the delegate method.
 @param message The message to display.
 @param frame Information about the frame whose JavaScript initiated this call.
 @param completionHandler The completion handler to call after the confirm
 panel has been dismissed. Pass YES if the user chose OK, NO if the user
 chose Cancel.
 @discussion For user security, your app should call attention to the fact
 that a specific website controls the content in this panel. A simple forumla
 for identifying the controlling website is frame.request.URL.host.
 The panel should have two buttons, such as OK and Cancel.

 If you do not implement this method, the web view will behave as if the user selected the Cancel button.
 */
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    
    if([_delegate respondsToSelector:_cmd]) {
        [_delegate webView:webView runJavaScriptConfirmPanelWithMessage:message initiatedByFrame:frame completionHandler:completionHandler];
    } else {
        //TODO: 弹个窗
        
        completionHandler(YES);
    }
}

/*! @abstract Displays a JavaScript text input panel.
 @param webView The web view invoking the delegate method.
 @param prompt The prompt to display.
 @param defaultText The initial text to display in the text entry field.
 @param frame Information about the frame whose JavaScript initiated this call.
 @param completionHandler The completion handler to call after the text
 input panel has been dismissed. Pass the entered text if the user chose
 OK, otherwise nil.
 @discussion For user security, your app should call attention to the fact
 that a specific website controls the content in this panel. A simple forumla
 for identifying the controlling website is frame.request.URL.host.
 The panel should have two buttons, such as OK and Cancel, and a field in
 which to enter text.

 If you do not implement this method, the web view will behave as if the user selected the Cancel button.
 */
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable result))completionHandler {
    
    if([_delegate respondsToSelector:_cmd]) {
        [_delegate webView:webView runJavaScriptTextInputPanelWithPrompt:prompt defaultText:defaultText initiatedByFrame:frame completionHandler:completionHandler];
    } else {
        //TODO: 弹个窗
        
        completionHandler(@"");
    }
}

#if TARGET_OS_IPHONE

/*! @abstract Allows your app to determine whether or not the given element should show a preview.
 @param webView The web view invoking the delegate method.
 @param elementInfo The elementInfo for the element the user has started touching.
 @discussion To disable previews entirely for the given element, return NO. Returning NO will prevent
 webView:previewingViewControllerForElement:defaultActions: and webView:commitPreviewingViewController:
 from being invoked.
 
 This method will only be invoked for elements that have default preview in WebKit, which is
 limited to links. In the future, it could be invoked for additional elements.
 */
- (BOOL)webView:(WKWebView *)webView shouldPreviewElement:(WKPreviewElementInfo *)elementInfo API_DEPRECATED_WITH_REPLACEMENT("webView:contextMenuConfigurationForElement:completionHandler:", ios(10.0, 13.0)) {
    
    if([_delegate respondsToSelector:_cmd]) {
        return [_delegate webView:webView shouldPreviewElement:elementInfo];
    } else {
        return NO;
    }
}

/*! @abstract Allows your app to provide a custom view controller to show when the given element is peeked.
 @param webView The web view invoking the delegate method.
 @param elementInfo The elementInfo for the element the user is peeking.
 @param previewActions An array of the actions that WebKit would use as previewActionItems for this element by
 default. These actions would be used if allowsLinkPreview is YES but these delegate methods have not been
 implemented, or if this delegate method returns nil.
 @discussion Returning a view controller will result in that view controller being displayed as a peek preview.
 To use the defaultActions, your app is responsible for returning whichever of those actions it wants in your
 view controller's implementation of -previewActionItems.
 
 Returning nil will result in WebKit's default preview behavior. webView:commitPreviewingViewController: will only be invoked
 if a non-nil view controller was returned.
 */
- (nullable UIViewController *)webView:(WKWebView *)webView previewingViewControllerForElement:(WKPreviewElementInfo *)elementInfo defaultActions:(NSArray<id <WKPreviewActionItem>> *)previewActions API_DEPRECATED_WITH_REPLACEMENT("webView:contextMenuConfigurationForElement:completionHandler:", ios(10.0, 13.0)) {
    
    if([_delegate respondsToSelector:_cmd]) {
        return [_delegate webView:webView previewingViewControllerForElement:elementInfo defaultActions:previewActions];
    } else {
        return nil;
    }
}

/*! @abstract Allows your app to pop to the view controller it created.
 @param webView The web view invoking the delegate method.
 @param previewingViewController The view controller that is being popped.
 */
- (void)webView:(WKWebView *)webView commitPreviewingViewController:(UIViewController *)previewingViewController API_DEPRECATED_WITH_REPLACEMENT("webView:contextMenuForElement:willCommitWithAnimator:", ios(10.0, 13.0)) {
    
    if([_delegate respondsToSelector:_cmd]) {
        [_delegate webView:webView commitPreviewingViewController:previewingViewController];
    }
}

#endif // TARGET_OS_IPHONE

#if TARGET_OS_IOS

/**
 * @abstract Called when a context menu interaction begins.
 *
 * @param webView The web view invoking the delegate method.
 * @param elementInfo The elementInfo for the element the user is touching.
 * @param completionHandler A completion handler to call once a it has been decided whether or not to show a context menu.
 * Pass a valid UIContextMenuConfiguration to show a context menu, or pass nil to not show a context menu.
 */
- (void)webView:(WKWebView *)webView contextMenuConfigurationForElement:(WKContextMenuElementInfo *)elementInfo completionHandler:(void (^)(UIContextMenuConfiguration * _Nullable configuration))completionHandler API_AVAILABLE(ios(13.0)) {
    
    if([_delegate respondsToSelector:_cmd]) {
        [_delegate webView:webView contextMenuConfigurationForElement:elementInfo completionHandler:completionHandler];
    } else {
        //TODO:创建UIContextMenuConfiguration
        completionHandler(nil);
    }
}

/**
 * @abstract Called when the context menu will be presented.
 *
 * @param webView The web view invoking the delegate method.
 * @param elementInfo The elementInfo for the element the user is touching.
 */
- (void)webView:(WKWebView *)webView contextMenuWillPresentForElement:(WKContextMenuElementInfo *)elementInfo API_AVAILABLE(ios(13.0)) {
    
    if([_delegate respondsToSelector:_cmd]) {
        [_delegate webView:webView contextMenuWillPresentForElement:elementInfo];
    }
}

/**
 * @abstract Called when the context menu configured by the UIContextMenuConfiguration from
 * webView:contextMenuConfigurationForElement:completionHandler: is committed. That is, when
 * the user has selected the view provided in the UIContextMenuContentPreviewProvider.
 *
 * @param webView The web view invoking the delegate method.
 * @param elementInfo The elementInfo for the element the user is touching.
 * @param animator The animator to use for the commit animation.
 */
- (void)webView:(WKWebView *)webView contextMenuForElement:(WKContextMenuElementInfo *)elementInfo willCommitWithAnimator:(id <UIContextMenuInteractionCommitAnimating>)animator API_AVAILABLE(ios(13.0)) {
    
    if([_delegate respondsToSelector:_cmd]) {
        [_delegate webView:webView contextMenuForElement:elementInfo willCommitWithAnimator:animator];
    }
}

/**
 * @abstract Called when the context menu ends, either by being dismissed or when a menu action is taken.
 *
 * @param webView The web view invoking the delegate method.
 * @param elementInfo The elementInfo for the element the user is touching.
 */
- (void)webView:(WKWebView *)webView contextMenuDidEndForElement:(WKContextMenuElementInfo *)elementInfo API_AVAILABLE(ios(13.0)) {
    
    if([_delegate respondsToSelector:_cmd]) {
        [_delegate webView:webView contextMenuDidEndForElement:elementInfo];
    }
}

#endif // TARGET_OS_IOS

#if !TARGET_OS_IPHONE

/*! @abstract Displays a file upload panel.
 @param webView The web view invoking the delegate method.
 @param parameters Parameters describing the file upload control.
 @param frame Information about the frame whose file upload control initiated this call.
 @param completionHandler The completion handler to call after open panel has been dismissed. Pass the selected URLs if the user chose OK, otherwise nil.

 If you do not implement this method, the web view will behave as if the user selected the Cancel button.
 */
- (void)webView:(WKWebView *)webView runOpenPanelWithParameters:(WKOpenPanelParameters *)parameters initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSArray<NSURL *> * _Nullable URLs))completionHandler API_AVAILABLE(macos(10.12)) {
    
    if([_delegate respondsToSelector:_cmd]) {
        [_delegate webView:webView runOpenPanelWithParameters:parameters initiatedByFrame:frame completionHandler:completionHandler];
    } else {
        completionHandler(nil);
    }
}

#endif

@end
