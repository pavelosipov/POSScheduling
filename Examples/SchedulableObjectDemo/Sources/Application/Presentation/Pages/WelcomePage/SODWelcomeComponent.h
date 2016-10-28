//
//  SODWelcomeComponent.h
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 29.06.16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import <ComponentKit/ComponentKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SODWelcomeViewController;

struct SODWelcomeComponentModel {
    BOOL signupEnabled;
};

@interface SODWelcomeComponent : CKCompositeComponent

+ (instancetype)newWithModel:(SODWelcomeComponentModel)model
                     context:(nullable SODWelcomeViewController *)context;

@end

NS_ASSUME_NONNULL_END
