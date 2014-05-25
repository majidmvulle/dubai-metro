//
//  RideRemindDashboardViewController.m
//  DubaiMetro
//
//  Created by Majid Mvulle on 4/14/14.
//  Copyright (c) 2014 Majid Mvulle. All rights reserved.
//

#import "RideRemindDashboardViewController.h"

@interface RideRemindDashboardViewController ()

@end

@implementation RideRemindDashboardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupFonts];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setStatus:(Status)status
{
    _status = status;

    switch (_status) {
        case kLocationOff:
            self.statusLabel.text = @"Location Services Off";
            self.speedLabel.text = @"-";
            self.speedUnitLabel.text = @"";
            break;
        default:
            break;
    }
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
