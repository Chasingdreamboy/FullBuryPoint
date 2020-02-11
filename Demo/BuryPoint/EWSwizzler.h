//
//  EWSwizzler.h
//  Demo
//
//  Created by Ericydong on 2020/2/11.
//  Copyright © 2020 EricyDong. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MAPTABLE_ID(x) (__bridge id)((void *)x)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
typedef void (^AlternateBlock)();
#pragma clang dianostic pop



NS_ASSUME_NONNULL_BEGIN

@interface EWSwizzler : NSObject
+ (void)swizzleSelector:(SEL)aSelector onClass:(Class)aClass withBlock:(AlternateBlock)block named:(NSString *)aName;
+ (void)swizzleBoolSelector:(SEL)aSelector onClass:(Class)aClass withBlock:(AlternateBlock)aBlock named:(NSString *)aName;
+ (void)unswizzleSelector:(SEL)aSelector onClass:(Class)aClass named:(NSString *)aName;
+ (void)printSwizzles;


@end

NS_ASSUME_NONNULL_END
