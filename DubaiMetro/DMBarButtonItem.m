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
    CGImageRef imageRef = CGImageCreateWithMaskingColors([[UIImage alloc] init].CGImage, colorMask);
    UIImage *image = [UIImage imageWithCGImage:imageRef];

    [self setBackgroundImage:image forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];

    CGImageRelease(imageRef);
}

- (void)setupBackButtonBackgroundImage
{
    [self setBackButtonBackgroundImage:[UIImage imageNamed:@"btn-back.png"]
                              forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
}

- (void)setupOrdinaryBackgroundImage
{
    if([DMHelper sharedInstance].isOS7AndAbove)
        self.tintColor = [UIColor whiteColor];
    else
        [self setBackgroundImage:[UIImage imageNamed:@"btn-ordinary.jpg"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
}

- (void)setupRedBackgroundImage
{
    if([DMHelper sharedInstance].isOS7AndAbove)
        self.tintColor = [UIColor redColor];
    else
        [self setBackgroundImage:[UIImage imageNamed:@"btn-red.jpg"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
}

- (void)setupGreenBackgroundImage
{
    if([DMHelper sharedInstance].isOS7AndAbove)
        self.tintColor = [UIColor greenColor];
    else
        [self setBackgroundImage:[UIImage imageNamed:@"btn-green.jpg"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
}

@end