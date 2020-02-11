//
//  EWTapGestureRecognizer.m
//  Demo
//
//  Created by Ericydong on 2020/2/11.
//  Copyright © 2020 EricyDong. All rights reserved.
//

#import "EWTapGestureRecognizer.h"

@implementation EWTapGestureRecognizer

- (instancetype)initWithTarget:(id)target action:(SEL)action {
   self = [super initWithTarget:target action:action];
    if (self) {
        [self removeTarget:target action:action];
        [self ew_addTarget:target action:action];
    }
    return self;
}
- (void)ew_addTarget:(id)target action:(SEL)action {
    [super addTarget:target action:action];
    [self addTarget:self action:@selector(trackGestureRecognizerAppClick:)];
    
}



- (void)trackGestureRecognizerAppClick:(UIGestureRecognizer *)gesture {
    if (gesture.state != UIGestureRecognizerStateEnded) {
         return;
     }
    NSLog(@"事件发生了");
}
@end
