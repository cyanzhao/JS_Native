//
//  CyanUIwebViewController.h
//  gezilicai
//
//  Created by cuiyan on 16/11/10.
//  Copyright © 2016年 yuexue. All rights reserved.
//

#import "CyanBaseWebViewController.h"
#import "InterfaceProvider.h"

@interface CyanUIwebViewController : CyanBaseWebViewController

@property (nonatomic,assign)id<InterfaceProvider> interfaceProvider;

@end
