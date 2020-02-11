//
//  UIApplication+Action.m
//  Demo
//
//  Created by Ericydong on 2020/2/11.
//  Copyright © 2020 EricyDong. All rights reserved.
//

#import "UIApplication+Action.h"

#import <objc/runtime.h>


@implementation UIApplication (Action)
+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        SEL _ori_sel_ = @selector(sendAction:to:from:forEvent:);
        Method _ori_method_ = class_getInstanceMethod(self, _ori_sel_);
        
        method_exchangeImplementations(_ori_method_, class_getInstanceMethod(self, @selector(ew_sendAction:to:from:forEvent:)));
        
        
    });
    
}
- (BOOL)ew_sendAction:(SEL)action to:(id)target from:(id)sender forEvent:(UIEvent *)event {
    
    NSLog(@"from:%@, to:%@, action:%@, event:%@", sender, target, NSStringFromSelector(action), event);
   return [self ew_sendAction:action to:target from:sender forEvent:event];
    
}
@end
