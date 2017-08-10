//
//  JSCoreViewController.m
//  TestJsInterface
//
//  Created by cuiyan on 16/12/7.
//  Copyright © 2016年 cyan. All rights reserved.
//

#import "JSCoreViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface JSCoreViewController ()<UIWebViewDelegate>

@property (nonatomic,strong) UIWebView *webview;

@end

@implementation JSCoreViewController

/**
 任何从jscontext拿到的都是jsvalue对象
 jsvalue = _context["add"]
	jsvalue = _context.evaluateScript("(funciton(a,b){return a+b})")
 
 native call js
 函数、匿名函数
 
 _context.evaluateScript('hello()')
 jsvalue.callwithArguments(args...)
 
 js call native
 block、<JSExport>
 
 _context["add"] = ^(NSInerger a){
 implethod code...
 }
 
 _context["jsobject"] = <JSExport>native_object;
 _context.evaluateScript('jsobject.add(2)')
 
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:[[UIView alloc]initWithFrame:(CGRectZero)]];
    
    CGFloat mainWidht = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat mainHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
    
    _webview = [[UIWebView alloc]initWithFrame:CGRectMake(0, 64, mainWidht, mainHeight-64)];
    _webview.delegate = self;
    [_webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://zhihu.com"]]];
    [self.view addSubview:_webview];

}


#pragma mark -- webview delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
    NSLog(@"%@",error);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
//    NSLog(@"-- get title %@", [webView stringByEvaluatingJavaScriptFromString:@"document.title"]);
    JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    self.webContext = context;
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
