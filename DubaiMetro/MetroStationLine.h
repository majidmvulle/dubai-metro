//
//  MetroStationLine.h
//  DubaiMetro
//
//  Created by Majid Mvulle on 11/3/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MetroStation, MetroStationOrder, PeakTime;

@interface MetroStationLine : NSManagedObject

@property (nonatomic, retain) NSData * polylinePath;
@property (nonatomic, retain) NSString * stationLineCode;
@property (nonatomic, retain) NSString * stationLineName;
@property (nonatomic, retain) NSSet *metroStations;
@property (nonatomic, retain) NSSet *peakTimes;
@property (nonatomic, retain) NSSet *stationOrders;
@end

@interface MetroStationLine (CoreDataGeneratedAccessors)

- (void)addMetroStationsObject:(MetroStation *)value;
- (void)removeMetroStationsObject:(MetroStation *)value;
- (void)addMetroStations:(NSSet *)values;
- (void)removeMetroStations:(NSSet *)values;

- (void)addPeakTimesObject:(PeakTime *)value;
- (void)removePeakTimesObject:(PeakTime *)value;
- (void)addPeakTimes:(NSSet *)values;
- (void)removePeakTimes:(NSSet *)values;

- (void)addStationOrdersObject:(MetroStationOrder *)value;
- (void)removeStationOrdersObject:(MetroStationOrder *)value;
- (void)addStationOrders:(NSSet *)values;
- (void)removeStationOrders:(NSSet *)values;

@end
