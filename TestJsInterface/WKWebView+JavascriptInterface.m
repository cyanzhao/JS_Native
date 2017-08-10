
//
//  WKWebView+JavascriptInterface.m
//  gezilicai
//
//  Created by cuiyan on 16/11/9.
//  Copyright © 2016年 yuexue. All rights reserved.
//

#import "WKWebView+JavascriptInterface.h"
#import "MethodSweeze.h"

#define JAVASCRIPTINTERFACE "_javascriptInterface"
#define DELEGATE "_delegate"
#define NAVIGATIONDELEGATE "_navigationDelegate"
#define WKSCRIPTMESSAGEHANDLER "_wKScriptMessageHandler"

@implementation WKUserContentController(JavascriptInterface)

+ (void)load{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [MethodSweeze swizzleSelector:@selector(wk_addScriptMessageHandler:name:) withTargetSelector:@selector(addScriptMessageHandler:name:) class:[self class]];
        [MethodSweeze swizzleSelector:@selector(wk_init) withTargetSelector:@selector(init) class:[self class]];
    });
}

- (instancetype)wk_init{
    
    if ([self wk_init]) {
        
        [self addScriptMessageHandler:nil name:nil];
        [self initJSInterface];
    }
    return self;
}

- (void)initJSInterface{
    
    JavascriptInterface *interface = [JavascriptInterface sharedJSInterface];
    [self setJSInterface:interface];
}

- (void)setJSInterface:(JavascriptInterface *)interface{
    
    objc_setAssociatedObject(self, JAVASCRIPTINTERFACE, interface, OBJC_ASSOCIATION_ASSIGN);
}

- (JavascriptInterface *)getJSInterface{
    
    return objc_getAssociatedObject(self, JAVASCRIPTINTERFACE);
}

- (void)wk_addScriptMessageHandler:(id<WKScriptMessageHandler>)scriptMessageHandler name:(NSString *)name{
	
    if (scriptMessageHandler && scriptMessageHandler != self){
        [self setWKScriptMessageHandler:scriptMessageHandler];
    }
    if (name != nil) {
        [self wk_addScriptMessageHandler:self name:name];
    }
    JavascriptInterface *interface = [self getJSInterface];
    if (interface) {
        interface.interfaceName = name;
    }
}

- (void)setWKScriptMessageHandler:(id<WKScriptMessageHandler>)handler{
    
    objc_setAssociatedObject(self, WKSCRIPTMESSAGEHANDLER, handler, OBJC_ASSOCIATION_ASSIGN);
}

- (id<WKScriptMessageHandler>)getWKScriptMessageHandler{
    
    return objc_getAssociatedObject(self, WKSCRIPTMESSAGEHANDLER);
}

#pragma mark -- script message handler delegate
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    
    JavascriptInterface *interface = [self getJSInterface];
    id<WKScriptMessageHandler> msgHandler = [self getWKScriptMessageHandler];
    NSString* urlStr = [NSString stringWithString:message.body];
    NSURL* url = [NSURL URLWithString:[urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
    
    if ((interface == nil || (interface != nil && [interface handleInjectedJSMethod:url])) &&
        [msgHandler respondsToSelector:@selector(userContentController:didReceiveScriptMessage:)]){
        [msgHandler userContentController:userContentController didReceiveScriptMessage:message];
    }
}

@end

@interface WKWebView ()

@end

@implementation WKWebView (JavascriptInterface)

+ (void)load{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        //方法交换
        [MethodSweeze swizzleSelector:@selector(wk_initWithFrame:configuration:) withTargetSelector:@selector(initWithFrame:configuration:) class:[self class]];
        [MethodSweeze swizzleSelector:@selector(wk_initWithCoder:) withTargetSelector:@selector(initWithCoder:) class:[self class]];
        [MethodSweeze swizzleSelector:@selector(wk_setUIDelegate:) withTargetSelector:@selector(setUIDelegate:) class:[self class]];
        [MethodSweeze swizzleSelector:@selector(wk_setNavigationDelegate:) withTargetSelector:@selector(setNavigationDelegate:) class:[self class]];
    });
}

- (void)initJSInterface{
    
//    JavascriptInterface *javaInterface = [[JavascriptInterface alloc]init];
    JavascriptInterface *javaInterface = [JavascriptInterface sharedJSInterface];
    [self setInterfaceProvider:javaInterface];
}

- (void)setInterfaceProvider:(JavascriptInterface *)inteface{
    
    objc_setAssociatedObject(self, JAVASCRIPTINTERFACE, inteface, OBJC_ASSOCIATION_ASSIGN);
}

- (JavascriptInterface *)getInterfaceProvider{
    
    return objc_getAssociatedObject(self, JAVASCRIPTINTERFACE);
}


- (void)addJavascritInetrface:(id<InterfaceProvider>)tarfer name:(NSString *)commonName{
    
    JavascriptInterface *inferface = [self getInterfaceProvider];
    inferface.webView = self;
    inferface.interfaceProvider = tarfer;
    inferface.interfaceName = commonName;
}

- (instancetype)wk_initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration{
    
    if ([self wk_initWithFrame:frame configuration:configuration]) {
        
        [self setUIDelegate:nil];
        [self setNavigationDelegate:nil];
        [self initJSInterface];
    }
    
    return self;
}

- (instancetype)wk_initWithCoder:(NSCoder *)coder{

    if ([self wk_initWithCoder:coder]) {
     
        [self setUIDelegate:nil];
        [self setNavigationDelegate:nil];
        [self initJSInterface];
    }
    
    return self;
}

- (void)wk_setUIDelegate:(id<WKUIDelegate>)UIDelegate{
    
    if (UIDelegate == nil) {
        [self wk_setUIDelegate:self];
    }else if(UIDelegate != self){
        
        objc_setAssociatedObject(self, DELEGATE, UIDelegate, OBJC_ASSOCIATION_ASSIGN);
    }
}

- (id<WKUIDelegate>)wk_getUIDelegate{
    
    return objc_getAssociatedObject(self, DELEGATE);
}

- (void)wk_setNavigationDelegate:(id<WKNavigationDelegate>)UIDelegate{
    
    if (UIDelegate == nil) {
        [self wk_setNavigationDelegate:self];
    }else if(UIDelegate != self){
        objc_setAssociatedObject(self, NAVIGATIONDELEGATE, UIDelegate, OBJC_ASSOCIATION_ASSIGN);
    }
}

- (id<WKNavigationDelegate>)wk_getNavigationDelegate{
    
    return objc_getAssociatedObject(self, NAVIGATIONDELEGATE);
}


#pragma mark-- IWebview Delegate
- (NSString *)evaluatingJavascript:(NSString *)script{
    [self evaluateJavaScript:script completionHandler:^(id _Nullable para, NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@",error);
        }
    }];
    return nil;
}

- (NSString *)provideJS2NativeCallForMessage:(NSString *)message{
    
    return message;
}

#pragma mark -- Navigation and UI delegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    id<WKNavigationDelegate> wkNavigationDelegate = [self wk_getNavigationDelegate];
    JavascriptInterface *inteface = [self getInterfaceProvider];
    
    if ((inteface == nil || (inteface != nil && ![inteface handleInjectedJSMethod:webView.URL]))&&wkNavigationDelegate!=nil && [wkNavigationDelegate respondsToSelector:@selector(webView:decidePolicyForNavigationAction:decisionHandler:)]) {

        [wkNavigationDelegate webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    
    id<WKNavigationDelegate> wkNavigationDelegate = [self wk_getNavigationDelegate];
    if ([wkNavigationDelegate respondsToSelector:@selector(webView:decidePolicyForNavigationResponse:decisionHandler:)]) {
        [wkNavigationDelegate webView:webView decidePolicyForNavigationResponse:navigationResponse decisionHandler:decisionHandler];
    }
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    id<WKNavigationDelegate> wkNavigationDelegate = [self wk_getNavigationDelegate];
    if ([wkNavigationDelegate respondsToSelector:@selector(webView:didCommitNavigation:)]) {
        [wkNavigationDelegate webView:webView didCommitNavigation:navigation];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    id<WKNavigationDelegate> wkNavigationDelegate = [self wk_getNavigationDelegate];
    [self evaluateJavaScript:@"document.body.style.webkitTouchCallout='none';" completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
        
        if (error) {
            NSLog(@"%@",error);
        }
    }];
    JavascriptInterface *inteface = [self getInterfaceProvider];
    [inteface injectJSMethod];
    if ([wkNavigationDelegate respondsToSelector:@selector(webView:didFinishNavigation:)]) {
        [wkNavigationDelegate webView:webView didFinishNavigation:navigation];
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    id<WKNavigationDelegate> wkNavigationDelegate = [self wk_getNavigationDelegate];
    if ([wkNavigationDelegate respondsToSelector:@selector(webView:didFailProvisionalNavigation:withError:)]) {
        [wkNavigationDelegate webView:webView didFailNavigation:navigation withError:error];
    }
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
    id<WKNavigationDelegate> wkNavigationDelegate = [self wk_getNavigationDelegate];
    if ([wkNavigationDelegate respondsToSelector:@selector(webView:didReceiveServerRedirectForProvisionalNavigation:)]) {
        [wkNavigationDelegate webView:webView didReceiveServerRedirectForProvisionalNavigation:navigation];
    }
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    id<WKNavigationDelegate> wkNavigationDelegate = [self wk_getNavigationDelegate];
    if ([wkNavigationDelegate respondsToSelector:@selector(webView:didStartProvisionalNavigation:)]) {
        [wkNavigationDelegate webView:webView didStartProvisionalNavigation:navigation];
    }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    id<WKNavigationDelegate> wkNavigationDelegate = [self wk_getNavigationDelegate];
    if ([wkNavigationDelegate respondsToSelector:@selector(webView:didFailProvisionalNavigation:withError:)]) {
        [wkNavigationDelegate webView:webView didFailProvisionalNavigation:navigation withError:error];
    }
}

//----------- UI delegate
//#cyan.next 优化js响应的UI操作
- (void) webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
        completionHandler();
    id<WKUIDelegate> WkUIDelegate = [self wk_getUIDelegate];
    if ([WkUIDelegate respondsToSelector:@selector(webView:runJavaScriptAlertPanelWithMessage:initiatedByFrame:completionHandler:)]) {
        [WkUIDelegate webView:webView runJavaScriptAlertPanelWithMessage:message initiatedByFrame:frame completionHandler:completionHandler];
    }else{
        if (WkUIDelegate) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:(UIAlertControllerStyleAlert)];
            [(UIViewController *)WkUIDelegate presentViewController:alertController animated:YES completion:^{
                sleep(2);
                [(UIViewController *)WkUIDelegate dismissViewControllerAnimated:YES completion:nil];
            }];
        }
    }
}

- (void) webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    completionHandler(YES);
    id<WKUIDelegate> WkUIDelegate = [self wk_getUIDelegate];
    if ([WkUIDelegate respondsToSelector:@selector(webView:runJavaScriptConfirmPanelWithMessage:initiatedByFrame:completionHandler:)]) {
        [WkUIDelegate webView:webView runJavaScriptConfirmPanelWithMessage:message initiatedByFrame:frame completionHandler:completionHandler];
    }
}

- (void) webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    completionHandler(@"www");
    id<WKUIDelegate> WkUIDelegate = [self wk_getUIDelegate];
    if ([WkUIDelegate respondsToSelector:@selector(webView:runJavaScriptTextInputPanelWithPrompt:defaultText:initiatedByFrame:completionHandler:)]) {
        [WkUIDelegate webView:webView runJavaScriptTextInputPanelWithPrompt:prompt defaultText:defaultText initiatedByFrame:frame completionHandler:completionHandler];
    }
}

- (void) webViewDidClose:(WKWebView *)webView{


}
@end
