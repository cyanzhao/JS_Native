
//
//  InterObject.m
//  TestJsInterface
//
//  Created by cuiyan on 2017/8/10.
//  Copyright © 2017年 cyan. All rights reserved.
//

#import "InterObject.h"

@implementation InterObject

-  (NSString *)callMethod:(NSString *)msg{
    
    return [NSString stringWithFormat:@"%@-Z-",msg];
}

@end
