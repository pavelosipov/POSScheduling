//
//  NSBundle+SODPresentation.h
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 29.10.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSBundle (SODPresentation)

- (NSString *)sod_dropboxAppKey;
- (NSString *)sod_dropboxAppSecret;

@end

NS_ASSUME_NONNULL_END
