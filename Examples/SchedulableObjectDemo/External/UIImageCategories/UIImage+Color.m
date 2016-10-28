//
//  UIImage+Color.m
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 30.06.16.
//  Copyright (c) 2016 Pavel Osipov. All rights reserved.
//

#import "UIImage+Color.h"
#import "UIImage+Resize.h"

NS_ASSUME_NONNULL_BEGIN

@implementation UIImage (MRCApp)

+ (UIImage *)sod_resizableImageWithColor:(UIColor *)color
{
    return [[UIImage sod_imageWithColor:color size:CGSizeMake(3.0, 3.0)]
            resizableImageWithCapInsets:UIEdgeInsetsMake(1.0, 1.0, 1.0, 1.0)];
}

+ (UIImage *)sod_imageWithColor:(UIColor*)color size:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    UIBezierPath* rPath = [UIBezierPath bezierPathWithRect:CGRectMake(0.0, 0.0, size.width, size.height)];
    [color setFill];
    [rPath fill];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)sod_squareImageWithSideLength:(CGFloat)sideLength
{
    CGSize imageSize = self.size;
    CGFloat cropRectSide = 0.0;
    CGPoint cropRectOrigin = CGPointZero;
    if (imageSize.height >= imageSize.width) {
        cropRectSide = imageSize.width;
    } else if (imageSize.height < imageSize.width) {
        cropRectSide = imageSize.height;
        cropRectOrigin = CGPointMake((imageSize.width - cropRectSide)/2.0, 0.0);
    }
    UIImage *croppedImage = [self croppedImage:CGRectMake(cropRectOrigin.x, cropRectOrigin.y, cropRectSide, cropRectSide)];
    return [croppedImage resizedImage:CGSizeMake(sideLength, sideLength) interpolationQuality:kCGInterpolationDefault];
}

- (UIImage *)sod_imageByApplyingAlpha:(CGFloat)alpha {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    CGContextSetAlpha(ctx, alpha);
    CGContextDrawImage(ctx, area, self.CGImage);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end

NS_ASSUME_NONNULL_END
