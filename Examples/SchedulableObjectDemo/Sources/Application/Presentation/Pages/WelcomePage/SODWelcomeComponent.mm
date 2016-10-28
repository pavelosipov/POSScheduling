//
//  SODWelcomeComponent.m
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 29.06.16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import "SODWelcomeComponent.h"
#import "SODWelcomeViewController.h"
#import "UIImage+Color.h"

NS_ASSUME_NONNULL_BEGIN

@interface SODWelcomeComponent ()
@property (nonatomic, nullable, weak) SODWelcomeViewController *signupHandler;
@end

@implementation SODWelcomeComponent

#pragma mark CKComponent

+ (instancetype)newWithModel:(SODWelcomeComponentModel)model
                     context:(nullable SODWelcomeViewController *)context {
    SODWelcomeComponent *that =
    [super newWithComponent:
     [CKButtonComponent
      newWithTitles:{{UIControlStateNormal, @"Link Dropbox"}}
      titleColors:{}
      images:{}
      backgroundImages:{
          {UIControlStateNormal, [UIImage sod_resizableImageWithColor:
                                  [UIColor colorWithRed:0.0 green:126./255. blue:229./255. alpha:1.0]]}
      }
      titleFont:nil
      selected:NO
      enabled:model.signupEnabled
      action:@selector(linkDropbox:)
      size:{}
      attributes:{}
      accessibilityConfiguration:{}]
     ];
    that.signupHandler = context;
    return that;
}

- (void)linkDropbox:(CKButtonComponent *)sender {
    [_signupHandler linkDropboxAccount];
}

@end

NS_ASSUME_NONNULL_END
