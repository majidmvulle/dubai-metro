//
//  DMDashboardViewController.m
//  DubaiMetro
//
//  Created by Majid Mvulle on 9/8/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "DMDashboardViewController.h"
#import "DMDashboardStatusView.h"
#import <QuartzCore/QuartzCore.h>

@interface DMDashboardViewController ()
@property (weak, nonatomic) IBOutlet UILabel *statusTitle;
@property (weak, nonatomic) IBOutlet UILabel *statusDescription;
@property (nonatomic, strong) NSNumber *previousRotateBy;
@end

@implementation DMDashboardViewController

#pragma mark - View Controller methods

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor clearColor];
    [self setupFonts];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
}

#pragma mark - Dashboard methods

- (void)setStationName:(NSString *)stationName
{
    _stationName = [stationName uppercaseString];
    [self setupDirectingToLocationStatus];
}

- (void)setStationProximity:(NSNumber *)stationProximity
{
    _stationProximity = stationProximity;
    [self setupDirectingToLocationStatus];
}

#pragma mark - Status methods

- (void)setStatus:(Status)status
{
    _status = status;

    self.statusView.isRotatable = NO;
    [self.statusView.layer removeAllAnimations];

    switch (status) {
        case kAtMetroStation:
            [self setupAtLocationStatus];
            break;
        case kLocationOff:
            [self setupLocationOffStatus];
            break;
        case kDirectingToMetroStation:
            [self setupDirectingToLocationStatus];
            break;
        case kUnknown:
            [self setupUnknown];
            break;
        case kInitializing:
            [self setupInitializing];
            break;
    }
}

- (void)setupAtLocationStatus
{
    [self showViewTrainTimingButton];
    [self hideStartJourneyButton];
        //Future Update: Enable to continue, Start Journey
        //    [self showStartJourneyButton];

    self.statusView.image = [UIImage imageNamed:@"dashboard-atstation.png"];
    self.statusTitle.text = [self.stationName uppercaseString];
    self.statusDescription.text = AT_STATION_TEXT;
}

- (void)setupLocationOffStatus
{
    [self hideViewTrainTimingButton];
    [self hideStartJourneyButton];

    self.statusView.image = [UIImage imageNamed:@"dashboard-off.png"];
    self.statusTitle.text = @"Location Services OFF";
    self.statusDescription.text = @"Enable Location Services in Settings";
}

- (void)setupDirectingToLocationStatus
{
    [self showViewTrainTimingButton];
    [self hideStartJourneyButton];

    DistanceSuffix distanceSuffix;
    distanceSuffix.isShortSuffix = NO;
    distanceSuffix.isLongSuffix = YES;

    self.statusView.image = [UIImage imageNamed:@"dashboard-directing.png"];
    self.statusView.isRotatable = YES;
    self.statusTitle.text = self.stationName;
    if(self.stationProximity){

        self.statusDescription.text = [NSString stringWithFormat:@"About %@ Away", [[DMHelper sharedInstance] formatDistance:self.stationProximity withSuffix:distanceSuffix]];
    }else{
        self.statusDescription.text = nil;
    }
}

- (void)setupUnknown
{
    [self hideViewTrainTimingButton];
    [self hideStartJourneyButton];

    self.statusView.image = [UIImage imageNamed:@"dashboard-unknown.png"];
    self.statusTitle.text = @"NONE";
    self.statusDescription.text = @"No Metro Station Nearby";

}

- (void)setupInitializing
{
    [self hideViewTrainTimingButton];
    [self hideStartJourneyButton];

    self.statusView.image = [UIImage imageNamed:@"dashboard-locating.png"];
    self.statusTitle.text = @"DETERMINING YOUR LOCATION";
    self.statusDescription.text = @"";
}

- (void)hideViewTrainTimingButton
{
    if(!self.viewTrainTimingsButton.hidden) self.viewTrainTimingsButton.hidden = YES;
}

- (void)showViewTrainTimingButton
{
    if(self.viewTrainTimingsButton.hidden) self.viewTrainTimingsButton.hidden = NO;
}

- (void)hideStartJourneyButton
{
    if(!self.startJourneyButton.hidden) self.startJourneyButton.hidden = YES;
}

- (void)showStartJourneyButton
{
    if(self.startJourneyButton.hidden) self.startJourneyButton.hidden = NO;
}

- (void)rotateLayer:(CALayer *)layer by:(float)rotationValue
{
    if(!self.previousRotateBy) self.previousRotateBy = [NSNumber numberWithFloat:0.0];

    NSNumber *rotateBy = [NSNumber numberWithFloat:rotationValue];
    CAKeyframeAnimation *rotateAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];

    rotateAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    rotateAnimation.values = @[self.previousRotateBy, rotateBy];
    rotateAnimation.duration = 5.0;
    rotateAnimation.removedOnCompletion = NO;
    rotateAnimation.fillMode = kCAFillModeForwards;

    self.previousRotateBy = rotateBy;

    [layer addAnimation:rotateAnimation forKey:@"transform"];
}

- (void)setupFonts
{
    for(id subview in [self.view subviews]){
        if([subview isKindOfClass:[UILabel class]]){
            ((UILabel *)subview).font = [DMHelper dmFontWithSize:((UILabel *)subview).font.pointSize];
        }else if([subview isKindOfClass:[UIButton class]]){
            ((UIButton *)subview).titleLabel.font = [DMHelper dmFontWithSize:((UIButton *)subview).titleLabel.font.pointSize];
        }
    }
}

@end