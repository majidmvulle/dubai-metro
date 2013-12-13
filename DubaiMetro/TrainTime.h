//
//  TrainTime.h
//  DubaiMetro
//
//  Created by Majid Mvulle on 9/28/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MetroStation.h"
#import "TrainTiming.h"

@interface TrainTime : NSObject
@property (nonatomic, strong, readonly) NSArray *boundStations;
@property (nonatomic, strong, readonly) NSString *dayGroup;
- (id)initWithMetroStation:(MetroStation *)station;
- (MetroStation *)boundStationAtIndexPath:(NSIndexPath *)indexPath;
- (TrainTiming *)trainTimingForBoundStationAt:(NSIndexPath *)indexPath andDayGroup:(NSString *)dayGroup;
- (TrainTiming *)trainTimingForBoundStation:(MetroStation *)boundStation andDayGroup:(NSString *)dayGroup;
- (NSArray *)nextTrainBoundStation:(MetroStation *)boundStation;
+ (float)timeFromDate:(NSDate *)theDate;
+ (NSDateFormatter *)twentyFourHourTimeFormatter;
+ (NSDateFormatter *)twelveHourTimeFormatter;
+ (NSString *)today;
+ (NSString *)yesterday;
+ (NSString *)todayFullShortDate;
+ (NSString *)currentDayGroup;
+ (NSString *)previousDayGroup;
@end