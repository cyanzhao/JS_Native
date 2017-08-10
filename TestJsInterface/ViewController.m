//
//  ViewController.m
//  TestJsInterface
//
//  Created by cuiyan on 16/11/10.
//  Copyright © 2016年 cyan. All rights reserved.
//

#import "ViewController.h"
#import "CyanWebViewController.h"
#import "JSCoreViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSArray *types = @[@{
                        @"type":@(Core_UI),
                        @"title": @"cor_ui"
                        },
                       @{
                           @"type":@(Core_WK),
                           @"title": @"cor_wk"
                           },
                       @{
                           @"type":@(Inject_UI),
                           @"title": @"inject_ui"
                           },
                       @{
                           @"type":@(Inject_WK),
                           @"title": @"inject_wk"
                           }];
    CGFloat OY = 100.;
    
    for (NSInteger i  = 0; i < 4; i++) {
        NSMutableDictionary *dic = nil;
        dic[@"312"] = nil;
        
        UIButton *btn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        btn.frame = CGRectMake(100, OY, 100, 30);
        [btn addTarget:self action:@selector(btnclicked:) forControlEvents:(UIControlEventTouchUpInside)];
        btn.backgroundColor = [UIColor greenColor];
        [btn setTitle:((NSDictionary *)types[i])[@"title"] forState:(UIControlStateNormal)];
        btn.tag = 100 + [(((NSDictionary *)types[i])[@"type"]) integerValue];
        [self.view addSubview:btn];
        OY += 30 + 10.;
    }

}

- (void)btnclicked:(id)sender{
    
    UIButton *btn = (UIButton *)sender;
    long type = btn.tag-100;
    
    [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%ld",type] forKey:@"WebType"];
    
    
    CyanWebViewController *ctrl = [[CyanWebViewController alloc]init];
    ctrl.type = (Interface_Web)type;
    [self.navigationController pushViewController:ctrl animated:YES];


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
