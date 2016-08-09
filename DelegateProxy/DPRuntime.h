//
//  DPRuntime.h
//  DelegateProxy
//
//  Created by Ryo Aoyama on 8/5/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

BOOL DP_IsMethodReturnTypeVoid(struct objc_method_description method);

BOOL DP_IsMethodSignatureVoid(NSMethodSignature * _Nonnull methodSignature);

NSArray * _Nonnull DP_ArgumentsFromInvocation(NSInvocation * _Nonnull invocation);

id _Nonnull DP_ArgumentsFromInvocationWithIndex(NSInvocation * _Nonnull invocation, NSUInteger index);