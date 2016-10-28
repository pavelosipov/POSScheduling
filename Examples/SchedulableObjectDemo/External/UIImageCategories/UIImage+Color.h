//
//  UIImage+Color.h
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 30.06.16.
//  Copyright (c) 2016 Pavel Osipov. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (MRCApp)

+ (UIImage *)sod_imageWithColor:(UIColor*)color size:(CGSize)size;
+ (UIImage *)sod_resizableImageWithColor:(UIColor *)color;
- (UIImage *)sod_squareImageWithSideLength:(CGFloat)sideLength;
- (UIImage *)sod_imageByApplyingAlpha:(CGFloat)alpha;

@end

NS_ASSUME_NONNULL_END
