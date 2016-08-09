//
//  DPDelegateProxy.m
//  DelegateProxy
//
//  Created by Ryo Aoyama on 8/5/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DPDelegateProxy.h"
#import "DPRuntime.h"

@implementation DPDelegateProxy

- (void)interceptedSelector:(SEL)selector arguments:(NSArray *)arguments {
    NSAssert(NO, @"Abstract method");
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    if (DP_IsMethodSignatureVoid(anInvocation.methodSignature)) {
        NSArray *arguments = DP_ArgumentsFromInvocation(anInvocation);
        [self interceptedSelector:anInvocation.selector arguments:arguments];
    }
}

@end