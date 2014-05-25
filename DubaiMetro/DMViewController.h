//
//  DMViewController.h
//  DubaiMetro
//
//  Created by Majid Mvulle on 4/14/14.
//  Copyright (c) 2014 Majid Mvulle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AllMetroStationsMapViewController.h"
#import "MetroStation.h"

@interface DMViewController : UIViewController <CLLocationManagerDelegate>
@property (nonatomic, strong) MetroStation *nearestMetroStation;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) AllMetroStationsMapViewController *metroStationsMapvc;
@property (nonatomic) BOOL shouldUpdateProximity;
- (void)reloadMap;
@end
