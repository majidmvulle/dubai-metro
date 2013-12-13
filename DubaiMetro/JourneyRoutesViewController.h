//
//  JourneyRoutesCollectionVC.h
//  DubaiMetro
//
//  Created by Majid Mvulle on 10/28/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MetroStation;
@interface JourneyRoutesViewController : UIViewController
@property (nonatomic, strong) MetroStation *fromStation;
@property (nonatomic, strong) MetroStation *toStation;
@end