//
//  CyanBaseWebViewController.h
//  gezilicai
//
//  Created by cuiyan on 16/11/10.
//  Copyright © 2016年 yuexue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

@interface CyanBaseWebViewController : UIViewController

//next：these method can become protocol
- (void)evaluateJavaScript:(NSString *_Nullable)javaScriptString completeBlock:(void(^_Nullable)(__nullable id obj))complete;
@property (nonatomic,strong) JSContext * _Nullable webContext;

@end
