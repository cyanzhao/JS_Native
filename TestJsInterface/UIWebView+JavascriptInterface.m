//
//  UIWebView+JavascriptInterface.m
//  JavascriptInterface
//
//  Created by 7heaven on 16/7/14.
//  Copyright © 2016年 7heaven. All rights reserved.
//

#import "UIWebView+JavascriptInterface.h"
#import "MethodSweeze.h"

#define PROPERTY_DELEGATE "_delegate"
#define PROPERTY_JAVASCRIPT_INTERFACE "_javascriptinterface"

@implementation UIWebView (JavascriptInterface)

+ (void) load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self methodSwizzle];
    });
}

+ (void) methodSwizzle{
    [MethodSweeze swizzleSelector:@selector(setDelegate:) withTargetSelector:@selector(src_setDelegate:) class:[self class]];
    [MethodSweeze swizzleSelector:@selector(delegate) withTargetSelector:@selector(src_delegate) class:[self class]];
    [MethodSweeze swizzleSelector:@selector(initWithFrame:) withTargetSelector:@selector(src_initWithFrame:) class:[self class]];
    [MethodSweeze swizzleSelector:@selector(initWithCoder:) withTargetSelector:@selector(src_initWithCoder:) class:[self class]];
}

- (instancetype) src_initWithFrame:(CGRect)frame{
    if([self src_initWithFrame:frame]){
        [self setDelegate:nil];
        [self initJavascriptInterface];
    }
    
    return self;
}

- (instancetype) src_initWithCoder:(NSCoder *)aDecoder{
    if([self src_initWithCoder:aDecoder]){
        [self setDelegate:nil];
        [self initJavascriptInterface];
    }
    
    return self;
}

- (void) src_setDelegate:(id<UIWebViewDelegate>)delegate{
    
    if(delegate == nil){
        [self src_setDelegate:self];
    }else if(delegate != self){
        objc_setAssociatedObject(self, PROPERTY_DELEGATE, delegate, OBJC_ASSOCIATION_ASSIGN);
    }
    
    
}

- (id<UIWebViewDelegate>) src_delegate{
    return [self getSrcDelegate];
}

- (id<UIWebViewDelegate>) getSrcDelegate{
    id delegateObject = objc_getAssociatedObject(self, PROPERTY_DELEGATE);
    if(delegateObject != nil && [delegateObject conformsToProtocol:@protocol(UIWebViewDelegate)]){
        return (id<UIWebViewDelegate>) delegateObject;
    }
    
    return nil;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    JavascriptInterface *_javascriptInterface = [self getJavascriptInterface];
    
    id<UIWebViewDelegate> srcDelegate = [self getSrcDelegate];
    if((_javascriptInterface == nil || (_javascriptInterface != nil && ![_javascriptInterface handleInjectedJSMethod:request.URL])) &&srcDelegate != nil && [srcDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]){
        return [srcDelegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    
    return NO;
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    JavascriptInterface *_javascriptInterface = [self getJavascriptInterface];
    if(_javascriptInterface != nil) [_javascriptInterface injectJSMethod];
    
    id<UIWebViewDelegate> srcDelegate = [self getSrcDelegate];
    if(srcDelegate != nil && [srcDelegate respondsToSelector:@selector(webViewDidStartLoad:)]){
        [srcDelegate webViewDidStartLoad:webView];
    }
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    id<UIWebViewDelegate> srcDelegate = [self getSrcDelegate];
    if(srcDelegate != nil && [srcDelegate respondsToSelector:@selector(webViewDidFinishLoad:)]){
        [srcDelegate webViewDidFinishLoad:webView];
    }
    
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:( NSError *)error{
    id<UIWebViewDelegate> srcDelegate = [self getSrcDelegate];
    if(srcDelegate != nil && [srcDelegate respondsToSelector:@selector(webView:didFailLoadWithError:)]){
        [srcDelegate webView:webView didFailLoadWithError:error];
    }
    
}



#pragma mark - -IwebviewDelegate
- (NSString *) provideJS2NativeCallForMessage:(NSString *) message{
    return message;
}

- (NSString *) evaluatingJavascript:(NSString *)script{
    return [self stringByEvaluatingJavaScriptFromString:script];
}



- (JavascriptInterface *) getJavascriptInterface{
    return objc_getAssociatedObject(self, PROPERTY_JAVASCRIPT_INTERFACE);
}

- (void) initJavascriptInterface{
    JavascriptInterface *_javascriptInterface = [JavascriptInterface sharedJSInterface];
    objc_setAssociatedObject(self, PROPERTY_JAVASCRIPT_INTERFACE, _javascriptInterface, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void) addJavascriptInterface:(id<InterfaceProvider>) target forName:(NSString *) name{
    JavascriptInterface *_javascriptInterface = [self getJavascriptInterface];
    if(_javascriptInterface != nil){
        _javascriptInterface.interfaceName = name;
        _javascriptInterface.webView = self;
        _javascriptInterface.interfaceProvider = target;
        
    }
}

@end
