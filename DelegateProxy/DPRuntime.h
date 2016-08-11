//
//  DPRuntime.h
//  DelegateProxy
//
//  Created by Ryo Aoyama on 8/5/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

BOOL DP_isMethodReturnTypeVoid(struct objc_method_description method);

BOOL DP_isMethodSignatureVoid(NSMethodSignature * _Nonnull methodSignature);

NSArray * _Nonnull DP_argumentsFromInvocation(NSInvocation * _Nonnull invocation);

id _Nonnull DP_argumentsFromInvocationWithIndex(NSInvocation * _Nonnull invocation, NSUInteger index);