//
//  DPRuntime.m
//  DelegateProxy
//
//  Created by Ryo Aoyama on 8/5/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <DelegateProxy/DPRuntime.h>

BOOL isMethodReturnTypeVoid(struct objc_method_description method) {
    return strncmp(method.types, @encode(void), 1) == 0;
}

BOOL isMethodSignatureVoid(NSMethodSignature * _Nonnull methodSignature) {
    const char *methodReturnType = methodSignature.methodReturnType;
    return strcmp(methodReturnType, @encode(void)) == 0;
}

NSArray * _Nonnull argumentsFromInvocation(NSInvocation * _Nonnull invocation) {
    // TODO:
    return [NSArray array];
}