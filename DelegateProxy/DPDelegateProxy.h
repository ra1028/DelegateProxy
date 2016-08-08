//
//  DPDelegateProxy.h
//  DelegateProxy
//
//  Created by 青山 遼 on 2016/08/08.
//  Copyright © 2016年 Ryo Aoyama. All rights reserved.
//

@import Foundation;

@interface DPDelegateProxy: NSObject

- (void)interceptedSelector:(SEL _Nonnull)selector arguments:(NSArray * _Nonnull)arguments;

@end
