//
//  SODSettingsViewController.h
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 15.06.16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SODAccountAssembly;

@interface SODSettingsViewController : UIViewController

- (instancetype)initWithAssembly:(id<SODAccountAssembly>)assembly;

@end
