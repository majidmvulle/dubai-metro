//
//  RideRemindDashboardViewController.h
//  DubaiMetro
//
//  Created by Majid Mvulle on 4/14/14.
//  Copyright (c) 2014 Majid Mvulle. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum
{
    kLocationOff,
    kAtMetroStation,
    kDirectingToMetroStation,
    kUnknown,
    kInitializing

}Status;
@interface RideRemindDashboardViewController : UIViewController
@property (nonatomic) Status status;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedUnitLabel;

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@end
