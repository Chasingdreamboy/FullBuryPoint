//
//  NSObject+EWSwizzle.m
//  Demo
//
//  Created by Ericydong on 2020/2/11.
//  Copyright © 2020 EricyDong. All rights reserved.
//

#import "EWSwizzle.h"
#if TARGET_OS_IPHONE
#import <objc/runtime.h>
#import <objc/message.h>
#else
#error This SDK is only for iOS.
#endif

#define SetError(ERROR, FORMAT,...) \
if(ERROR) { \
    NSString *errorInfo = [NSString stringWithFormat:@"%s:" FORMAT, __func__, ##__VA_ARGS__]; \
    *ERROR = [NSError errorWithDomain:@"NSCocoaErrorDomain" \
                                 code:-1    \
                             userInfo:[NSDictionary dictionaryWithObject:errorInfo forKey:NSLocalizedDescriptionKey]]; \
}


@implementation NSObject (EWSwizzle)
+ (BOOL)ew_swizzleMethod:(SEL)_origSel_ withMethod:(SEL)_altSel_ error:(NSError **)_error_ {
#if OBJC_API_VERSION >= 2
    Method _oriMethod_ = class_getInstanceMethod(self, _origSel_);
    if (!_oriMethod_) {
        SetError(_error_, @"orignal method:%@ not found in class:%@", NSStringFromSelector(_origSel_), self);
        return false;
    }
    Method _altMethod_ = class_getInstanceMethod(self, _altSel_);
    if (!_altMethod_) {
        SetError(_error_, @"alternater method:%@ not found in class:%@", NSStringFromSelector(_altSel_), self);
        return false;
    }
    method_exchangeImplementations(_oriMethod_, _altMethod_);
    return true;
#else
    Method _oriMethod_ = NULL, _altMethod_ = NULL;
    void *interator = NULL;
    struct objc_method_list  *method_list = class_nextMethodList(self, &interator);
    while (method_list) {
        int method_index = 0;
        for (; method_index < mlist->method_count; method_index++) {
            if (mlist->method_list[method_index].method_name == origSel_) {
                assert(!directOriginalMethod);
                _oriMethod_ = &mlist->method_list[method_index];
            }
            if (mlist->method_list[method_index].method_name == altSel_) {
                assert(!directAlternateMethod);
                _altMethod_ = &mlist->method_list[method_index];
            }
        }
        mlist = ic(self, &iterator);
        
    }
    
    
    //    If either method is inherited, copy it up to the target class to make it non-inherited.
    if (!_oriMethod_ || !_altMethod_) {
        Method inheritedOriginalMethod = NULL, inheritedAlternateMethod = NULL;
        if (!_oriMethod_) {
            inheritedOriginalMethod = class_getInstanceMethod(self, origSel_);
            if (!inheritedOriginalMethod) {
                SetNSError(error_, @"original method %@ not found for class %@", NSStringFromSelector(origSel_), [self className]);
                return NO;
            }
        }
        if (!_altMethod_) {
            inheritedAlternateMethod = class_getInstanceMethod(self, altSel_);
            if (!inheritedAlternateMethod) {
                SetNSError(error_, @"alternate method %@ not found for class %@", NSStringFromSelector(altSel_), [self className]);
                return NO;
            }
        }
        
        int hoisted_method_count = !_oriMethod_ && !_altMethod_ ? 2 : 1;
        struct objc_method_list *hoisted_method_list = malloc(sizeof(struct objc_method_list) + (sizeof(struct objc_method)*(hoisted_method_count-1)));
        hoisted_method_list->obsolete = NULL;    // soothe valgrind - apparently ObjC runtime accesses this value and it shows as uninitialized in valgrind
        hoisted_method_list->method_count = hoisted_method_count;
        Method hoisted_method = hoisted_method_list->method_list;
        
        if (!_oriMethod_) {
            bcopy(inheritedOriginalMethod, hoisted_method, sizeof(struct objc_method));
            _oriMethod_ = hoisted_method++;
        }
        if (!_altMethod_) {
            bcopy(inheritedAlternateMethod, hoisted_method, sizeof(struct objc_method));
            _altMethod_ = hoisted_method;
        }
        class_addMethods(self, hoisted_method_list);
    }
    
    //    Swizzle.
    IMP temp = _oriMethod_->method_imp;
    _oriMethod_->method_imp = _altMethod_->method_imp;
    directAlternateMethod->method_imp = temp;
    return YES;
#endif
}
+ (BOOL)ew_swizzleClassMethod:(SEL)_origSel_ withClassMethod:(SEL)_altSel_ error:(NSError **)_error_ {
    return [object_getClass(self) ew_swizzleClassMethod:_origSel_ withClassMethod:_altSel_ error:_error_];

}
@end
