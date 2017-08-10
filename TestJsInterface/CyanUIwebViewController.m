
//
//  CyanUIwebViewController.m
//  gezilicai
//
//  Created by cuiyan on 16/11/10.
//  Copyright © 2016年 yuexue. All rights reserved.
//

#import "CyanUIwebViewController.h"
#import "UIWebView+JavascriptInterface.h"

@interface CyanUIwebViewController ()<UIWebViewDelegate>

@property (nonatomic,strong) UIWebView *webView;

@end

@implementation CyanUIwebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 50, self.view.bounds.size.width, self.view.bounds.size.height)];
    _webView.delegate = self;
    
    //给webView增加javascriptInterface，javascriptInterface提供JS需要调用的对应方法
    //这边的javascriptInterface名称会在JS里面生成相同名称的对象,在JS里面调用原生的时候就可以写成"nativeCommon.xxxx()"
    //注意这边javascriptInterface提供的方法都必须是以javascriptInterface为target能调用到的方法
    [_webView addJavascriptInterface:self.interfaceProvider forName:@"nativeCommon"];
    
    [self.view addSubview:_webView];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Test" ofType:@"html"];
    [_webView loadHTMLString:[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil] baseURL:[NSURL URLWithString:@"https://www.zhihu.com"]];}

#pragma mark --
- (void)evaluateJavaScript:(NSString *)javaScriptString completeBlock:(void (^)(id _Nullable))complete{
    
    NSString* response = [_webView stringByEvaluatingJavaScriptFromString:javaScriptString];
    if (complete) {
        complete(response);
    }
}

#pragma mark webview delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    NSLog(@"----> UIWebview deleagte  should start load");
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    

}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
    
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
