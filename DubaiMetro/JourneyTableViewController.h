//
//  JourneyTableViewController.h
//  DubaiMetro
//
//  Created by Majid Mvulle on 9/18/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MetroStation;
@interface JourneyTableViewController : UITableViewController
@property (nonatomic, readonly) MetroStation *fromStation;
@property (nonatomic, readonly) MetroStation *toStation;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
- (IBAction)unwindToSetupJourney:(UIStoryboardSegue *)segue;
@property (nonatomic) BOOL isStartingJourney;
@end