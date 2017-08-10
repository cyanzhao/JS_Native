//
//  JSCoreWKViewController.m
//  TestJsInterface
//
//  Created by cuiyan on 16/12/7.
//  Copyright © 2016年 cyan. All rights reserved.
//

#import "JSCoreWKViewController.h"
#import <WebKit/WebKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

@interface JSCoreWKViewController ()<WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler>

@property (nonatomic,strong) WKWebView *webview;
@end

@implementation JSCoreWKViewController

//#cyan 暂未找到方法获取 wkwebview.jscontext
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    //still can't find method fetch wkweview.jscontext
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
