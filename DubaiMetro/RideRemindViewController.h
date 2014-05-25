//
//  RideRemindViewController.h
//  DubaiMetro
//
//  Created by Majid Mvulle on 4/14/14.
//  Copyright (c) 2014 Majid Mvulle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Journey.h"
#import "DMViewController.h"

@interface RideRemindViewController : DMViewController
@property (nonatomic, strong) JourneyRoute *journeyRoute;
@end
