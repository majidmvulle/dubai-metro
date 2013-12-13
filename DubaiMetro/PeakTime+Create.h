//
//  PeakTime+Create.h
//  DubaiMetro
//
//  Created by Majid Mvulle on 9/29/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import "PeakTime.h"
@class MetroStationLine;
@interface PeakTime (Create)
+ (PeakTime *)createPeakTimeWithMorningPeakFrom:(NSDate *)morningPeakFrom
                                  morningPeakTo:(NSDate *)morningPeakTo
                                eveningPeakFrom:(NSDate *)eveningPeakFrom
                                  eveningPeakTo:(NSDate *)eveningPeakTo
                                       dayGroup:(NSString *)dayGroup
                                 andStationLine:(MetroStationLine *)stationLine;

+ (PeakTime *)fetchPeakTimeFor:(MetroStationLine *)stationLine andDayGroup:(NSString *)dayGroup;
@end