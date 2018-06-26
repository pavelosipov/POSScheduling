//
//  RACSignal+POSScheduling.h
//  POSScheduling
//
//  Created by Pavel Osipov on 13.06.16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
#   import <ReactiveObjC/ReactiveObjC.h>
#pragma clang diagnostic pop

NS_ASSUME_NONNULL_BEGIN

@interface RACSignal<__covariant ValueType> (POSScheduling)

- (nullable __kindof ValueType)pos_await;

@end

NS_ASSUME_NONNULL_END
