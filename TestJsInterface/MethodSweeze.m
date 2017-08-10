
//
//  MethodSweeze.m
//  TestJsInterface
//
//  Created by cuiyan on 16/12/1.
//  Copyright © 2016年 cyan. All rights reserved.
//

#import "MethodSweeze.h"

@implementation MethodSweeze


+ (void)swizzleSelector:(SEL)selector withTargetSelector:(SEL)baseSelector class:(Class)sweezingClass{
    
    Method method = class_getInstanceMethod(sweezingClass, selector);
    Method baseMethd = class_getInstanceMethod(sweezingClass, baseSelector);
    method_exchangeImplementations(method, baseMethd);

    if (class_addMethod([self class], selector,method_getImplementation(baseMethd) , method_getTypeEncoding(method))) {
        
        class_replaceMethod([self class], baseSelector,method_getImplementation(method), method_getTypeEncoding(baseMethd));
    }else{
        
        method_exchangeImplementations(method, baseMethd);
    }
}

@end
