

//
//  CyanWkwebViewController.m
//  gezilicai
//
//  Created by cuiyan on 16/11/10.
//  Copyright © 2016年 yuexue. All rights reserved.
//

#import "CyanWkwebViewController.h"
#import <WebKit/WebKit.h>
#import "WKWebView+JavascriptInterface.h"

@interface CyanWkwebViewController ()<WKNavigationDelegate,WKScriptMessageHandler,WKUIDelegate>

@property (nonatomic,strong) WKWebView *webview;

@end

@implementation CyanWkwebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc]init];
    WKUserContentController *userContent = [[WKUserContentController alloc]init];
    [userContent addScriptMessageHandler:self name:@"nativeCommon"];
//    userContent.scriptMessageHandler = self;
    configuration.userContentController = userContent;
    
    _webview = [[WKWebView alloc]initWithFrame:self.view.bounds configuration:configuration];
    _webview.navigationDelegate = self;
    _webview.UIDelegate = self;
    [_webview addJavascritInetrface:self.interfaceProvider name:@"nativeCommon"];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Test" ofType:@"html"];
    [_webview loadHTMLString:[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil] baseURL:[NSURL URLWithString:@"https://www.zhihu.com"]];
    
    [self.view addSubview:_webview];
}

#pragma mark --
- (void)evaluateJavaScript:(NSString *)javaScriptString completeBlock:(void (^)(id _Nullable))complete{
    
   [_webview evaluateJavaScript:javaScriptString completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
       
       if (complete != nil) {
           complete(obj);
       }
    }];
}

#pragma mark --
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    decisionHandler(WKNavigationActionPolicyAllow);
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
