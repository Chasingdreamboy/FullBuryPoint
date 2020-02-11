//
//  NSObject+EWSwizzle.h
//  Demo
//
//  Created by Ericydong on 2020/2/11.
//  Copyright © 2020 EricyDong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (EWSwizzle)

+ (BOOL)ew_swizzleMethod:(SEL)_origSel_ withMethod:(SEL)_altSel_ error:(NSError **)_error_;
+ (BOOL)ew_swizzleClassMethod:(SEL)_origSel_ withClassMethod:(SEL)_altSel_ error:(NSError **)_error_;
@end

NS_ASSUME_NONNULL_END
