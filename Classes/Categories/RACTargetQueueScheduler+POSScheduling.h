//
//  RACTargetQueueScheduler+POSScheduling.h
//  POSScheduling
//
//  Created by Pavel Osipov on 29.10.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
#   import <ReactiveObjC/ReactiveObjC.h>
#pragma clang diagnostic pop

NS_ASSUME_NONNULL_BEGIN

@interface RACTargetQueueScheduler (POSScheduling)

+ (instancetype)pos_scheduler;
+ (instancetype)pos_mainThreadScheduler;

@end

NS_ASSUME_NONNULL_END
