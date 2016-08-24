//
//  DPDelegateProxy.h
//  DelegateProxy
//
//  Created by Ryo Aoyama on 8/5/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

@interface DPDelegateProxy: NSObject

- (void)interceptedSelector:(SEL _Nonnull)selector arguments:(NSArray * _Nonnull)arguments;

@end
