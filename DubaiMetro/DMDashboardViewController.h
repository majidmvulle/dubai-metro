//
//  DMDashboardViewController.h
//  DubaiMetro
//
//  Created by Majid Mvulle on 9/8/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMDashboardStatusView.h"

typedef enum
{
    kLocationOff,
    kAtMetroStation,
    kDirectingToMetroStation,
    kUnknown,
    kInitializing

}Status;
@interface DMDashboardViewController : UIViewController
@property (nonatomic) Status status;
@property (weak, nonatomic) IBOutlet DMDashboardStatusView *statusView;
@property (weak, nonatomic) IBOutlet UIButton *viewTrainTimingsButton;
@property (weak, nonatomic) IBOutlet UIButton *startJourneyButton;
@property (nonatomic, strong) NSString *stationName;
@property (nonatomic) NSNumber *stationProximity;
- (void)rotateLayer:(CALayer *)layer by:(float)rotationValue;
@end