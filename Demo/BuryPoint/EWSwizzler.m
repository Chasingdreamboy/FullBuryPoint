//
//  EWSwizzler.m
//  Demo
//
//  Created by Ericydong on 2020/2/11.
//  Copyright © 2020 EricyDong. All rights reserved.
//


#if !__has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag on this file.
#endif





#import "EWSwizzler.h"

#if TARGET_OS_IPHONE
#import <objc/runtime.h>
#import <objc/message.h>
#else
#error This SDK is only for iOS.
#endif



#define MIN_ARGS 2
#define MAX_ARGS 4
#define MIN_BOOL_ARGS 3
#define MAX_BOOL_ARGS 3

@interface EWSwizzle : NSObject

@property (nonatomic, assign) Class class;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, assign) IMP originalMethod;
@property (nonatomic, assign) uint numArgs;
@property (nonatomic, copy) NSMapTable *blocks;

- (instancetype)initWithBlock:(AlternateBlock)aBlock
                        named:(NSString *)aName
                     forClass:(Class)aClass
                     selector:(SEL)aSelector
               originalMethod:(IMP)aMethod;

@end

//static NSMapTable<id, EWSwizzle *> *swizzles;

static NSMapTable<id, EWSwizzle *> *swizzles() {
    static NSMapTable<id, EWSwizzle *> *_swizzles;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _swizzles = [NSMapTable mapTableWithKeyOptions:(NSPointerFunctionsOpaqueMemory | NSPointerFunctionsOpaquePersonality)
                                         valueOptions:(NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPointerPersonality)];

        
        
    });
    return _swizzles;
    
}




static void ew_swizzledMethod_2(id self, SEL _cmd) {
    Method aMethod = class_getInstanceMethod([self class], _cmd);
    EWSwizzle *swizzle = (EWSwizzle *)[swizzles() objectForKey:MAPTABLE_ID(aMethod)];
    if (swizzle) {
        ((void(*)(id, SEL))swizzle.originalMethod)(self, _cmd);

        NSEnumerator *blocks = [swizzle.blocks objectEnumerator];
        AlternateBlock block;
        while((block = [blocks nextObject])) {
            block(self, _cmd);
        }
    }
}


static void ew_swizzledMethod_3(id self, SEL _cmd, id arg) {
    Method aMethod = class_getInstanceMethod([self class], _cmd);
    EWSwizzle *swizzle = (EWSwizzle *)[swizzles() objectForKey:MAPTABLE_ID(aMethod)];
    if (swizzle) {
        ((void(*)(id, SEL, id))swizzle.originalMethod)(self, _cmd, arg);

        NSEnumerator *blocks = [swizzle.blocks objectEnumerator];
        AlternateBlock block;
        while((block = [blocks nextObject])) {
            block(self, _cmd, arg);
        }
    }
}

static void ew_swizzledMethod_3_bool(id self, SEL _cmd, BOOL arg) {
    Class klass = [self class];
    while (klass) {
        Method aMethod = class_getInstanceMethod(klass, _cmd);
        EWSwizzle *swizzle = (EWSwizzle *)[swizzles() objectForKey:MAPTABLE_ID(aMethod)];
        if (swizzle) {
            ((void(*)(id, SEL, BOOL))swizzle.originalMethod)(self, _cmd, arg);
            
            NSEnumerator *blocks = [swizzle.blocks objectEnumerator];
            AlternateBlock block;
            while((block = [blocks nextObject])) {
                block(self, _cmd, [NSNumber numberWithBool:arg]);
            }
            break;
        }
        klass = class_getSuperclass(klass);
    }
}

static void ew_swizzledMethod_4(id self, SEL _cmd, id arg, id arg2) {
    Method aMethod = class_getInstanceMethod([self class], _cmd);
    EWSwizzle *swizzle = (EWSwizzle *)[swizzles() objectForKey:(__bridge id)((void *)aMethod)];
    if (swizzle) {
        ((void(*)(id, SEL, id, id))swizzle.originalMethod)(self, _cmd, arg, arg2);

        NSEnumerator *blocks = [swizzle.blocks objectEnumerator];
        AlternateBlock block;
        while((block = [blocks nextObject])) {
            block(self, _cmd, arg, arg2);
        }
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
static void (*ew_swizzledMethods[MAX_ARGS - MIN_ARGS + 1])() = {ew_swizzledMethod_2, ew_swizzledMethod_3, ew_swizzledMethod_4};
#pragma clang diagnostic pop
static void (*ew_swizzledMethods_bool[MAX_BOOL_ARGS - MIN_BOOL_ARGS + 1])(id, SEL, BOOL) = {ew_swizzledMethod_3_bool};


@implementation EWSwizzle
- (instancetype)init {
    self = [super init];
    if (self) {
        self.blocks = [NSMapTable mapTableWithKeyOptions:(NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPersonality)
                                            valueOptions:(NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPointerPersonality)];
    }
    return self;
}


- (instancetype)initWithBlock:(AlternateBlock)aBlock
              named:(NSString *)aName
           forClass:(Class)aClass
           selector:(SEL)aSelector
     originalMethod:(IMP)aMethod {
    self = [self init];
    if (self) {
        self.class = aClass;
        self.selector = aSelector;
        self.originalMethod = aMethod;
        [self.blocks setObject:aBlock forKey:aName];
    }
    return self;
}

- (NSString *)description {
    NSString *descriptors = @"";
    NSString *key;
    NSEnumerator *keys = [self.blocks keyEnumerator];
    while ((key = [keys nextObject])) {
        descriptors = [descriptors stringByAppendingFormat:@"\t%@ : %@\n", key, [self.blocks objectForKey:key]];
    }
    return [NSString stringWithFormat:@"Swizzle on %@::%@ [\n%@]", NSStringFromClass(self.class), NSStringFromSelector(self.selector), descriptors];
}

@end





@implementation EWSwizzler

//+ (void)load {
//    swizzles = [NSMapTable mapTableWithKeyOptions:(NSPointerFunctionsOpaqueMemory | NSPointerFunctionsOpaquePersonality)
//                                     valueOptions:(NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPointerPersonality)];
//}

+ (void)printSwizzles {
    NSEnumerator *en = [swizzles() objectEnumerator];
    EWSwizzle *swizzle;
    while((swizzle = (EWSwizzle *)[en nextObject])) {
        NSLog(@"%@", swizzle);
    }
}

+ (EWSwizzle *)swizzleForMethod:(Method)aMethod {
    return (EWSwizzle *)[swizzles() objectForKey:MAPTABLE_ID(aMethod)];
}

+ (void)removeSwizzleForMethod:(Method)aMethod {
    [swizzles() removeObjectForKey:MAPTABLE_ID(aMethod)];
}

+ (void)setSwizzle:(EWSwizzle *)swizzle forMethod:(Method)aMethod {
    [swizzles() setObject:swizzle forKey:MAPTABLE_ID(aMethod)];
}

+ (BOOL)isLocallyDefinedMethod:(Method)aMethod onClass:(Class)aClass {
    uint count;
    BOOL isLocal = NO;
    Method *methods = class_copyMethodList(aClass, &count);
    for (NSUInteger i = 0; i < count; i++) {
        if (aMethod == methods[i]) {
            isLocal = YES;
            break;
        }
    }
    free(methods);
    return isLocal;
}

+ (void)swizzleSelector:(SEL)aSelector
                onClass:(Class)aClass
              withBlock:(AlternateBlock)aBlock
                  named:(NSString *)aName {
    Method aMethod = class_getInstanceMethod(aClass, aSelector);
    if (!aMethod) {
//        [NSException raise:@"SwizzleException" format:@"Cannot find method for %@ on %@", NSStringFromSelector(aSelector), NSStringFromClass(aClass)];
        NSLog(@"SwizzleException:Cannot find method for %@ on %@", NSStringFromSelector(aSelector), NSStringFromClass(aClass));
        return;
    }
    
    uint numArgs = method_getNumberOfArguments(aMethod);
    if (numArgs < MIN_ARGS || numArgs > MAX_ARGS) {
        [NSException raise:@"SwizzleException" format:@"Cannot swizzle method with %d args", numArgs];
    }
    
    IMP swizzledMethod = (IMP)ew_swizzledMethods[numArgs - 2];
    [EWSwizzler swizzleSelector:aSelector onClass:aClass withBlock:aBlock andSwizzleMethod:swizzledMethod named:aName];
}

+ (void)swizzleBoolSelector:(SEL)aSelector
                    onClass:(Class)aClass
                  withBlock:(AlternateBlock)aBlock
                      named:(NSString *)aName {
    Method aMethod = class_getInstanceMethod(aClass, aSelector);
    if (!aMethod) {
        [NSException raise:@"SwizzleBoolException" format:@"Cannot find method for %@ on %@", NSStringFromSelector(aSelector), NSStringFromClass(aClass)];
    }
    
    uint numArgs = method_getNumberOfArguments(aMethod);
    if (numArgs < MIN_BOOL_ARGS || numArgs > MAX_BOOL_ARGS) {
        [NSException raise:@"SwizzleBoolException" format:@"Cannot swizzle method with %d args", numArgs];
    }
    
    IMP swizzledMethod = (IMP)ew_swizzledMethods_bool[numArgs - 3];
    [EWSwizzler swizzleSelector:aSelector onClass:aClass withBlock:aBlock andSwizzleMethod:swizzledMethod named:aName];
}

+ (void)swizzleSelector:(SEL)aSelector
                onClass:(Class)aClass
              withBlock:(AlternateBlock)aBlock
       andSwizzleMethod:(IMP)aSwizzleMethod
                  named:(NSString *)aName {
    Method aMethod = class_getInstanceMethod(aClass, aSelector);
    if (!aMethod) {
        [NSException raise:@"SwizzleException" format:@"Cannot find method for %@ on %@", NSStringFromSelector(aSelector), NSStringFromClass(aClass)];
    }
    
    //当前类中是否存在该方法
    BOOL isLocal = [self isLocallyDefinedMethod:aMethod onClass:aClass];
    EWSwizzle *swizzle = [self swizzleForMethod:aMethod];
    
    if (isLocal) {
        //当前aMethod对应的方法在类方列表中
        
        if (swizzle) {
            [swizzle.blocks setObject:aBlock forKey:aName];
        } else {
            IMP originalMethod = method_getImplementation(aMethod);
            
            // Replace the local implementation of this method with the swizzled one
            method_setImplementation(aMethod, aSwizzleMethod);
            
            // Create and add the swizzle
            @try {
                swizzle = [[EWSwizzle alloc] initWithBlock:aBlock named:aName forClass:aClass selector:aSelector originalMethod:originalMethod];
            } @catch (NSException *exception) {
                NSLog(@"%@ error: %@", self, exception);
            }
            [self setSwizzle:swizzle forMethod:aMethod];
        }
    } else {
        //当前aMethod对应的方法在类方列表中
        
        IMP originalMethod = swizzle ? swizzle.originalMethod : method_getImplementation(aMethod);
        
        // Add the swizzle as a new local method on the class.
        if (!class_addMethod(aClass, aSelector, aSwizzleMethod, method_getTypeEncoding(aMethod))) {
            [NSException raise:@"SwizzleException" format:@"Could not add swizzled for %@::%@, even though it didn't already exist locally", NSStringFromClass(aClass), NSStringFromSelector(aSelector)];
        }
        // Now re-get the Method, it should be the one we just added.
        Method newMethod = class_getInstanceMethod(aClass, aSelector);
        if (aMethod == newMethod) {
            [NSException raise:@"SwizzleException" format:@"Newly added method for %@::%@ was the same as the old method", NSStringFromClass(aClass), NSStringFromSelector(aSelector)];
        }
        
        EWSwizzle *newSwizzle = [[EWSwizzle alloc] initWithBlock:aBlock named:aName forClass:aClass selector:aSelector originalMethod:originalMethod];
        [self setSwizzle:newSwizzle forMethod:newMethod];
    }
}

+ (void)unswizzleSelector:(SEL)aSelector onClass:(Class)aClass {
    Method aMethod = class_getInstanceMethod(aClass, aSelector);
    EWSwizzle *swizzle = [self swizzleForMethod:aMethod];
    if (swizzle) {
        method_setImplementation(aMethod, swizzle.originalMethod);
        [self removeSwizzleForMethod:aMethod];
    }
}

/*
 Remove the named swizzle from the given class/selector. If aName is nil, remove all
 swizzles for this class/selector
*/
+ (void)unswizzleSelector:(SEL)aSelector onClass:(Class)aClass named:(NSString *)aName {
    Method aMethod = class_getInstanceMethod(aClass, aSelector);
    EWSwizzle *swizzle = [self swizzleForMethod:aMethod];
    if (swizzle) {
        if (aName) {
            [swizzle.blocks removeObjectForKey:aName];
        }
        if (!aName || [swizzle.blocks count] == 0) {
            method_setImplementation(aMethod, swizzle.originalMethod);
            [self removeSwizzleForMethod:aMethod];
        }
    }
}

@end
















