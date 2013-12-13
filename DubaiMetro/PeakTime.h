//
//  PeakTime.h
//  DubaiMetro
//
//  Created by Majid Mvulle on 11/3/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MetroStationLine;

@interface PeakTime : NSManagedObject

@property (nonatomic, retain) NSString * dayGroup;
@property (nonatomic, retain) NSDate * eveningPeakFrom;
@property (nonatomic, retain) NSDate * eveningPeakTo;
@property (nonatomic, retain) NSDate * morningPeakFrom;
@property (nonatomic, retain) NSDate * morningPeakTo;
@property (nonatomic, retain) MetroStationLine *stationLine;

@end
