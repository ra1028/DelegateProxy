//
//  DPDelegateProxy.m
//  DelegateProxy
//
//  Created by 青山 遼 on 2016/08/08.
//  Copyright © 2016年 Ryo Aoyama. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DPDelegateProxy.h"
#import "DPRuntime.h"

@implementation DPDelegateProxy

- (void)interceptedSelector:(SEL)selector arguments:(NSArray *)arguments {
    
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    if (isMethodSignatureVoid(anInvocation.methodSignature)) {
        NSArray *arguments = argumentsFromInvocation(anInvocation);
        [self interceptedSelector:anInvocation.selector arguments:arguments];
    }
}

@end