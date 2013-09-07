//
//  DMBarButtonItem.m
//  DubaiMetro
//
//  Created by Majid Mvulle on 9/4/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "DMBarButtonItem.h"

@implementation DMBarButtonItem

- (void)setup
{
    const float colorMask[6] = {222, 255, 222, 255, 222, 255};
    UIImage *image = [UIImage imageWithCGImage: CGImageCreateWithMaskingColors([[UIImage alloc] init].CGImage, colorMask)];

    [self setBackgroundImage:image forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];

}

@end
