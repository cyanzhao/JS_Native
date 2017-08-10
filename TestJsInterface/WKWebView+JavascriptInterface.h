//
//  WKWebView+JavascriptInterface.h
//  gezilicai
//
//  Created by cuiyan on 16/11/9.
//  Copyright © 2016年 yuexue. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "IWebView.h"
#import "JavascriptInterface.h"

@interface WKUserContentController(JavascriptInterface)<WKScriptMessageHandler>

//@property (nonatomic,assign) id<WKScriptMessageHandler> scriptMessageHandler;

@end


@interface WKWebView (JavascriptInterface)<IWebView,WKUIDelegate,WKNavigationDelegate>

- (void)addJavascritInetrface:(id<InterfaceProvider>)tarfer name:(NSString *)commonName;

@end
