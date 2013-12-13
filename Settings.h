//
//  Settings.h
//  DubaiMetro
//
//  Created by Majid Mvulle on 10/15/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//
//  Manually call synchronize to save changes

#import <Foundation/Foundation.h>

@interface Settings : NSObject
@property (nonatomic, getter = isMeasurementImperial) BOOL measurementImperial;
@property (nonatomic, getter = isTimeTwelveHour) BOOL timeTwelveHour;
@property (nonatomic) BOOL shouldTrackUsage;
@property (nonatomic) NSUInteger mapType;
@property (nonatomic, getter = isFirstLaunch) BOOL firstLaunch;
+ (Settings *)sharedInstance;
- (void)synchronize;
@end