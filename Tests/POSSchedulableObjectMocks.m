//
//  POSSchedulableObjectMocks.m
//  POSScheduling
//
//  Created by Pavel Osipov on 25.05.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import "POSSchedulableObjectMocks.h"

@implementation EmptyMock
@end

@implementation TestA
- (void)a {}
@end

@implementation SchedulableObject

- (void)methodA {}

- (CGSize)preferedSize {
    return CGSizeMake(0.0, 0.0);
}

@end
