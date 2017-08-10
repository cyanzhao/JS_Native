//
//  InterObject.h
//  TestJsInterface
//
//  Created by cuiyan on 2017/8/10.
//  Copyright © 2017年 cyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol ExportProtocol <JSExport>

- (NSString *)callMethod:(NSString *)msg;

@end

@interface InterObject : NSObject<ExportProtocol>

@end
