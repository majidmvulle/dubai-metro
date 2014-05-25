//
//  LoadingOverlay.m
//  DubaiMetro
//
//  Created by Majid Mvulle on 4/7/14.
//  Copyright (c) 2014 Majid Mvulle. All rights reserved.
//

#import "LoadingOverlay.h"


@interface LoadingOverlay()
@property (nonatomic, strong) UIActivityIndicatorView *activitySpinner;
@property (nonatomic, strong) UILabel *loadingLabel;
@end

@implementation LoadingOverlay

- (id)initWithCustomFrame:(CGRect)rect
{

    self = [super init];

    if(self){
        self.frame = rect;

        self.backgroundColor = [UIColor blackColor];
        self.alpha = 0.75f;

        float labelHeight = 22;
        float labelWidth = rect.size.width - 20;

            // derive the center x and y
        float centerX = rect.size.width / 2;
        float centerY = rect.size.height / 2;

            // create the activity spinner, center it horizontall and put it 5 points above center x

        self.activitySpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];

        self.activitySpinner.frame = CGRectMake(centerX - (self.activitySpinner.frame.size.width / 2),
                                                centerY - (self.activitySpinner.frame.size.height - 20),
                                                self.activitySpinner.frame.size.width,
                                                self.activitySpinner.frame.size.height);

        self.activitySpinner.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        [self addSubview:self.activitySpinner];

        [self.activitySpinner startAnimating];

            // create and configure the "Loading Data" label
        self.loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(centerX - (labelWidth / 2),
                                                                      centerY + 20,
                                                                      labelWidth, labelHeight)];
        self.loadingLabel.backgroundColor = [UIColor clearColor];
        self.loadingLabel.textColor = [UIColor whiteColor];
        self.loadingLabel.text = @"Loading...";
        self.loadingLabel.textAlignment = NSTextAlignmentCenter;

        self.loadingLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.loadingLabel];
    }

    return self;
}

- (void)hide
{
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished){
        if(finished){
        [self removeFromSuperview];
        }
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
