//
//  DubaiMetroViewController.h
//  DubaiMetro
//
//  Created by Majid Mvulle on 8/27/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface DMViewController : UIViewController
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) CLLocation *currentLocation;
- (void)setupMetroStation:(id)sender; //to call a segue
@end