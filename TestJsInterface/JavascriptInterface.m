//
//  JavascriptInterface.m
//  JavascriptInterface
//
//  Created by 7heaven on 16/7/14.
//  Copyright © 2016年 7heaven. All rights reserved.
//

#import "JavascriptInterface.h"
#import "objc/runtime.h"
#import "StringUtil.h"
#import "WebType.h"

static JavascriptInterface *sharedInterface;

@implementation JavascriptInterface


+ (JavascriptInterface *)sharedJSInterface{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInterface = [[JavascriptInterface alloc]init];
    });
    return sharedInterface;
}

- (BOOL) validateInterfaceName:(NSString *) name{
    return name != nil && [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length != 0;
}

- (BOOL) checkUpcomingRequestURL:(NSURL *) url{
    
    if(url != nil && [self validateInterfaceName:self.interfaceName]){
        //忽略大小写
        NSString *urlString = [url.absoluteString lowercaseString];
        return [urlString hasPrefix:[[NSString stringWithFormat:@"%@://", _interfaceName] lowercaseString]];
    }
    
    return NO;
}

- (BOOL) handleInjectedJSMethod:(NSURL *) url{
    if([self checkUpcomingRequestURL:url]){
      
        return [self execSelectorForURL:url];

    }
    
    return NO;
}

- (BOOL) execSelectorForURL:(NSURL *) url{
    
    NSValue *selValue = [self.interfaceProvider javascriptInterfaces][url.host];
    if(selValue != nil){
        SEL targetSelector = [selValue pointerValue];
        
        if([self.interfaceProvider respondsToSelector:targetSelector]){
            
            NSMethodSignature *methodSignature = [((NSObject *) self.interfaceProvider) methodSignatureForSelector:targetSelector];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
            [invocation setTarget:self.interfaceProvider];
            [invocation setSelector:targetSelector];
            
            NSDictionary *params = [StringUtil getUrlParams:url.absoluteString];
            if(params != nil && params.allKeys.count > 0){
                unsigned long paramCount = params.allKeys.count;
                for(int i = 0; i < paramCount; i++){
                    NSString *key = [NSString stringWithFormat:@"arg%d", i];
                    
                    NSString *value = params[key];
                    
                    if(value != nil){
                        [invocation setArgument:&value atIndex:i + 2];
                    }
                }
            }
            
            [invocation invoke];
            
            //获取返回值
            Method m = class_getInstanceMethod([self.interfaceProvider class], targetSelector);
            void *returnValue;
            
            char type[128];
            method_getReturnType(m, type, sizeof(type));
            
            NSData *dataData = [NSData dataWithBytes:type length:sizeof(type)];
            NSString *returnS = [[NSString alloc] initWithData:dataData encoding:NSUTF8StringEncoding];
            
            if (!([returnS hasPrefix:@"v"] && type[1] == '\0')) {
                [invocation getReturnValue:&returnValue];
                
                //把返回值传给js
                [self.webView evaluatingJavascript:[NSString stringWithFormat:@"%@.retValue=\"%@\";", self.interfaceName, returnValue]];
            }
            
            return YES;
        }
        
    }
    
    return NO;
}

- (void) injectJSMethod{

    long type = [[[NSUserDefaults standardUserDefaults]objectForKey:@"WebType"] longLongValue];
    
    if (type == Inject_UI) {
        NSDictionary<NSString *, NSValue *> *list = [self.interfaceProvider javascriptInterfaces];
        
        //把所有的方法都拼到window下{interfaceName}对象内
        if([self validateInterfaceName:self.interfaceName] && list != nil && list.allKeys.count > 0){
            NSMutableString *injectString = [[NSMutableString alloc] init];
            [injectString appendString:[NSString stringWithFormat:@"window.%@ = {", self.interfaceName]];
            
            for(int i = 0; i < list.allKeys.count; i++){
                NSString *key = list.allKeys[i];
                SEL selector = [list[key] pointerValue];
                
                NSString *functionString = [self injectMethodStringForSelector:selector withJSName:key interfaceName:self.interfaceName];
                
                [injectString appendString:functionString];
                
                if(i != list.allKeys.count - 1){
                    [injectString appendString:@","];
                }
            }
            
            [injectString appendString:@"};"];
            
            [self.webView evaluatingJavascript:injectString];
        }
    }else if (type == Inject_WK){
        NSString *script = [NSString stringWithFormat:@"var script = document.createElement('script');"
                            "script.type = 'text/javascript';"
                            "script.text = 'var nativeCommon = {};';"
                            "document.getElementsByTagName('head')[0].appendChild(script);"];
        [self.webView evaluatingJavascript:script];
        
        NSDictionary<NSString *, NSValue *> *list = [self.interfaceProvider javascriptInterfaces];
        
        //把所有的方法都拼到window下{interfaceName}对象内
        if([self validateInterfaceName:self.interfaceName] && list != nil && list.allKeys.count > 0){
            
            for(int i = 0; i < list.allKeys.count; i++){
                
                NSString *key = list.allKeys[i];
                SEL selector = [list[key] pointerValue];
                NSString *injectString = [self injectMethodStringForSelector:selector withJSName:key interfaceName:self.interfaceName];
                [self.webView evaluatingJavascript:injectString];
                
            }
        }
    }
}

- (NSString *) injectMethodStringForSelector:(SEL) selector withJSName:(NSString *) jsName interfaceName:(NSString *) interfaceName{
    
    Method method = class_getInstanceMethod([_interfaceProvider class], selector);
    int paramsCount = method_getNumberOfArguments(method) - 2;
    
    long type = [[[NSUserDefaults standardUserDefaults]objectForKey:@"WebType"] longLongValue];

    if (type == Inject_UI) {
        //js function头
        NSMutableString *resultString = [[NSMutableString alloc] init];
        [resultString appendString:[NSString stringWithFormat:@"%@: function (", jsName]];
        
        //实际的调用url
        NSMutableString *locationString = [[NSMutableString alloc] init];
        [locationString appendString:[NSString stringWithFormat:@"\"%@://%@", interfaceName, jsName]];
        if(paramsCount > 0) [locationString appendString:@"?"];
        [locationString appendString:@"\""];
        
        //对方法的参数进行拼接
        for(int i = 0; i < paramsCount; i++){
            if(i == paramsCount - 1){
                [resultString appendString:[NSString stringWithFormat:@"arg%d", i]];
                [locationString appendString:[NSString stringWithFormat:@" + \"arg%d=\" + arg%d", i, i]];
            }else{
                [resultString appendString:[NSString stringWithFormat:@"arg%d,", i]];
                [locationString appendString:[NSString stringWithFormat:@" + \"arg%d=\" + arg%d + \"&\"", i, i]];
            }
        }
        
        [resultString appendString:[NSString stringWithFormat:@"){"
                                    "%@.retValue = null;"
                                    "var iframe = document.createElement(\"IFRAME\");"
                                    "iframe.setAttribute(\"src\", %@);"
                                    "document.documentElement.appendChild(iframe);"
                                    "iframe.parentNode.removeChild(iframe);"
                                    "iframe = null;"
                                    "var ret = %@.retValue;"
                                    "if(ret){"
                                    "return ret;"
                                    "}}", interfaceName, [self.webView provideJS2NativeCallForMessage:locationString], interfaceName]];
        
        return resultString;
    }else if (type == Inject_WK){
        NSString *formFunction = @"(";
        NSString *host = [NSString stringWithFormat:@"\"%@://",_interfaceName];
        NSString *formMessage = [host stringByAppendingString:paramsCount == 0 ? jsName : [jsName stringByAppendingString:@"?"]];
        for(int i = 0; i < paramsCount; i++){
            
            NSString *argName = [NSString stringWithFormat:@"arg%d", i];
            formFunction = [formFunction stringByAppendingString:argName];
            formMessage = [formMessage stringByAppendingString:[NSString stringWithFormat:@"%@=\" + %@", argName, argName]];
            
            if(i < paramsCount - 1){
                formFunction = [formFunction stringByAppendingString:@","];
                formMessage = [formMessage stringByAppendingString:@" + \"&"];
            }
        }
        if(paramsCount == 0) formMessage = [formMessage stringByAppendingString:@"\""];
        formFunction = [formFunction stringByAppendingString:@")"];
        //    formMessage = @"\"nativeCommon://callNative_two?+ \"arg0=\" + arg0 + \"&\" + \"arg1=\" + arg1";
        NSString *script = [NSString stringWithFormat:@"var script = document.createElement('script');"
                            "script.type = 'text/javascript';"
                            "script.text = 'nativeCommon.%@ = function%@ {"
                            "webkit.messageHandlers.nativeCommon.postMessage(%@);"
                            "}';"
                            "document.getElementsByTagName('head')[0].appendChild(script);", jsName, formFunction, formMessage];
        return script;
    }
    return nil;
}

@end
