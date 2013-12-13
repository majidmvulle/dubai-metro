//
//  TrainBound.h
//  DubaiMetro
//
//  Created by Majid Mvulle on 11/3/13.
//  Copyright (c) 2013 Majid Mvulle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MetroStation, TrainTiming;

@interface TrainBound : NSManagedObject

@property (nonatomic, retain) NSString * boundStationId;
@property (nonatomic, retain) NSSet *boundFromStations;
@property (nonatomic, retain) NSSet *trainTiming;
@end

@interface TrainBound (CoreDataGeneratedAccessors)

- (void)addBoundFromStationsObject:(MetroStation *)value;
- (void)removeBoundFromStationsObject:(MetroStation *)value;
- (void)addBoundFromStations:(NSSet *)values;
- (void)removeBoundFromStations:(NSSet *)values;

- (void)addTrainTimingObject:(TrainTiming *)value;
- (void)removeTrainTimingObject:(TrainTiming *)value;
- (void)addTrainTiming:(NSSet *)values;
- (void)removeTrainTiming:(NSSet *)values;

@end
