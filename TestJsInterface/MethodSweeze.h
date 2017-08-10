//
//  MethodSweeze.h
//  TestJsInterface
//
//  Created by cuiyan on 16/12/1.
//  Copyright © 2016年 cyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface MethodSweeze : NSObject

+ (void)swizzleSelector:(SEL)selector withTargetSelector:(SEL)baseSelector class:(Class)sweezingClass;
@end
