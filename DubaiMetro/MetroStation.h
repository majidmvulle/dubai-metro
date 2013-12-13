//
//  MetroStation.h
//  DubaiMetro
//
//  Created by Majid Mvulle on 11/3/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MetroStationLine, MetroStationOrder, MetroStationType, TrainBound;

@interface MetroStation : NSManagedObject

@property (nonatomic, retain) NSNumber * isStationOperational;
@property (nonatomic, retain) NSString * stationAttractions;
@property (nonatomic, retain) NSString * stationId;
@property (nonatomic, retain) NSNumber * stationLatitude;
@property (nonatomic, retain) NSNumber * stationLongitude;
@property (nonatomic, retain) NSString * stationName;
@property (nonatomic, retain) NSString * stationParking;
@property (nonatomic, retain) NSNumber * stationProximity;
@property (nonatomic, retain) NSNumber * stationZone;
@property (nonatomic, retain) NSSet *boundToStations;
@property (nonatomic, retain) NSSet *stationLines;
@property (nonatomic, retain) NSSet *stationOrders;
@property (nonatomic, retain) NSSet *stationTypes;
@end

@interface MetroStation (CoreDataGeneratedAccessors)

- (void)addBoundToStationsObject:(TrainBound *)value;
- (void)removeBoundToStationsObject:(TrainBound *)value;
- (void)addBoundToStations:(NSSet *)values;
- (void)removeBoundToStations:(NSSet *)values;

- (void)addStationLinesObject:(MetroStationLine *)value;
- (void)removeStationLinesObject:(MetroStationLine *)value;
- (void)addStationLines:(NSSet *)values;
- (void)removeStationLines:(NSSet *)values;

- (void)addStationOrdersObject:(MetroStationOrder *)value;
- (void)removeStationOrdersObject:(MetroStationOrder *)value;
- (void)addStationOrders:(NSSet *)values;
- (void)removeStationOrders:(NSSet *)values;

- (void)addStationTypesObject:(MetroStationType *)value;
- (void)removeStationTypesObject:(MetroStationType *)value;
- (void)addStationTypes:(NSSet *)values;
- (void)removeStationTypes:(NSSet *)values;

@end
