//
//  DPRuntime.m
//  DelegateProxy
//
//  Created by Ryo Aoyama on 8/5/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "DPRuntime.h"

BOOL DP_isMethodReturnTypeVoid(struct objc_method_description method) {
    return strncmp(method.types, @encode(void), 1) == 0;
}

BOOL DP_isMethodSignatureVoid(NSMethodSignature * _Nonnull methodSignature) {
    const char *methodReturnType = methodSignature.methodReturnType;
    return strcmp(methodReturnType, @encode(void)) == 0;
}

NSArray * _Nonnull DP_argumentsFromInvocation(NSInvocation * _Nonnull invocation) {
    NSUInteger numberOfHiddenArguments = 2; // self + cmd
    NSUInteger numberOfArguments = invocation.methodSignature.numberOfArguments;
    
    NSCParameterAssert(numberOfArguments >= 0);
    
    NSMutableArray *arguments = [NSMutableArray arrayWithCapacity:numberOfArguments - numberOfHiddenArguments];
    for (NSUInteger index = numberOfHiddenArguments; index < numberOfArguments; ++index) {
        [arguments addObject:DP_argumentsFromInvocationWithIndex(invocation, index)];
    }
    
    return arguments;
}

id _Nonnull DP_argumentsFromInvocationWithIndex(NSInvocation * _Nonnull invocation, NSUInteger index) {
    const char *argumentType = [invocation.methodSignature getArgumentTypeAtIndex:index];
    
    if (argumentType[0] == 'r') {
        argumentType++;
    }
    
#define isArgumentTypeEquatTo(type) strcmp(argumentType, @encode(type)) == 0
    
#define returnValueIfArgumentTypeEqualTo(type) \
    if (strcmp(argumentType, @encode(type)) == 0) {\
        type val = 0; \
        [invocation getArgument:&val atIndex:index]; \
        return @(val); \
    }
    
    if (isArgumentTypeEquatTo(id) || isArgumentTypeEquatTo(Class) || isArgumentTypeEquatTo(void (^)())) {
        __unsafe_unretained id argument = nil;
        [invocation getArgument:&argument atIndex:index];
        return argument;
    }
    else returnValueIfArgumentTypeEqualTo(char)
    else returnValueIfArgumentTypeEqualTo(short)
    else returnValueIfArgumentTypeEqualTo(int)
    else returnValueIfArgumentTypeEqualTo(long)
    else returnValueIfArgumentTypeEqualTo(long long)
    else returnValueIfArgumentTypeEqualTo(unsigned char)
    else returnValueIfArgumentTypeEqualTo(unsigned short)
    else returnValueIfArgumentTypeEqualTo(unsigned int)
    else returnValueIfArgumentTypeEqualTo(unsigned long)
    else returnValueIfArgumentTypeEqualTo(unsigned long long)
    else returnValueIfArgumentTypeEqualTo(float)
    else returnValueIfArgumentTypeEqualTo(double)
    else returnValueIfArgumentTypeEqualTo(BOOL)
    else returnValueIfArgumentTypeEqualTo(const char *)
    else {
        NSUInteger size = 0;
        NSGetSizeAndAlignment(argumentType, &size, NULL);
        NSCParameterAssert(size > 0);
        uint8_t data[size];
        [invocation getArgument:&data atIndex:index];
        
        return [NSValue valueWithBytes:&data objCType:argumentType];
    }
}