//
//  AllStationsCDTVC.h
//  DubaiMetro
//
//  Created by Majid Mvulle on 10/7/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "CoreDataTableViewController.h"

@class MetroStation;
@interface MetroStationCDTVC : CoreDataTableViewController
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) MetroStation *selectedMetroStation;
@property (nonatomic, strong) MetroStation *metroStationToDisable;
@property (nonatomic, getter = isStartingJourney) BOOL startingJourney;
@property (nonatomic) BOOL shouldShowStationTrainTimings;
@end